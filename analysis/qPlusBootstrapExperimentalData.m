% BootstrapExperimentalData
%
% Run the model on experimental data and implement bootstraping
% so we can estimate confidence intervals for model paramters.
%
% 06/19/2017 ar Adapted the code that bootstraps demo data.

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';

analysisDir = fullfile(getpref('ColorMaterial', 'analysisDir'), 'E3');
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis'); 

% Exp parameters
% Specify other experimental parameters
subjectList = {'ar', 'dhb'};
conditionCode = {'NC'};
nSubjects = length(subjectList);
nConditions = length(conditionCode);

indices.stimPairs = 1:4; 
indices.response1 = 5; 
indices.nTrials = 6; 

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'smoothSpacing';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1;
end
% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% Set some parameters for bootstrapping.
nRepetitions = 300;
nModelTypes = 2;

params.CIrange = 95; % confidence interval range.
params.CIlo = (1-params.CIrange/100)/2;
params.CIhi = 1-params.CIlo;

%% Run the bootstrapping for each subject and condition
% Leaving an option to enable different models (although for now we just have one model).
% To introduce other models, we can redefine some of the parameters here.
for s = 1:length(subjectList)
    load([analysisDir '/' subjectList{s} 'SummarizedqPlusData.mat']); % data
    
    for whichModelType = 1:nModelTypes
        if whichModelType == 1
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 1;
        elseif whichModelType == 2
            params.whichPositions = 'smoothSpacing';
            params.smoothOrder = 2;
        end
        for c = 1:nConditions
            for whichRep = 1:nRepetitions
                
                % resample the data for this iteration of bootstraping
                clear nTrials id bootstrapData bootstrapDataAggregated
                nTrials = size(thisSubject.condition{c}.rawTrialData,1);
                id = randi(nTrials,[nTrials 1]);
                bootstrapData = thisSubject.condition{c}.rawTrialData(id,:);
                bootstrapDataAggregated = qPlusConcatenateRawData(bootstrapData, indices);
   
                thisSubject.condition{c}.bs(whichRep).bootstrapDataAggregated = bootstrapDataAggregated;
                % Convert the information about pairs to 'our prefered representation'
                clear pairColorMatchColorCoords pairMaterialMatchColorCoords pairColorMatchMaterialCoords pairMaterialMatchMaterialCoords
                pairColorMatchColorCoords = bootstrapDataAggregated(:,1);
                pairMaterialMatchColorCoords = bootstrapDataAggregated(:,3);
                pairColorMatchMaterialCoords = bootstrapDataAggregated(:,2);
                pairMaterialMatchMaterialCoords = bootstrapDataAggregated(:,4);
                
                thisSubject.condition{c}.bs(whichRep).bootstrapDataAggregatedFirstChosen = bootstrapDataAggregated(:,5);
                thisSubject.condition{c}.bs(whichRep).bootstrapDataAggregatednTrials = bootstrapDataAggregated(:,6);
                
                [thisSubject.condition{c}.bs(whichRep).returnedParams, thisSubject.condition{c}.bs(whichRep).logLikelyFit, ...
                    thisSubject.condition{c}.bs(whichRep).predictedProbabilitiesBasedOnSolution] = ...
                    FitColorMaterialModelMLDS(...
                    pairColorMatchColorCoords, ...
                    pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords, ...
                    pairMaterialMatchMaterialCoords,...
                    thisSubject.condition{c}.bs(whichRep).bootstrapDataAggregatedFirstChosen, ...
                    thisSubject.condition{c}.bs(whichRep).bootstrapDataAggregatednTrials,...
                    params);
            end
        end
    end
    % Save in the right folder.
    cd(analysisDir)
    if strcmp(params.whichPositions, 'smoothSpacing')
        save([subjectList{s} '-BootstrapSmoothSpacing' num2str(params.smoothOrder)],  'thisSubject');
    else
        save([subjectList{s} '-BootstrapFull'],  'thisSubject');
    end
    cd(codeDir)
end