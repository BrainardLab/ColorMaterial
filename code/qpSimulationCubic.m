function qpSimulationCubic(whichDistance, filename, DO_INITIALIZE)

% Demonstrate/test QUEST+ at work on the color material model, cubic
%
% Description:
%    This script shows QUEST+ employed to estimate the parameters of the
%    cubic version of the color material model.
%
%    To keep things managable in terms of time, the sampling of the
%    parameter space is sparse.  Not sure how that trades off in terms
%    of quality of stimulus choices.

% 12/19/17  dhb, ar  Created.
% 01/05/18  dhb      Futz with bounds on parameters so it doesn't bomb.
% 01/24/18  dhb      Cubic version.



%% Change to our pwd
cd(fileparts(mfilename('fullpath')));


%% We need the lookup table.  Load it.
% Specify which table
whichInterp = 'Cubic'; 
% whichDistance = 'euclidean'; 
theLookupTable = load(['colorMaterialInterpolateFun' whichInterp whichDistance '.mat']);

%% Define psychometric function in terms of lookup table
qpPFFun = @(stimParams,psiParams) qpPFColorMaterialCubicModel(stimParams,psiParams,theLookupTable.colorMaterialInterpolatorFunction);

%% Define parameters that set up parameter grid for QUEST+
lowerLin = 1;
upperLin = 6;
lowerQuad = -0.3;
upperQuad = -lowerQuad;
lowerCubic = -0.3;
upperCubic = -lowerCubic;
lowerWeight = 0.05;
upperWeight = 0.95;
nLin = 5;
nQuad = 4;
nCubic = 4;
nWeight = 5;

% Set up parameter constraints.  
maxStimValue = 3;
maxPosition = 20;
minSpacing = 0.25;

%% Initialize three QUEST+ structures

% Each one has a different upper end of stimulus regime
% The last of these should be the most inclusive, and
% include stimuli that could come from any of them.
DO_INITIALIZE = true;
initFilename = 'initalizedQuestsParamsCubicEuclidean'; 
if (DO_INITIALIZE)
    stimUpperEnds = [1 2 3];
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
   
    save(fullfile(tempdir,initFilename),'questData','questDataAllTrials');
end

% Load in intialized questDataAllTrials.  We do this outside
% the big loop over simulated sessions, as it is common acorss 
% those simulated sessions.
clear questDataAllTrials
load(fullfile(tempdir,initFilename),'questDataAllTrials');

%% Set up simulated observer function
whichSmoothSpacing = 3; 
simulatedPsiParams = generatePositionsFromCubicParams(1,whichSmoothSpacing);
simulatedObserverFun = @(x) qpSimulatedObserver(x,qpPFFun,simulatedPsiParams);

%% Run multiple simulations
nSessions = 8;
nTrialsPerQuest = 30;
questOrderIn = [0 1 2 3 3 3 3 3 3];
tic
for ss = 1:nSessions
    % Load in the initialized quest structures
    fprintf('Session %d of %d\n',ss,nSessions);

    % Load just the initialized questData structures, leaving
    % the questDataAllTrials structure intact.  We do this separately
    % for each simulated session.
    clear questData
    load(fullfile(tempdir,initFilename),'questData');
    
    % Force questDataAllTrials not to update entropy. This speeds things up
    % quite a bit, although you can't then make a nice plot of entropy as a
    % function of trial.
    questDataAllTrials.noentropy = true;
    
    % Run simulated trials, using QUEST+ to tell us what contrast to
    %
    % Define how many of each type of trial selection we'll do each time through.
    % 0 -> choose at random from all trials.
    for tt = 1:nTrialsPerQuest
     %   fprintf('\tTrial block %d of %d\n',tt,nTrialsPerQuest');
        bstart = tic;
        
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
        btime = toc(bstart);
    %    fprintf('\t\tBlock time = %0.1f secs, %0.1f secs/trial\n',btime,btime/length(questOrder));
    end
end

%% Save
cd(getpref('ColorMaterial'), 'demoDataDir');
save(['qpSimulation' whichInterp whichDistance, filename]); clear;
toc

end
