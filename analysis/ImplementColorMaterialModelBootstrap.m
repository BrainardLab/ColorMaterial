% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Pilot';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
codeDir = '/Users/ana/Documents/MATLAB/toolboxes/BrainardLabToolbox/ColorMaterialModel'; 
switch whichExperiment
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 25;
        conditionCode = {'NC'};
        figAndDataDir = [mainDir, 'CNST_analysis/ColorMaterial/Pilot'];
        dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/';
        % Load the pair indices.
        pairInfo = load([mainDir 'CNST_analysis/ColorMaterial/Pilot/pairIndicesPilot.mat']);
        
    case 'E1P2FULL'% Specify other experimental parameters
        subjectList = {'mdc', 'nsk'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 24;
        conditionCode = {'NC', 'CY', 'CB'};
        dataDir = [mainDir 'CNST_data/ColorMaterial/'];
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Experiment1/'];
        pairInfo = load([mainDir, 'CNST_analysis/ColorMaterial/Experiment1/pairIndicesE1P2Complete.mat']);
end
nSubjects = length(subjectList);
nConditions = length(conditionCode);
nRepetitions = 1;

%% Set up main params
params.targetIndex = 4;
params.competitorsRangePositive = [1 3];
params.competitorsRangeNegative = [-3 -1];
params.targetMaterialCoord = 0;
params.targetColorCoord = 0;
params.sigma = 1;
params.sigmaFactor = 4;

params.targetPosition = 0;
params.targetIndexColor =  11; % target position on the color dimension in the set of all paramters.
params.targetIndexMaterial = 4; % target position on the material dimension in the set of all paramters.

params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.numberOfMaterialCompetitors = length(params.colorMatchMaterialCoords);
params.numberOfColorCompetitors = length(params.materialMatchColorCoords);
params.numberOfCompetitorsPositive = length(params.competitorsRangePositive(1):params.competitorsRangePositive(end));
params.numberOfCompetitorsNegative = length(params.competitorsRangeNegative(1):params.competitorsRangeNegative(end));

%%
% Set up modeling
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'smoothSpacing'; %'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1;
end
params.bootstrapMethod = 'perTrialPerBlock';
% Initial position spacing values and weight values to try.
params.tryMaterialSpacingValues = [0.5 1 2 3 4];
params.tryColorSpacingValues = params.tryMaterialSpacingValues;
params.tryWeightValues = [0.5 0.2 0.8];

% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% what did we do here? do we need these
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'

% Load lookup table
load colorMaterialInterpolateFunCubiceuclidean.mat
params.F = colorMaterialInterpolatorFunction;
params.maxPositionValue = max(params.F.GridVectors{1});

% For each subject and each condition, run the model and basic plots
for s = 1:nSubjects
    if strcmp(whichExperiment, 'E1P2FULL')
        load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']);
    else
        load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']);
    end
    subject{s} = thisSubject; clear thisSubject;
    
    for whichCondition = 1:nConditions
        nTrials = subject{s}.condition{whichCondition}.totalTrials;
        subject{s}.condition{whichCondition}.bootstrapStructure = ...
            ColorMaterialModelBootstrapData(subject{s}.condition{whichCondition}.firstChosenPerTrial,...
            nBlocks, nRepetitions, pairInfo, params);
    end
    thisSubject = subject{s};
    cd (figAndDataDir)
    if strcmp(params.whichWeight, 'weightFixed')
        save([subjectList{s} 'SolutionBS' num2str(nRepetitions) '-' params.whichWeight '-' num2str(tryWeightValues*10) '-' params.whichPositions], 'thisSubject', 'params'); clear thisSubject
    else
        save([subjectList{s} 'SolutionBS' num2str(nRepetitions) '-' params.whichWeight '-' params.whichPositions], 'thisSubject', 'params'); clear thisSubject
    end
end