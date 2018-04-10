% qPlusImplementColorMaterialModel
% Main script for data analysis of qPlus implementation

% 04/10/2018 ar Wrote it. 

% Initialize
clear; close

% Specify directories
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),'/E3/'); 
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');

% Specify other experimental parameters
nSets = 8;
distances = {'euclidean'};

% Load structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;

params.whichDistance = 'euclidean';
params.interpCode = 'Cubic';

% Set up initial modeling paramters
params = getqPlusPilotModelingParams(params);

% Use this adapted structure to get qpParams for likelihood estimation. 
tempParams = params; 
tempParams.whichPositions = 'smoothSpacing'; 
tempParams.smoothOrder = 3; 

% Set up more modeling parameters
% 1) Which position type are we fitting? ('full', 'smoothSpacing'). 
params.whichPositions = 'full';

% 2) Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% 3) Do we start the parameter search from estimated qpParams? (true/false) 
%  If false, we use our rich set of 75 diffent points (takes much longer)  
params.qpParamsStart = false; 

% Set Indices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;

% load the same qPlus params as in the experiment. 
% tempqPParams = run([getpref('ColorMaterial', 'mainCodeDir') '/getQuestParamsExp3']);
lowerLin = 0.5;
upperLin = 6;
nLin = 5;

lowerQuad = -0.3;
upperQuad = -lowerQuad;
nQuad = 4;

lowerCubic = -0.3;
upperCubic = -lowerCubic;
nCubic = 4;

lowerWeight = 0.05;
upperWeight = 0.95;
nWeight = 5;

subjectList = {'test'}; 

% Load the initialization file. 
warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
qpInit = load([dataDir, 'initalizedQuestsExp3-09-Apr-2018.mat']);
warning(warnState);
for ss = 1:length(subjectList) % we can modigy this is we have sets with different position spacings.
    for d = 1:length(distances)
            
        % Set up the quest data structure that updates. 
        questDataAllTrials = qpInit.questData{end};
        questDataAllTrials.noentropy = true; 
        
        % Start the counter for concatenating trials. 
        n = 0;
        
        % Load and reformat all trials. 
        for i = 1:nSets
            % Load the data set
            fileName = [subjectList{ss}, '/' subjectList{ss}, '-E3-' num2str(i) '.mat'];
            warning(warnState);
            clear thisTempSet
            thisTempSet = load([dataDir, fileName]);
            
            % Get few params that do not change across trials/blocks and that we
            % need to compute qPlus likelihoods. 
            qpPF = thisTempSet.params.data.qpPF;
            nOutcomes = thisTempSet.params.data.nOutcomes;
            
            for t = 1:length(thisTempSet.params.data.trialData)
                n = n+1;
                % Reformat the data for stimCounts below. 
                thisSubject.trialData(n,1).stim = thisTempSet.params.data.trialData(t).stim;
                thisSubject.trialData(n,1).outcome = thisTempSet.params.data.trialData(t).outcome;
                
                % Update the posterior across all trials in the experiment.
                questDataAllTrials = qpUpdate(questDataAllTrials, thisTempSet.params.data.trialData(t).stim, ...
                    thisTempSet.params.data.trialData(t).outcome); 
                
                % Make a duplicate matrix that works with our experimental
                % code that does concatination. 
                thisSubject.rawTrialData(n,:) = [thisSubject.trialData(n,1).stim, thisSubject.trialData(n,1).outcome]; 
            end
        end
        
        % Compute qPlus outcomes and some diagnostics
        clear psiParamsIndex psiParamsQuest psiParamsFit
        stimCounts = qpCounts(qpData(thisSubject.trialData),nOutcomes);
        psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
        psiParamsQuest = thisTempSet.params.data.psiParamsDomain(psiParamsIndex,:);
        psiParamsFit = qpFit(thisSubject.trialData,qpPF,psiParamsQuest(:),nOutcomes,...
            'lowerBounds', [1/upperLin -upperQuad -upperCubic ...
            1/upperLin -upperQuad -upperCubic 0], ...
            'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
        fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
            psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4), ...
            psiParamsFit(5),psiParamsFit(6),psiParamsFit(7));
        fprintf('Log 10 likelihood of data fit max likelihood params: %0.2f\n', ...
            qpLogLikelihood(stimCounts, qpPF, psiParamsFit)/log(10));
        
        % Save maximum likelihood params according to qplus
        [thisSubject.initialParams(1:7), thisSubject.initialParams(8:14), thisSubject.initialParams(15), thisSubject.initialParams(16)] =...
            ColorMaterialModelXToParams([psiParamsFit;1],tempParams);
        params.qpInitialParams = thisSubject.initialParams;
        
        % Concatenate across blocks
        thisSubject.newTrialData = qPlusConcatenateRawData(thisSubject.rawTrialData, indices);
        
        % Convert the information about pairs to 'our prefered representation'
        thisSubject.pairColorMatchColorCoords = thisSubject.newTrialData(:,1);
        thisSubject.pairMaterialMatchColorCoords = thisSubject.newTrialData(:,2);
        thisSubject.pairColorMatchMaterialCoords = thisSubject.newTrialData(:,3);
        thisSubject.pairMaterialMatchMaterialCoords = thisSubject.newTrialData(:,4);
        thisSubject.firstChosen = thisSubject.newTrialData(:,5);
        thisSubject.newNTrials = thisSubject.newTrialData(:,6);
        thisSubject.pFirstChosen = thisSubject.firstChosen./thisSubject.newNTrials;
        
        % Implement the model
        [thisSubject.returnedParams, thisSubject.logLikelyFit, thisSubject.predictedProbabilitiesBasedOnSolution] =  FitColorMaterialModelMLDS(thisSubject.pairColorMatchColorCoords, ...
            thisSubject.pairMaterialMatchColorCoords,...
            thisSubject.pairColorMatchMaterialCoords, ...
            thisSubject.pairMaterialMatchMaterialCoords,...
            thisSubject.firstChosen, thisSubject.newNTrials, params);
        
        % Extract parameters
        [thisSubject.returnedMaterialMatchColorCoords, thisSubject.returnedColorMatchMaterialCoords, ...
            thisSubject.returnedW, thisSubject.returnedSigma]  = ColorMaterialModelXToParams(thisSubject.returnedParams, params);
        fprintf('Log likelihood of data given our model parameters: %0.2f\n', thisSubject.logLikelyFit);
        
        % Save the outcome
        cd (getpref('ColorMaterial', 'demoDataDir'))
        subject{ss,d} = thisSubject; 
        save([subjectList{ss} distances{d} 'Fit'], 'thisSubject'); clear thisSubject
        cd (codeDir)
    end
end
