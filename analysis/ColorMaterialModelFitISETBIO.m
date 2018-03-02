% ColorMaterialModelFitISETBIO

% Fits ISETBIO-based simulated data that David provided. 
% Clean version of the fitting code anyone should be able to follow.
% 

% 02/15/2018 ar Adapted it it from the CMMFitDemoData

%% Initialize and set directories and some plotting params.
clear; close all;
filename = 'DataForFitting15_3000_60'; 

% Some plotting params. Save the plots? Include Weibull plots?
plotSolution = 1;
saveFig = 1;
weibullplots = 0;
figDir = pwd; 

% Set experimental parameters. 
params = getqPlusPilotExpParams;

% Set modeling parameters. 
params = getqPlusPilotModelingParams(params); 
params.whichPositions = 'full';
params.whichWeight = 'weightVary';
params.subjectName = 'ISETBIO3000';


% Load and reformat the data 
load([filename '.mat']);
nLevels = params.numberOfMaterialCompetitors; % note that in our implementation these are the same for both color and material
codes = params.materialMatchColorCoords;  % note that in our implementation these are the same for both color and material
[modelFitData, indexMatrix, imageList] = reformatISETBIOData(modelFitData, nLevels, codes); 

% Rename the pairs, so it's clear how the variables are passed
pairColorMatchColorsCoords = modelFitData(:,1); 
pairMaterialMatchColorCoords = modelFitData(:,3); 
pairColorMatchMaterialCoords = modelFitData(:,2); 
pairMaterialMatchMaterialCoords = modelFitData(:,4); 

% Rename the response variables. 
theResponses = modelFitData(:,5);
nTrials = modelFitData(:,6);  
probabilitiesFromSimulatedData =  modelFitData(:,7); 

% Fit the data and extract parameters and other useful things from the solution
[returnedParams, logLikelyFit, predictedProbabilitiesBasedOnSolution] = FitColorMaterialModelMLDS(...
    pairColorMatchColorsCoords, pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
    theResponses,nTrials, params) %#ok<SAGROW>

% Print some diagnostics
fprintf('Returned weight: %0.2f.\n', returnedParams(end-1));
fprintf('Log likelyhood of the solution: %0.2f.\n', logLikelyFit);

% Compute RMSE (root mean square error) for the current solution
% (to get some sense of how we're doing)
rmse = ComputeRealRMSE(probabilitiesFromSimulatedData(:), predictedProbabilitiesBasedOnSolution(:));

% Plot current solution.
if plotSolution
    ColorMaterialModelPlotSolution(probabilitiesFromSimulatedData, predictedProbabilitiesBasedOnSolution, ...
        returnedParams,  indexMatrix, params, figDir, saveFig, weibullplots)
end

% Save current fit
cd(figDir)
switch params.whichPositions
    case 'full'
        save([params.subjectName 'Fit-' params.whichPositions  ' .mat'])
    case 'smoothSpacing'
        save([params.subjectName 'Fit-' params.whichPositions num2str(params.smoothOrder)  ' .mat'])
end
