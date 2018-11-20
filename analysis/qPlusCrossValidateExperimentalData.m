% qPlusCrossValidatateExperimentalData
% Perform cross validation on experimenta data obtained via our qPlus experimental procedure
% The goal is to establish the quality of the model.
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters.
%
% 03/26/2018 ar Adapted it from the cross validation code written for demo data (not the adaptive experimental design).
% 04/16/2018 ar Adapting it for adaptive experimental design.

% Initialize
clear; close

% Specify directories
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),'/E3/');
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');
analysisDir  = fullfile(getpref('ColorMaterial', 'analysisDir'),'/E3/');

% Specify other experimental parameters
nBlocks = 8;


% Subjects to analyze
% subjectList = {'nzf', 'nkh','dca', 'hmn', ...
%     'ofv', 'gfn', 'ckf', 'lma',...
%     'cjz', 'lza', 'sel', 'jcd'};

subjectList = {'gfksim','lzasim','nkhsim'};


% Load structure that matches the experimental design of
% our initial experiments.
%
% This is stuff like the number of competitors and thier
% nominal positions -- things that are fixed throughout
% a particular experimental subproject.
params = getqPlusPilotExpParams;

params.whichDistance = 'euclidean';

params.interpCode = 'Cubic';

% Add to the parameters structure parameters that
% define the modeling we are doing.
%
% This is things like grid search parameters and information
% that defines how we compute likihood in the fitting.
params = getqPlusPilotModelingParams(params);

% Set indices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;

% Set cross-validation params.
% The model types are defined in the whichModelType
% loop below, with various integers corresponding to
% varous models.  Current types:
%  1: Full model
%  2: Cubic model
nModelTypes = 4;

% The two parameters bellow are fixed for both models.
% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% Do we start the parameter search from estimated qpParams? (true/false)
%  If false, we use our rich set of 75 diffent points (takes much longer)
params.qpParamsStart = false;

% Hard coded number of trials per run.
% Danger danger danger.  But we check
% after the load that things are OK.
nTrialsRun = 2160;

%% Subject loop
for ss = 1:length(subjectList)
    
    % Load subject data and aggregate across blocks
    thisSubject.trialData = [];
    
    for i = 1:nBlocks
        fileName = [subjectList{ss}, '/' subjectList{ss}, '-E3-' num2str(i) '.mat'];
        clear thisTempSet
        warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
        thisTempSet = load([dataDir, fileName]);
        warning(warnState);
        
        for t = 1:length(thisTempSet.params.data.trialData)
            thisSubject.trialData = [thisSubject.trialData; ...
                thisTempSet.params.data.trialData(t).stim, thisTempSet.params.data.trialData(t).outcome];
        end
    end
    
    if (size(thisSubject.trialData,1) ~= nTrialsRun)
        error('Specified and actual number of trials do not match.');
    end
    
    % Load the partition for this subject and get indices.
    thisPartition{ss} = load([analysisDir '/' subjectList{ss} 'partition.mat']);
    nFolds = thisPartition{ss}.c.NumTestSets; 
    if (size(thisSubject.trialData,1) ~= thisPartition{ss}.c.NumObservations)
        error('Actual number of trials do not match the number of trials used in cvpartition.');
    end
    
    for whichModelType = 1:nModelTypes
        
        % Set model types
        if whichModelType == 1
            params.whichPositions = 'full';
            modelCode = 'Full';
        elseif whichModelType == 2
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 3;
            modelCode = 'Cubic';
        elseif whichModelType == 3
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 2;
            modelCode = 'Quadratic';
        elseif whichModelType == 4
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 1;
            modelCode = 'Linear';
        else
            error('This model type is not yet implemented.');
        end
        
        for kk = 1:nFolds
            
            % Separate test and training
            clear trainingSet testSet
            trainingIndex = thisPartition{ss}.c.training(kk);
            testIndex = thisPartition{ss}.c.test(kk);
            
            trainingSet.newTrialData = qPlusConcatenateRawData(thisSubject.trialData(trainingIndex,:), indices);
            testSet.newTrialData = qPlusConcatenateRawData(thisSubject.trialData(testIndex,:), indices);
            
            % Concatenated training data
            trainingSet.pairColorMatchColorCoords = trainingSet.newTrialData(:,1);
            trainingSet.pairMaterialMatchColorCoords = trainingSet.newTrialData(:,2);
            trainingSet.pairColorMatchMaterialCoords = trainingSet.newTrialData(:,3);
            trainingSet.pairMaterialMatchMaterialCoords = trainingSet.newTrialData(:,4);
            trainingSet.firstChosen = trainingSet.newTrialData(:,5);
            trainingSet.newNTrials = trainingSet.newTrialData(:,6);
            trainingSet.pFirstChosen = trainingSet.firstChosen./trainingSet.newNTrials;
            
            % Concatenated test data
            testSet.pairColorMatchColorCoords = testSet.newTrialData(:,1);
            testSet.pairMaterialMatchColorCoords = testSet.newTrialData(:,2);
            testSet.pairColorMatchMaterialCoords = testSet.newTrialData(:,3);
            testSet.pairMaterialMatchMaterialCoords = testSet.newTrialData(:,4);
            testSet.firstChosen = testSet.newTrialData(:,5);
            testSet.newNTrials = testSet.newTrialData(:,6);
            testSet.pFirstChosen = testSet.firstChosen./testSet.newNTrials;
            
            % Model training data
            [trainingSet.returnedParams, trainingSet.logLikelyFit, trainingSet.predictedProbabilitiesBasedOnSolution] =  ...
                FitColorMaterialModelMLDS(trainingSet.pairColorMatchColorCoords, ...
                trainingSet.pairMaterialMatchColorCoords,...
                trainingSet.pairColorMatchMaterialCoords, ...
                trainingSet.pairMaterialMatchMaterialCoords,...
                trainingSet.firstChosen, trainingSet.newNTrials, params);
            
            % Now use these parameters to predict the responses for the test data.
            [negLogLikely,predictedProbabilities{kk}] = FitColorMaterialModelMLDSFun(trainingSet.returnedParams,...
                testSet.pairColorMatchColorCoords,testSet.pairMaterialMatchColorCoords,...
                testSet.pairColorMatchMaterialCoords,testSet.pairMaterialMatchMaterialCoords,...
                testSet.firstChosen, testSet.newNTrials, params);
            
            logLikelyhood(kk) = -negLogLikely; clear negLogLikely
            RMSError(kk) = ComputeRealRMSE(predictedProbabilities{kk}, testSet.pFirstChosen);
            
            dataSet{kk}.trainingSet = trainingSet; clear trainingSet
            dataSet{kk}.testSet = testSet; clear testSet
        end
        
        meanLogLiklihood = mean(logLikelyhood);
        meanRMSE = mean(RMSError);
        
        % Save in the right folder.
        cd(analysisDir);
        save([subjectList{ss} '-' num2str(nFolds) 'FoldsCV' '-'  modelCode  '-' params.whichDistance], ...
            'dataSet', 'logLikelyhood', 'predictedProbabilities', 'RMSError', ...
            'meanLogLiklihood', 'meanRMSE');
        clear dataSet LogLikelyhood predictedProbabilities RMSError
        cd(codeDir)
    end
end
