% qPlusPlotBootstrappingData
%
% Plot the results of bootstrapping
%
% 12/16/2017 ar Wrote it. 

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3'];
codeDir  = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis'; 

% Exp parameters
% Specify other experimental parameters
subjectList = { 'as'};

conditionCode = {'NC'};
nSubjects = length(subjectList);
nConditions = length(conditionCode);
modelType = 'smoothSpacing';
if strcmp(modelType, 'smoothSpacing')
    smoothSpacingOrder = 3;
    modelcode = {'Linear', 'Quad', 'Cubic'};  
end

saveFig = 0;
for s = 1:nSubjects
    for whichCondition = 1:length(subjectList)
        % load subject data
        load([analysisDir '/' subjectList{s}, modelType modelcode{smoothSpacingOrder} 'Fit.mat'])
        subject{s} = thisSubject; clear thisSubject
        params.subjectName = subjectList{s};
        
        subject{s}.condition{whichCondition}.pFirstChosen = ...
            subject{s}.condition{whichCondition}.firstChosen./subject{s}.condition{whichCondition}.newNTrials;
        
        qPlusColorMaterialModelPlotSolution(subject{s}.condition{whichCondition}.pFirstChosen, ...
            subject{s}.condition{whichCondition}.predictedProbabilitiesBasedOnSolution, ...
            subject{s}.condition{whichCondition}.returnedParams,...
            params, analysisDir, saveFig)
        
        % rmse is not a good measure, because we have very different trial
        % numbers so the measured vs. predicted probablity representation is distorted
        % this is why we will simply compute log likelihood. 
        if subject{s}.condition{whichCondition}.returnedSigma ~= 1
            error ('Sigma is not equal to 1'); 
        end
        
        % extract 
        
        C1 = subject{s}.condition{whichCondition}.returnedMaterialMatchColorCoords(subject{s}.condition{whichCondition}.pairColorMatchColorCoords+4); 
        C2 = subject{s}.condition{whichCondition}.returnedMaterialMatchColorCoords(subject{s}.condition{whichCondition}.pairMaterialMatchColorCoords+4); 
        M1 = subject{s}.condition{whichCondition}.returnedColorMatchMaterialCoords(subject{s}.condition{whichCondition}.pairColorMatchMaterialCoords+4);
        M2 = subject{s}.condition{whichCondition}.returnedColorMatchMaterialCoords(subject{s}.condition{whichCondition}.pairMaterialMatchMaterialCoords+4);
        
        [logLikely, ~] = ColorMaterialModelComputeLogLikelihood(...
            C1, C2, M1, M2, ...
            subject{s}.condition{whichCondition}.firstChosen, ...
            subject{s}.condition{whichCondition}.newNTrials,...
            params.materialMatchColorCoords(params.targetIndex), ...
            params.colorMatchMaterialCoords(params.targetIndex), ...
            subject{s}.condition{whichCondition}.returnedW,subject{s}.condition{whichCondition}.returnedSigma, ...
            'Fobj', params.F, 'whichMethod', params.whichMethod); 
        
        %subject{s}.condition{whichCondition}.logLikelihood = logLikely; clear logLikely
        
        
        if saveFig
            FigureSave([subjectList{s} num2str(params.whichPositions) 'Fit'],gcf,'pdf');
        end
    end
end


