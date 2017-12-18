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
        subjectList = {'flj', 'zhr', 'mcv', 'scd', 'flj', 'vtr'};
        conditionCode = {'NC'};
        nBlocks = 25;
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
thisMarkerSize = 20; 
thisLineWidth = 3; 
for s = 1%:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SolutionBootstrap' num2str(nRepetitions) '-weightVary-smoothSpacing.mat'])
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    subject{s} = thisSubject; clear thisSubject;
    for whichCondition = 1:length(conditionCode)
        colorMaterialDataProb = subject{s}.condition{whichCondition}.pColorMatchChosen;  
        colorMaterialDataProb(4,4) = 0.5;  
         for i = 1:size(colorMaterialDataProb,2);
            if i == 4
                fixMidPoint = 1;
            else
                fixMidPoint = 0;
            end
            % Plot proportion of color match chosen for different
            % color-diffence steps of the material match.
            [theSmoothPreds(:,i), theSmoothVals(:,i)] = FitColorMaterialModelWeibull(colorMaterialDataProb(:,i)',...
                params.materialMatchColorCoords, fixMidPoint);
        end
        thisFig1 = ColorMaterialModelPlotFit(theSmoothVals, theSmoothPreds, params.colorMatchMaterialCoords, colorMaterialDataProb,...
            'whichMatch', 'colorMatch', 'whichFit', 'weibull', 'fontSize', thisFontSize, ...
            'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
%         if saveFigs
             FigureSave([subjectList{s}, 'WeibullFitColorXAxis3'], thisFig1, 'pdf');
%         end
    end
end