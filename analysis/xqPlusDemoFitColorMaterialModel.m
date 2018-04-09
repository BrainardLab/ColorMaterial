% xqPlusDemoFitColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Demo';
demoDir = fullfile( getpref('ColorMaterial', 'demoDataDir'));
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');

% Exp parameters
% Specify other experimental parameters
nSets = 8;
distances = {'euclidean'};

% Here we use the example structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;

params.whichDistance = 'euclidean';
params.interpCode = 'Cubic';

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);

% Get the qpParams quickly. 
tempParams = params; 
tempParams.whichPositions = 'smoothSpacing'; 
tempParams.smoothOrder = 3; 

% Set up more modeling parameters
params.whichPositions = 'full';

% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% setIndices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;
simulatedPsiParams = [3 0 0 2 0 0 0.2];

% parameters, the same as in the experiment. 
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

% Load the initialization file. 
warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
qpInit = load('/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/E3/initalizedQuestsExp3-09-Apr-2018.mat');
warning(warnState);
for ss = 1 % we can modigy this is we have sets with different position spacings.
    for d = 1%:length(distances)
        
        % Set up the quest data structure that updates. 
        questDataAllTrials = qpInit.questData{end};
        questDataAllTrials.noentropy = true; 
        
        % Set counter. 
        n = 0;
       
        for i = 1:nSets
            % Load the data set
            fileName = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/E3/test/test-E3-' num2str(i) '.mat'];
            warning(warnState);
            clear thisTempSet
            thisTempSet = load([fullfile(fileName)]);
            % Get stuff we need for likelihood estimates.
            % These do not change across trials/blocks. 
            qpPF = thisTempSet.params.data.qpPF;
            nOutcomes = thisTempSet.params.data.nOutcomes;
            
            for t = 1:length(thisTempSet.params.data.trialData)
                n = n+1;
                thisSet.trialData(n,1).stim = thisTempSet.params.data.trialData(t).stim;
                thisSet.trialData(n,1).outcome = thisTempSet.params.data.trialData(t).outcome;
                % update the posterior across all trials in the experiment.
                tic
                questDataAllTrials = qpUpdate(questDataAllTrials, thisTempSet.params.data.trialData(t).stim, ...
                    thisTempSet.params.data.trialData(t).outcome); 
                toc
            end
        end
        % Print some diagnostics
        clear psiParamsIndex psiParamsQuest psiParamsFit
        stimCounts = qpCounts(qpData(thisSet.trialData),nOutcomes);
        psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
        psiParamsQuest = thisTempSet.params.data.psiParamsDomain(psiParamsIndex,:);
        
        psiParamsFit = qpFit(thisSet.trialData,qpPF,psiParamsQuest(:),nOutcomes,...
            'lowerBounds', [1/upperLin -upperQuad -upperCubic ...
            1/upperLin -upperQuad -upperCubic 0], ...
            'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
        fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
            psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4), ...
            psiParamsFit(5),psiParamsFit(6),psiParamsFit(7));
        fprintf('Log 10 likelihood of data fit max likelihood params: %0.2f\n', ...
            qpLogLikelihood(stimCounts, qpPF, psiParamsFit)/log(10));
        
        [thisSet.initialParams(1:7), thisSet.initialParams(8:14), thisSet.initialParams(15), thisSet.initialParams(16)] =...
            ColorMaterialModelXToParams([psiParamsFit;1],tempParams);
        
        % Concatenate across blocks
        thisSet.rawTrialData = thisSet.trialData;
        thisSet.newTrialData = qPlusConcatenateRawData(thisSet.rawTrialData, indices);
        
        % Convert the information about pairs to 'our prefered representation'
        thisSet.pairColorMatchColorCoords = thisSet.newTrialData(:,1);
        thisSet.pairMaterialMatchColorCoords = thisSet.newTrialData(:,2);
        thisSet.pairColorMatchMaterialCoords = thisSet.newTrialData(:,3);
        thisSet.pairMaterialMatchMaterialCoords = thisSet.newTrialData(:,4);
        thisSet.firstChosen = thisSet.newTrialData(:,5);
        thisSet.newNTrials = thisSet.newTrialData(:,6);
        thisSet.pFirstChosen = thisSet.firstChosen./thisSet.newNTrials;
        
        % Implement the model
        params.qpParamsStart = true;
        params.qpInitialParams = thisSet.initialParams;
        [thisSet.returnedParams, thisSet.logLikelyFit, thisSet.predictedProbabilitiesBasedOnSolution] =  FitColorMaterialModelMLDS(thisSet.pairColorMatchColorCoords, ...
            thisSet.pairMaterialMatchColorCoords,...
            thisSet.pairColorMatchMaterialCoords, ...
            thisSet.pairMaterialMatchMaterialCoords,...
            thisSet.firstChosen, thisSet.newNTrials, params);
        
        % Extract parameters
        [thisSet.returnedMaterialMatchColorCoords, thisSet.returnedColorMatchMaterialCoords, ...
            thisSet.returnedW, thisSet.returnedSigma]  = ColorMaterialModelXToParams(thisSet.returnedParams, params);
        fprintf('Log likelihood of data given our model parameters: %0.2f\n', thisSet.logLikelyFit);
        
        % Save
        cd (demoDir)
        save([fileName 'Fit'], 'thisSet'); clear thisSet
        cd (codeDir)
    end
end
