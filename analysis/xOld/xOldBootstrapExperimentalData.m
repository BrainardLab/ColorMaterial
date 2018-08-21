% BootstrapExperimentalData
%
% Run the model on experimental data and implement bootstraping 
% so we can estimate confidence intervals for model paramters. 
%
% 06/19/2017 ar Adapted the code that bootstraps demo data. 

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
codeDir = '/Users/Shared/Matlab/Toolboxes/BrainardLabToolbox/ColorMaterialModel';
analysisDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial'; 
whichExperiment = 'Pilot'; 

% Set paramters for a given expeirment.
switch whichExperiment
    case 'Pilot'
        figAndDataDir = [analysisDir '/' whichExperiment  '/' ];
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        nBlocks = 25;
        pairInfo = load([figAndDataDir 'pairIndicesPilot.mat'])
        load([figAndDataDir  'ParamsPilot.mat'])
    case 'E1P2FULL'
        figAndDataDir = [analysisDir '/Experiment1/'];
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        nBlocks = 24;
        pairInfo = load([figAndDataDir 'pairIndicesE1P2Complete.mat'])
        load([figAndDataDir 'ParamsE1P2FULL.mat'])
end

% Set some parameters for bootstrapping. 
nConditions = length(conditionCode); 
nRepetitions = 1;
nModelTypes = 1; 
showOutcome = 1; 
params.bootstrapMethod = 'perTrialPerBlock'; 

params.CIrange = 95; % confidence interval range. 
params.CIlo = (1-params.CIrange/100)/2;
params.CIhi = 1-params.CIlo;

%% Standard set of parameters we need to define for the model. 
params.whichMethod = 'lookup'; % options: 'lookup', 'simulate' or 'analytic'
params.whichDistance = 'euclidean'; % options: euclidean, cityblock (or any metric enabled by pdist function). 

% For simulate method, set up how many simulations to use for predicting probabilities.  
if strcmp(params.whichMethod, 'simulate')
    params.nSimulate = 1000;
end
% What sort of position fitting are we doing, and if smooth the order of the polynomial.
% Options:
%  'full' - Weights vary
%  'smoothSpacing' - Weights computed according to a polynomial fit.
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1; % this option is only for smoothSpacing
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

%% Run the bootstrapping for each subject and condition 
% Leaving an option to enable different models (although for now we just have one model). 
% To introduce other models, we can redefine some of the parameters here. 
for s = 1%:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']); % data
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    for whichModelType = 1:nModelTypes
        for whichCondition = 1:nConditions
            thisSubject.condition{whichCondition}.bootstrap = ....
                ColorMaterialModelBootstrapData(thisSubject.condition{whichCondition}.firstChosenPerTrial, nBlocks, nRepetitions, pairInfo, params)
            for jj = 1:size(bootstrap.returnedParamsTraining,2)
                thisSubject.condition{whichCondition}.bootstrapMeans(jj) = ...
                    mean(dataSet{nDataSets}.condition{whichCondition}.bootstrap.returnedParamsTraining(:,jj));
                thisSubject.condition{whichCondition}.bootstrapCI(jj,1) = ...
                    prctile(thisSubject.condition{whichCondition}.bootstrap.returnedParamsTraining(:,jj),100*params.CIlo);
                thisSubject.condition{whichCondition}.bootstrapCI(jj,2) = ...
                    prctile(thisSubject.condition{whichCondition}.bootstrap.returnedParamsTraining(:,jj),100*params.CIhi);
            end
        end
    end
    
    %% Show results
    if showOutcome
        fprintf('Subject %s\n', subjectList{s})
        fprintf('Bootstrapped weight %.2f, CI = [%.2f, %.2f] \n', thisSubject.condition{whichCondition}.bootstrapMeans(end-1), thisSubject.condition{whichCondition}.bootstrapCI(end-1, 1), ...
            thisSubject.condition{whichCondition}.bootstrapCI(end-1, 2));
    end
end
% Save in the right folder.
cd(demoDir)
save([subjectName '-BootstrapResults'],  'thisSubject');
cd(codeDir)