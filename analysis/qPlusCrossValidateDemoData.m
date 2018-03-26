% qPlusCrossValidatateDemoData
% Perform cross validation on experimenta data obtained via our qPlus experimental procedure
% The goal is to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters.
%
% 03/26/2018 ar Adapted it from the cross validation code written for demo data (not the adaptive experimental design).

% Initialize
clear; close

% Specify directories
demoDir = fullfile( getpref('ColorMaterial', 'demoDataDir'));

% Specify parameters related to the data set
nSets = 20;
distances = {'euclidean', 'cityblock'};
positionSmoothSpacing = 3;
positionCode = {'Linear', 'Quad', 'Cubic'};

% Set up experimen parameters, which are common for all the data
params = getqPlusPilotExpParams;
params.whichDistance = 'euclidean';
params.interpCode = 'Cubic';
% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);
% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% Set indices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;

% Set cross-validation params. 
nModelTypes = 2;
nFolds = 8;
nTrialsRun = 2160;


%% Define different models.
% To enable the same partition across condition
% Set cross validation parameters
for ss = 1
    for d = 1%:length(distances)
        for i = 1%:nSets
            for whichModelType = 1:nModelTypes
                % Partition and get indices.
                c = cvpartition(nTrialsRun,'Kfold',nFolds);
                
                % Set model types
                if whichModelType == 1
                    params.whichPositions = 'full';
                    modelCode = 'Full';
                elseif whichModelType == 2
                    params.whichPositions = 'smoothSpacing';
                    params.smoothOrder = 3; 
                    modelCode = 'Cubic';
                else
                    error('This model type is not yet implemented.');
                end
                
                % Load and reformat the data set
                fileName = ['test' distances{d} 'Positions-' positionCode{positionSmoothSpacing(ss)} '-' num2str(i)]; %qpSimulationcityblockPositions-Linear-10
                warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
                thisTempSet = load([fullfile(demoDir, fileName)]);
                %thisSet = thisTempSet.questDataAllTrials;
                warning(warnState);
                thisSet.trialData = [];
                for t = 1:length(thisTempSet.questDataAllTrials.trialData)
                    thisSet.trialData = [thisSet.trialData; ...
                        thisTempSet.questDataAllTrials.trialData(t).stim, thisTempSet.questDataAllTrials.trialData(t).outcome];
                end
                clear thisTempSet;
                
                for kk = 1:nFolds
                    
                    % Separate test and training
                    trainingIndex = c.training(kk);
                    testIndex = c.test(kk);
                    
                    trainingSet.newTrialData = qPlusConcatenateRawData(thisSet.trialData(trainingIndex,:), indices);
                    testSet.newTrialData = qPlusConcatenateRawData(thisSet.trialData(testIndex,:), indices);
                    
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
                    [negLogLikely,predictedResponses] = FitColorMaterialModelMLDSFun(trainingSet.returnedParams,...
                        testSet.pairColorMatchColorCoords,testSet.pairMaterialMatchColorCoords,...
                        testSet.pairColorMatchMaterialCoords,testSet.pairMaterialMatchMaterialCoords,...
                        testSet.firstChosen, testSet.newNTrials, params);
                    
                    LogLikelyhood(kk) = -negLogLikely; clear negLogLikely
                    predictedProbabilities(kk,:) = predictedResponses; clear predictedResponses
                    RMSError(kk) = ComputeRealRMSE(predictedResponses, probabilitiesTestData);
                    
                    dataSet{kk}.trainingSet = trainingSet; clear trainingSet
                    dataSet{kk}.testSet = testSet; clear testSet
                end
                
                % Save in the right folder.
                cd(figAndDataDir);
                save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(nFolds) 'Folds'   modelCode], ...
                    'dataSet', 'LogLikelyhood', 'predictedProbabilities', 'RMSError');
                clear dataSet LogLikelyhood predictedProbabilities RMSError
            end
        % Could add print outcome here.     
        end
    end
end

%         %% Print outputs
%         if printOutcome
%             for i = 1:nModelTypes
%                 tmpMeanError(i) = mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood);
%             end
%             fprintf('meanLogLikely: %s  %.4f, %s %.4f, %s %.4f.\n', modelCode(1), tmpMeanError(1), modelCode(2), tmpMeanError(2), modelCode(3), tmpMeanError(3));
%             
%             for i = 1:nModelTypes
%                 tmpMeanError(i) = mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
%             end
%             fprintf('meanRMSE: %s  %.4f, %s %.4f, %s %.4f.\n', modelCode(1), tmpMeanError(1), modelCode(2), tmpMeanError(2), modelCode(3), tmpMeanError(3));
%             
%             modelPair = [1, 2; 1,3; 1,2];
%             for whichModelPair = 1:length(modelPair)
%                 [~,P,~,STATS] = ttest(thisSubject.condition{1}.crossVal(modelPair(1)).LogLikelyhood, thisSubject.condition{1}.crossVal(modelPair(2)).LogLikelyhood);
%                 fprintf('%s Vs %s LogLikely: t(%d) = %.2f, p = %.4f, \n', modelCode(whichModelPair(1)), ...
%                     modelCode(whichModelPair(2)), STATS.df, STATS.tstat, P);
%                 [~,P,~,STATS] = ttest(thisSubject.condition{1}.crossVal(whichModelPair(1)).RMSError, ...
%                     thisSubject.condition{1}.crossVal(whichModelPair(2)).RMSError);
%                 fprintf('%s Vs %s RMSE: t(%d) = %.2f, p = %.4f, \n', modelCode(whichModelPair(1)), modelCode(whichModelPair(2)), STATS.df, STATS.tstat, P);
%             end
%         end