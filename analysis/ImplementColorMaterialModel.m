% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Pilot';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
switch whichExperiment
    case 'E1P2Old'
        % Specify other experimental parameters
        subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 24;
        conditionCode = {'NC', 'CY', 'CB'};
        dataDir = [mainDir '/CNST_data/ColorMaterial/'];
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Experiment1'];
        load(mainDir, 'CNST_analysis/ColorMaterial/Experiment1/pairIndicesE1P2.mat')
        colIndex = [1:49];
        matIndex = colIndex;
        
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 25;
        conditionCode = {'NC'};
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Pilot'];
        dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
        % Load the pair indices.
        load([mainDir 'CNST_analysis/ColorMaterial/Pilot/pairIndicesPilot.mat'])
        colIndex = [ 1     2     6    10    11    12    13    17    21    22    23, ...
            27    31    32    33    61    62    63    76    77    78];
        matIndex =  [34    35    36    37    38    39    43    44    45 , ...
            46    47    51    52    53    54    58    59    60    64    65    69];
        
    case 'E1P2FULL'
        % Specify other experimental parameters
        subjectList = {'mdc','nsk'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 24;
        conditionCode = {'NC', 'CY', 'CB'};
        dataDir = [mainDir '/CNST_data/ColorMaterial/'];
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Experiment1'];
        load([mainDir, 'CNST_analysis/ColorMaterial/Experiment1/pairIndicesE1P2Complete.mat'])
end
nSubjects = length(subjectList);
nConditions = length(conditionCode);

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
% load('ColorMaterialExampleStructure.mat')

% Nominal coordinates
params.materialMatchColorCoords = -3: 1: -1;
params.colorMatchMaterialCoords = -3: 1: -1;

% Set up modeling
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'smoothSpacing';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1;
end

% Initial position spacing values to try.
trySpacingValues = [0.5 1 2 3 4];
params.trySpacingValues = trySpacingValues; 
% Does material/color weight vary in fit? ('weightVary', 'weightFixed'). 
params.whichWeight = 'weightVary';

if strcmp(params.whichWeight, 'weightFixed')
    fixedWValue = [0.1:0.1:0.9];
    nWeigthValues = length(fixedWValue); 
else
    tryWeightValues = [0.5 0.2 0.8];
    nWeigthValues = 1; 
end
params.maxPositionValue = 20; 
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'

% Load lookup table
load colorMaterialInterpolateFunCubiceuclidean.mat
colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
interpCode = 'C';
params.F = colorMaterialInterpolatorFunction; % for lookup.

% For each subject and each condition, run the model and basic plots
for ww = 1:nWeigthValues
    clear subject
    for s = 1:nSubjects
        if strcmp(whichExperiment, 'E1P2FULL')
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']);
        else
            load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']);
        end
        subject{s} = thisSubject; clear thisSubject;
        if strcmp(params.whichWeight, 'weightFixed')
            tryWeightValues = fixedWValue(ww);
        end
        params.tryWeightValues = tryWeightValues;
        
        for whichCondition = 1:nConditions
            nTrials = subject{s}.condition{whichCondition}.totalTrials;
            
            [subject{s}.condition{whichCondition}.returnedParams, subject{s}.condition{whichCondition}.logLikelyFit, ...
                subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution] = ...
                FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
                pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
                subject{s}.condition{whichCondition}.firstChosen , nTrials,...
                params);
            
           
            
            [subject{s}.condition{whichCondition}.returnedMaterialMatchColorCoords, ...
                subject{s}.condition{whichCondition}.returnedColorMatchMaterialCoords, ...
                subject{s}.condition{whichCondition}.returnedW,...
                subject{s}.condition{whichCondition}.returnedSigma]  = ColorMaterialModelXToParams(subject{s}.condition{whichCondition}.returnedParams, params);
            
            % entry % row % column % first or second
            subject{s}.condition{whichCondition}.resizedDataProb = nan(7,7);
            subject{s}.condition{whichCondition}.resizedSolutionProb = nan(7,7);
            for i = 1:size(trackIndices,1)
                entryIndex = trackIndices(i,1);
                if trackIndices(i,end) == 1
                    subject{s}.condition{whichCondition}.resizedDataProb(trackIndices(i,2), trackIndices(i,3)) = ...
                        subject{s}.condition{whichCondition}.pFirstChosen(trackIndices(i,1));
                    subject{s}.condition{whichCondition}.resizedSolutionProb(trackIndices(i,2), trackIndices(i,3)) = ...
                        subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution(trackIndices(i,1));
                elseif trackIndices(i,end) == 2
                    subject{s}.condition{whichCondition}.resizedDataProb(trackIndices(i,2), trackIndices(i,3)) = ...
                        1 - subject{s}.condition{whichCondition}.pFirstChosen(trackIndices(i,1));
                    subject{s}.condition{whichCondition}.resizedSolutionProb(trackIndices(i,2), trackIndices(i,3)) = ...
                        1 - subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution(trackIndices(i,1));
                end
            end
            subject{s}.condition{whichCondition}.rmse= ComputeRealRMSE(subject{s}.condition{whichCondition}.pFirstChosen, ...
                subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution'); 
        end
        thisSubject = subject{s};
        cd (figAndDataDir)
        if strcmp(params.whichWeight, 'weightFixed')
            save([interpCode subjectList{s} 'SolutionNew-' params.whichWeight num2str(tryWeightValues*10)], 'thisSubject'); clear thisSubject
        else
            save([interpCode subjectList{s} 'SolutionOld-' params.whichWeight], 'thisSubject'); clear thisSubject
        end
    end
end
save(['Params' whichExperiment], 'params');