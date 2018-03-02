% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'E3';
analysisDir = fullfile(getpref('ColorMaterial', 'analysisDir'), 'E3');
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis'); 

% Exp parameters
% Specify other experimental parameters
subjectList = {'as'};
conditionCode = {'NC'};
nSubjects = length(subjectList);
nConditions = length(conditionCode); 

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 3;
    params.code = {'Linear', 'Quad', 'Cubic'};
end
% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% For each subject and each condition, run the model and basic plots
for s = 1:nSubjects
    
    load([analysisDir '/' subjectList{s} 'SummarizedqPlusData.mat']);
    subject{s} = thisSubject; clear thisSubject; 
    
    % Implement the model, for each condition. 
    for c = 1:nConditions
        [subject{s}.condition{c}.returnedParams, subject{s}.condition{c}.logLikelyFit, ...
            subject{s}.condition{c}.predictedProbabilitiesBasedOnSolution] = ...
            FitColorMaterialModelMLDS(subject{s}.condition{c}.pairColorMatchColorCoords, ...
            subject{s}.condition{c}.pairMaterialMatchColorCoords,...
            subject{s}.condition{c}.pairColorMatchMaterialCoords, ...
            subject{s}.condition{c}.pairMaterialMatchMaterialCoords,...
            subject{s}.condition{c}.firstChosen , subject{s}.condition{c}.newNTrials,...
            params);
        [subject{s}.condition{c}.returnedMaterialMatchColorCoords, ...
            subject{s}.condition{c}.returnedColorMatchMaterialCoords, ...
            subject{s}.condition{c}.returnedW,...
            subject{s}.condition{c}.returnedSigma]  = ColorMaterialModelXToParams(subject{s}.condition{c}.returnedParams, params);
    end
    
    thisSubject = subject{s};
    cd (analysisDir)
    if strcmp(params.whichPositions, 'full')
        save([subjectList{s} params.whichPositions,  'Fit'], 'thisSubject', 'params'); clear thisSubject
    elseif strcmp(params.whichPositions, 'smoothSpacing')
        save([subjectList{s} params.whichPositions,  params.code{params.smoothOrder} 'Fit'], 'thisSubject', 'params'); clear thisSubject
    end
end