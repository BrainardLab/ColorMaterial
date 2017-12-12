% BootstrapExperimentalData
%
% Run the model on experimental data and implement bootstraping 
% so we can estimate confidence intervals for model paramters. 
%
% 06/19/2017 ar Adapted the code that bootstraps demo data. 

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
codeDir = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis';
analysisDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial'; 
whichExperiment = 'Pilot'; 

% Set paramters for a given expeirment.
switch whichExperiment
    case 'Pilot'
        figAndDataDir = [analysisDir '/' whichExperiment  '/' ];
        subjectList = {'flj', 'mcv', 'zhr', 'scd', 'vtr'};
        conditionCode = {'NC'};
        nBlocks = 25;
        load('pilotIndices.mat')
    case 'E1P2FULL'
        figAndDataDir = [analysisDir '/Experiment1/'];
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        nBlocks = 24;
end

% Set some parameters for bootstrapping. 
nConditions = length(conditionCode); 
nModelTypes = 1; 
nSubjects = length(subjectList); 

% addNoise parameter is already a part of the generated data sets. 
% We should not set it again here. Commenting it out. 
% params.addNoise = true; 
%params.maxPositionValue = max(params.F.GridVectors{1});
nRepetitions = 400; 
%% Run the bootstrapping for each subject and condition 
% Leaving an option to enable different models (although for now we just have one model). 
% To introduce other models, we can redefine some of the parameters here.
thisFontSize = 20; 
thisMarkerSize = 16; 
thisLineWidth = 3; 
whichCondition = 1; 
load('/Users/ana/Desktop/ParamsPilot.mat')
for s = 1:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            %   load([figAndDataDir '/' subjectList{s} 'BestSolution' num2str(nRepetitions) '-weightVary-smoothSpacing.mat'])
            load([figAndDataDir '/' subjectList{s} 'BestSolution' num2str(nRepetitions) '-weightVary-full.mat'])
            %   load([figAndDataDir '/' 'C' subjectList{s} 'SolutionNew-weightVary.mat'])
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    indexMatrix.rowIndex = pilotIndices(:,2);  
    indexMatrix.columnIndex = pilotIndices(:,3);
    indexMatrix.overallColorMaterialPairIndices = pilotIndices(:,1);
    indexMatrix.colorMatchFirst = pilotIndices(:,4); 
    subject{s} = thisSubject; clear thisSubject;
    params.subjectName = subjectList{s}; 
    ColorMaterialModelPlotSolution(subject{s}.condition{whichCondition}.pFirstChosen, ...
        subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution, ...
        subject{s}.condition{whichCondition}.returnedParams,...
        indexMatrix, params, figAndDataDir, 0, 0)
end