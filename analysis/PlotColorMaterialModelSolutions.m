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
        figAndDataDir = [getpref('ColorMaterial', 'analysisDir') '/Experiment1'];
        load([figAndDataDir '/' 'ParamsE1P2FULL.mat'])
    
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        figAndDataDir = [getpref('ColorMaterial', 'analysisDir') '/Pilot'];
        load([figAndDataDir '/' 'pairIndicesPilot.mat'])
        
end
nSubjects = length(subjectList);
nConditions = length(conditionCode);
saveFig = 1;
weibullplots = 0;

% Get experiment paramters and model parameters. 
params = getqPlusPilotExpParams;
params.interpCode = 'Cubic'; 
params.whichDistance = 'euclidean';
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
        temp = load([figAndDataDir '/'   subjectList{s} 'Solution-' num2str(params.whichPositions) '.mat']);  %fljSolution-Cubicfull
        thisSubject = temp.thisSubject; 
        load colorMaterialInterpolateFunCubiceuclidean.mat
        params.F = colorMaterialInterpolatorFunction; % for lookup.
        
        ColorMaterialModelPlotSolution(thisSubject.condition{whichCondition}.pFirstChosen, ...
            thisSubject.condition{whichCondition}.predictedProbabilitiesBasedOnSolution, ...
            thisSubject.condition{whichCondition}.returnedParams,indexMatrix, ...
            params, figAndDataDir, saveFig, weibullplots) 
        
      thisSubject.condition{whichCondition}.returnedParams(end-1)
    end
    if saveFig
        FigureSave([subjectList{s} num2str(params.whichPositions) 'FitNewCorr'],gcf,'pdf');
    end
end