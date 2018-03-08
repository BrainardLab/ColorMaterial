% ImplementColorMaterialModel

% Initialize
clear; close all;
% global iterationX
% iterationX = 0; 
% Specify basic experiment parameters
whichExperiment = 'Pilot';
mainDir = '/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/';
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
%         subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
          subjectList = {'zhr'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 25;
        conditionCode = {'NC'};
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Pilot'];
        %dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
        % Load the pair indices.
        load([mainDir 'CNST_analysis/ColorMaterial/Pilot/pairIndicesPilot.mat'])
 
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

params = getqPlusPilotExpParams; 
params = getqPlusPilotModelingParams(params);

% What sort of position fitting ('full', 'smoothSpacing').
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1;
end

% Does material/color weight vary in fit? ('weightVary', 'weightFixed'). 
params.whichWeight = 'weightVary';


% For each subject and each condition, run the model and basic plots

clear subject
for s = 1:nSubjects
    if strcmp(whichExperiment, 'E1P2FULL')
        load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']);
    else
        load([figAndDataDir '/' subjectList{s} 'SummarizedData.mat']);
    end
    subject{s} = thisSubject; clear thisSubject;
   
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
        
%         % entry % row % column % first or second
%         subject{s}.condition{whichCondition}.resizedDataProb = nan(7,7);
%         subject{s}.condition{whichCondition}.resizedSolutionProb = nan(7,7);
%         for i = 1:size(trackIndices,1)
%             entryIndex = trackIndices(i,1);
%             if trackIndices(i,end) == 1
%                 subject{s}.condition{whichCondition}.resizedDataProb(indexMatrix.rowIndex, indexMatrix.columnIndex) = ...
%                     subject{s}.condition{whichCondition}.pFirstChosen(trackIndices(i,1));
%                 subject{s}.condition{whichCondition}.resizedSolutionProb(trackIndices(i,2), trackIndices(i,3)) = ...
%                     subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution(trackIndices(i,1));
%             elseif trackIndices(i,end) == 2
%                 subject{s}.condition{whichCondition}.resizedDataProb(indexMatrix.rowIndex, indexMatrix.columnIndex) = ...
%                     1 - subject{s}.condition{whichCondition}.pFirstChosen(trackIndices(i,1));
%                 subject{s}.condition{whichCondition}.resizedSolutionProb(trackIndices(i,2), trackIndices(i,3)) = ...
%                     1 - subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution(trackIndices(i,1));
%             end
%         end
%         subject{s}.condition{whichCondition}.rmse = ComputeRealRMSE(subject{s}.condition{whichCondition}.pFirstChosen, ...
%             subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution');
    end
    thisSubject = subject{s};
    cd (figAndDataDir)
    if strcmp(params.whichPositions, 'full')
        save([ subjectList{s} 'Solution-' params.interpCode params.whichPositions], 'thisSubject', 'params'); clear thisSubject
    else
        save([ subjectList{s} 'Solution-' params.interpCode params.whichPositions  num2str(params.smoothOrder)], 'thisSubject', 'params'); clear thisSubject
    end
end