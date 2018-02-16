% PlotColorMaterialModelSolutions
% For each observer, import the recovered model parameters and plot the model fits to the data 
% and other informative figures. 

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Pilot';
codeDir =  pwd; 
analysisDir = getpref('ColorMaterial', 'analysisDir'); 
switch whichExperiment
    case 'E1P2'
        % Specify other experimental parameters
        subjectList = { 'mdc', 'nsk'};
        %  subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
        conditionCode = {'NC', 'CY', 'CB'};
        figAndDataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1';
        load([figAndDataDir '/' 'ParamsE1P2FULL.mat'])
    
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        figAndDataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Pilot';
        load([figAndDataDir '/' 'pairIndicesPilot.mat'])
        
    case 'E3'
        % Specify other experimental parameters
        subjectList = {'as'};
        conditionCode = {'NC'};
        figAndDataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Pilot';
        load([figAndDataDir '/' 'pairIndicesPilot.mat'])
end
nSubjects = length(subjectList);
nConditions = length(conditionCode);
saveFig = 1;
weibullplots = 0;

% Get experiment paramters and model parameters. 
params = getqPlusPilotExpParams;
params = getqPlusPilotModelingParams(params);

% What sort of position fitting ('full', 'smoothSpacing').
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1;
end

% Does material/color weight vary in fit? ('weightVary', 'weightFixed'). 
params.whichWeight = 'weightVary';

% For each subject
for s = 1:length(subjectList)
    params.subjectName = subjectList{s};
    close all;
    for whichCondition = 1:nConditions
        load([figAndDataDir '/'   subjectList{s} 'SolutionNew-' num2str(params.whichPositions) '.mat'])
       
        load colorMaterialInterpolateFunCubiceuclidean.mat
params.F = colorMaterialInterpolatorFunction; % for lookup.

        ColorMaterialModelPlotSolution(thisSubject.condition{whichCondition}.pFirstChosen, ...
            thisSubject.condition{whichCondition}.predictedProbabilitiesBasedOnSolution, ...
            thisSubject.condition{whichCondition}.returnedParams,indexMatrix, ...
            params, figAndDataDir, saveFig, weibullplots)
    
    end
    if saveFig
    FigureSave([subjectList{s} num2str(params.whichPositions) 'FitNewCorr'],gcf,'pdf');
    end
end