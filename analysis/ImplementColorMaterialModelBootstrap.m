% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Pilot';
mainDir = '/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/';
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
nRepetitions = 150;

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);
params.bootstrapMethod = 'perTrialPerBlock';

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';
% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

if strcmp(params.whichPositions, 'smoothSpacing')
        params.smoothOrder = 1;
        params.smoothOrderCode = 'Lin';
end

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
    if strcmp(params.whichPositions, 'full')
        save([subjectList{s} 'BootstrapCubic' num2str(nRepetitions) '-' params.whichPositions ], 'thisSubject'); clear thisSubject
    else
    save([subjectList{s} 'BootstrapCubic' num2str(nRepetitions) '-' params.whichPositions params.smoothOrderCode], 'thisSubject', 'params'); clear thisSubject
    end
end
