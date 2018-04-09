% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'E3';
analysisDir = fullfile(getpref('ColorMaterial', 'analysisDir'), 'E3');
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis'); 
dataDir = getpref('ColorMaterial', 'dataFolder');

% Exp parameters
% Specify other experimental parameters
subjectList = {'test'};
conditionCode = {'NC'};
nSubjects = length(subjectList);
nConditions = length(conditionCode); 

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;
params.whichDistance = 'euclidean';
params.interpCode = 'Cubic'; 

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);
tempParams = params; 
tempParams.whichPositions = 'smoothSpacing'; 
tempParams.smoothOrder = 3; 

nBlocks = 8;

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 3;
    params.code = {'Linear', 'Quad', 'Cubic'};
end
% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;
whichExperiment = 'E3'; 

% For each subject and each condition, run the model and basic plots
for s = 1:nSubjects
    for c = 1:nConditions
        subject{s}.condition{c}.trialData = [];
        for b  = 1:nBlocks(s)
            warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
            tempSubj = load([dataDir '/' whichExperiment '/' subjectList{s} '/' subjectList{s}  '-'  whichExperiment  '-' num2str(b) '.mat']);
            warning(warnState);
            for t = 1:length(tempSubj.params.data.trialData)
                subject{s}.condition{c}.trialData = [subject{s}.condition{c}.trialData; ...
                    tempSubj.params.data.trialData(t).stim, tempSubj.params.data.trialData(t).outcome];
            end
            clear tempSubj
        end
        
        
        % Concatenate across blocks
        subject{s}.condition{c}.rawTrialData = subject{s}.condition{c}.trialData;
        subject{s}.condition{c}.newTrialData = qPlusConcatenateRawData(subject{s}.condition{c}.rawTrialData, indices);
        
        % Convert the information about pairs to 'our prefered representation'
        subject{s}.condition{c}.pairColorMatchColorCoords = subject{s}.condition{c}.newTrialData(:,1);
        subject{s}.condition{c}.pairMaterialMatchColorCoords = subject{s}.condition{c}.newTrialData(:,2);
        subject{s}.condition{c}.pairColorMatchMaterialCoords = subject{s}.condition{c}.newTrialData(:,3);
        subject{s}.condition{c}.pairMaterialMatchMaterialCoords = subject{s}.condition{c}.newTrialData(:,4);
        subject{s}.condition{c}.firstChosen = subject{s}.condition{c}.newTrialData(:,5);
        subject{s}.condition{c}.newNTrials = subject{s}.condition{c}.newTrialData(:,6);
        subject{s}.condition{c}.pFirstChosen = subject{s}.condition{c}.firstChosen./subject{s}.condition{c}.newNTrials;
        
    % Implement the model, for each condition. 
    params.qpParamsStart = false; 
            params.qpInitialParams = NaN;
           
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