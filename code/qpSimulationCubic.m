function qpSimulationCubic(whichDistance, whichSmoothSpacing, filename, DO_INITIALIZE)
% Functionalize qPlus demo

%% Change to our pwd
cd(fileparts(mfilename('fullpath')));

%% We need the lookup table.  Load it.
% Load all simulation parameters. They are defined in the separate
% function. 
load('qPSimulationParams'); 

% load lookup table
theLookupTable = load(['colorMaterialInterpolateFun' whichInterp whichDistance '.mat']);

%% Define psychometric function in terms of lookup table
qpPFFun = @(stimParams,psiParams) qpPFColorMaterialCubicModel(stimParams,psiParams,theLookupTable.colorMaterialInterpolatorFunction);

%% Initialize three QUEST+ structures

% Each one has a different upper end of stimulus regime
% The last of these should be the most inclusive, and
% include stimuli that could come from any of them.

initFilename = ['initalizedQuestsParamsCubic' whichDistance]; 
initFileDir = getpref('ColorMaterial', 'demoDataDir');
if (DO_INITIALIZE)
    tic
    nQuests = length(stimUpperEnds);
    for qq = 1:nQuests
        fprintf('Initializing quest structure %d\n',qq)
        questData{qq} = qpInitialize( ...
            'qpPF',qpPFFun, ...
            'stimParamsDomainList',{-stimUpperEnds(qq):stimUpperEnds(qq), -stimUpperEnds(qq):stimUpperEnds(qq), -stimUpperEnds(qq):stimUpperEnds(qq), -stimUpperEnds(qq):stimUpperEnds(qq)}, ...
            'psiParamsDomainList',{ linspace(lowerLin,upperLin,nLin) linspace(lowerQuad,upperQuad,nQuad) linspace(lowerCubic,upperCubic,nCubic) ...
                                    linspace(lowerLin,upperLin,nLin) linspace(lowerQuad,upperQuad,nQuad) linspace(lowerCubic,upperCubic,nCubic) ...
                                    linspace(lowerWeight,upperWeight,nWeight) }, ...
            'filterPsiParamsDomainFun',@(psiParams) qpQuestPlusColorMaterialCubicModelParamsCheck(psiParams,maxStimValue,maxPosition,minSpacing) ...
            );
    end
    
    %% Define a questStructure that has all the stimuli
    %
    % We use this as a simple way to account for every
    % stimulus in the analysis at the end.
    questDataAllTrials = questData{end};
    
    %% Save out initialized quests
    save(fullfile(initFileDir,initFilename),'questData','questDataAllTrials');
    toc
end

% Load in intialized questDataAllTrials.  We do this outside
% the big loop over simulated sessions, as it is common acorss 
% those simulated sessions.
clear questDataAllTrials
load(fullfile(initFileDir,initFilename),'questDataAllTrials');

%% Set up simulated observer function
simulatedPsiParams = qPlusGeneratePositionsFromCubicParams(1,whichSmoothSpacing); 
simulatedObserverFun = @(x) qpSimulatedObserver(x,qpPFFun,simulatedPsiParams);

%% Run multiple simulations
tic
for ss = 1:nSessions
    % Load in the initialized quest structures
    fprintf('Session %d of %d\n',ss,nSessions);

    % Load just the initialized questData structures, leaving
    % the questDataAllTrials structure intact.  We do this separately
    % for each simulated session.
    clear questData
    load(fullfile(initFileDir,initFilename),'questData');
    
    % Force questDataAllTrials not to update entropy. This speeds things up
    % quite a bit, although you can't then make a nice plot of entropy as a
    % function of trial.
    questDataAllTrials.noentropy = true;
    
    % Run simulated trials, using QUEST+ to tell us what contrast to
    %
    % Define how many of each type of trial selection we'll do each time through.
    % 0 -> choose at random from all trials.
    for tt = 1:nTrialsPerQuest
%         fprintf('\tTrial block %d of %d\n',tt,nTrialsPerQuest');
%         bstart = tic;
        
        % Set the order for the specified quests and random
        questOrder = randperm(length(questOrderIn));
        for qq = 1:length(questOrder)
            theQuest = questOrderIn(questOrder(qq));
            
            % Get stimulus for this trial, either from one of the quests or at random.
            if (theQuest > 0)
                stim = qpQuery(questData{theQuest});
            else
                nStimuli = size(questDataAllTrials.stimParamsDomain,1);
                stim = questDataAllTrials.stimParamsDomain(randi(nStimuli),:);
            end
            
            % Simulate outcome
            outcome = simulatedObserverFun(stim);
            
            % Update quest data structure, if not a randomly inserted trial
            %tic
            if (theQuest > 0)
                questData{theQuest} = qpUpdate(questData{theQuest},stim,outcome);
            end
            
            % This data structure tracks all of the trials run in the
            % experiment.  We never query it to decide what to do, but we
            % will use it to fit the data at the end.
            questDataAllTrials = qpUpdate(questDataAllTrials,stim,outcome);
        end
%         btime = toc(bstart);
%         fprintf('\t\tBlock time = %0.1f secs, %0.1f secs/trial\n',btime,btime/length(questOrder));
    end
end

% Get stim counts
stimCounts = qpCounts(qpData(questDataAllTrials.trialData),questDataAllTrials.nOutcomes);

% Find out QUEST+'s estimate of the stimulus parameters, obtained
% on the gridded parameter domain.
psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
psiParamsQuest = questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
fprintf('Simulated parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4), ...
    simulatedPsiParams(5),simulatedPsiParams(6),simulatedPsiParams(7));
fprintf('Log 10 likelihood of data given simulated params: %0.2f\n', ...
    qpLogLikelihood(stimCounts,questDataAllTrials.qpPF,simulatedPsiParams)/log(10));
fprintf('Max posterior QUEST+ parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4), ...
    psiParamsQuest(5),psiParamsQuest(6),psiParamsQuest(7));
fprintf('Log 10 likelihood of data quest''s max posterior params: %0.2f\n', ...
    qpLogLikelihood(stimCounts,questDataAllTrials.qpPF, psiParamsQuest)/log(10));

% Maximum likelihood fit.  Use psiParams from QUEST+ as the starting
% parameter for the search, and impose as parameter bounds the range
% provided to QUEST+.
psiParamsFit = qpFit(questDataAllTrials.trialData,questDataAllTrials.qpPF,psiParamsQuest(:),questDataAllTrials.nOutcomes,...
    'lowerBounds', [1/upperLin -upperQuad -upperCubic 1/upperLin -upperQuad -upperCubic 0], ...
    'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
    psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4), ...
    psiParamsFit(5),psiParamsFit(6),psiParamsFit(7));
fprintf('Log 10 likelihood of data fit max likelihood params: %0.2f\n', ...
    qpLogLikelihood(stimCounts,questDataAllTrials.qpPF, psiParamsFit)/log(10));
fprintf('\n');


%% Save
cd(getpref('ColorMaterial', 'demoDataDir'));
positionsCode = {'Linear', 'Quadratic', 'Cubic'}; 
save(['test', whichDistance, 'Positions-' positionsCode{whichSmoothSpacing} '-' num2str(filename)]); clear;
toc

end
