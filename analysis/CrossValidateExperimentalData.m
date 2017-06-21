% CrossValidatateDemoData
% Perform cross validation on demo data to establish the quality of the model.
%
% We want to be able to compare several instancies of our model using cross
% validation. The main goal is to figure out whether we're overfitting with
% our many parameters. Here we use the simulated demo data to learn more
% about diffferent models by examining the cross validation
%
% 03/17/2017 ar Wrote it.
% 04/30/2017 ar Clean up and comment.
% 06/19/2017 ar Pulled the cross validation function. Commenting and cleanup.  up code. 

% Initialize
clear; close all;

% Load the look up table. Set experiment to analyze.
load colorMaterialInterpolateFunCubiceuclidean.mat
whichExperiment = 'Pilot';
figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/' whichExperiment '/'];

% Set some parameters for cross validation. 
nModelTypes = 3;
printOutcome = 1; 

% Set paramters for a given expeirment.
switch whichExperiment
    case 'Pilot'
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        nBlocks = 25;
        pairInfo = load([figAndDataDir 'pairIndicesPilot.mat']); 
        load([figAndDataDir  'ParamsPilot.mat'])
        nFolds = 5;
        
    case 'E1P2FULL'
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        nBlocks = 24;
        pairInfo = load([figAndDataDir 'pairIndicesE1P2Complete.mat']); 
        load([figAndDataDir 'ParamsE1P2FULL.mat'])
        nFolds = 6;
end

%% Standard set of parameters we need to define for the model. 
params.whichMethod = 'lookup'; % options: 'lookup', 'simulate' or 'analytic'
params.whichDistance = 'euclidean'; % options: euclidean, cityblock (or any metric enabled by pdist function). 

% For simulate method, set up how many simulations to use for predicting probabilities.  
if strcmp(params.whichMethod, 'simulate')
    params.nSimulate = 1000;
end

% Does material/color weight vary in fit?
% Options: 
%  'weightVary' - yes, it does.
%  'weightFixed' - fix weight to specified value in tryWeightValues(1);
params.whichWeight = 'weightVary';

% Initial position spacing values to try.
params.tryColorSpacingValues = [0.5 1 2];
params.tryMaterialSpacingValues = [0.5 1 2];
params.tryWeightValues = [0.2 0.5 0.8];

% addNoise parameter is already a part of the generated data sets. 
% We should not set it again here. Commenting it out. 
% params.addNoise = true; 
params.maxPositionValue = max(params.F.GridVectors{1});

%% Define different models.
% To enable the same partition across condition
% Set cross validation parameters
for s = 1:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']); % data
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    
    for whichModelType = 1:nModelTypes
        if whichModelType == 1
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 1;
            modelCode = 'Linear';
        elseif whichModelType == 2
            % For which model type 2 and 3 - use the spacing values for color and material
            % that are returned by a linear fit as a starting point.
            % Instead the whole list of parameters we have used before.
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 3; % overwrite smooth spacing default.
            modelCode = 'Cubic';
        elseif whichModelType == 3
            params.whichPositions = 'full';
            modelCode = 'Full';
        end
        
        % Run the cross validation for this condition
        % Demo case has just one condition, by default.
        for whichCondition = 1:length(conditionCode)
            [thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelihood, ...
                thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError, ...
                params] = ColorMaterialModelCrossValidation(thisSubject.condition{whichCondition}.firstChosenPerTrial, nBlocks, nFolds, pairInfo, params);
            
            % Compute mean error for both log likelihood and rmse.
            thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood = ...
                mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).LogLikelyhood);
            thisSubject.condition{whichCondition}.crossVal(whichModelType).meanRMSError = ...
                mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
        end
    end
    
    % Save in the right folder.
    cd(figAndDataDir);
    save([subjectList{s} conditionCode{whichCondition} params.whichWeight '-' num2str(nFolds) 'Folds'],  'thisSubject');
    
    %% Print outputs
    if printOutcome
        for i = 1:nModelTypes
            tmpMeanError(i) = mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).meanLogLikelihood);
        end
        fprintf('meanLogLikely: %s  %.4f, %s %.4f, %s %.4f.\n', modelCode(1), tmpMeanError(1), modelCode(2), tmpMeanError(2), modelCode(3), tmpMeanError(3));
        
        for i = 1:nModelTypes
            tmpMeanError(i) = mean(thisSubject.condition{whichCondition}.crossVal(whichModelType).RMSError);
        end
        fprintf('meanRMSE: %s  %.4f, %s %.4f, %s %.4f.\n', modelCode(1), tmpMeanError(1), modelCode(2), tmpMeanError(2), modelCode(3), tmpMeanError(3));
        
        modelPair = [1, 2; 1,3; 1,2];
        for whichModelPair = 1:length(modelPair)
            [~,P,~,STATS] = ttest(thisSubject.condition{1}.crossVal(modelPair(1)).LogLikelyhood, thisSubject.condition{1}.crossVal(modelPair(2)).LogLikelyhood);
            fprintf('%s Vs %s LogLikely: t(%d) = %.2f, p = %.4f, \n', modelCode(whichModelPair(1)), ...
                modelCode(whichModelPair(2)), STATS.df, STATS.tstat, P);
            [~,P,~,STATS] = ttest(thisSubject.condition{1}.crossVal(whichModelPair(1)).RMSError, ...
                thisSubject.condition{1}.crossVal(whichModelPair(2)).RMSError);
            fprintf('%s Vs %s RMSE: t(%d) = %.2f, p = %.4f, \n', modelCode(whichModelPair(1)), modelCode(whichModelPair(2)), STATS.df, STATS.tstat, P);
        end
    end
end