% qPlusBootstrapExpDataInitialParsms
% Repeat the bootstrapping, but initialize with the best fitting params from the
% best model rather than our grid of variable parameters. 
%
% 06/01/2018 ar Adapted it from previous modeling and bootstrapping
%               scripts.

% Initialize
clear; close;

SIMULATED = false;
% Set experiment and subjects to analyze
if SIMULATED
    subjectList = {'gfksim','lzasim','nkhsim'};
    subjectModels = {'gfksimeuclideanCubic','lzasimeuclideanQuadratic','nkhsimeuclideanFull'};
    
else
    subjectList = {'cjz', 'hmn', 'nkh', 'dca', 'ofv', 'gfn', 'ckf', 'lma',  'sel', 'jcd', 'lza'};
    subjectModels = {'cjzcityblockCubic', 'hmneuclideanFull', 'nkheuclideanFull', 'dcacityblockFull', 'ofvcityblockFull', 'gfneuclideanCubic', 'ckfeuclideanCubic'...
        'lmacityblockQuadratic',  'selcityblockQuadratic', 'jcdcityblockLinear', 'lzacityblockQuadratic'};
end
whichExperiment = 'E3';

% Specify directories
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),['/' whichExperiment '/']);
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');
analysisDir  = fullfile(getpref('ColorMaterial', 'analysisDir'),['/' whichExperiment '/']);

% Specify other experimental parameters
nBlocks = 8;
nRepetitions = 100;

% Set indices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;

for s = 1:length(subjectList)
    
% set up modeling parameters for each subject
    clear params
    % Load structure that matches the experimental design of
    % our initial experiments.
    %
    % This is stuff like the number of competitors and thier
    % nominal positions -- things that are fixed throughout
    % a particular experimental subproject.
    params = getqPlusPilotExpParams;
    params.interpCode = 'Cubic';
    
    switch subjectList{s}
        case 'gfn'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
            
        case 'nkh'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'lma'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 2; % quadratic
            params.modelCode = 'Quadratic';
            
        case 'cjz'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
            
        case 'ofv'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'dca'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'lza'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 2; % quadratic
            params.modelCode = 'Quadratic';
            
        case 'ckf'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
            
        case 'hmn'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'sel'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 2; % quadratic
            params.modelCode = 'Quadratic';
            
        case 'jcd'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 1; % linear
            params.modelCode = 'Linear';
            
        case 'gfksim'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
        case 'nkhsim'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
        case 'lzasim'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 2; % quadratic
            params.modelCode = 'Quadratic';
            
    end

    % Add to the parameters structure parameters that
    % define the modeling we are doing.
    %
    % This is things like grid search parameters and information
    % that defines how we compute likihood in the fitting.
    
    params = getqPlusPilotModelingParams(params);
    
    % Continue setting up the main modeling params. 
    % Does material/color weight vary in fit? ('weightVary', 'weightFixed').
    params.whichWeight = 'weightVary';
    
    % Do we start the parameter search from estimated qpParams? (true/false)
    %  If false, we use our rich set of 75 diffent points (takes much longer)
    params.qpParamsStart = true;
    
    % Load subject data and extract initial parameters
    tempSubjFit =  load([analysisDir '/' subjectModels{s}, 'Fit.mat']); 
    params.qpInitialParams = tempSubjFit.thisSubject.returnedParams;
    
    clear tempSubjFit

    % Load subject bootstrap data
    clear thisSubject
    load([analysisDir '/' subjectModels{s}, 'BootstrapFit_New.mat'])

    for whichRep = 1:nRepetitions
        
        % Convert the information about pairs to 'our prefered representation'
        clear pairColorMatchColorCoords pairMaterialMatchColorCoords pairColorMatchMaterialCoords pairMaterialMatchMaterialCoords
        pairColorMatchColorCoords = thisSubject.bs(whichRep).bootstrapDataAggregated{whichRep}(:,1);
        pairMaterialMatchColorCoords = thisSubject.bs(whichRep).bootstrapDataAggregated{whichRep}(:,2);
        pairColorMatchMaterialCoords = thisSubject.bs(whichRep).bootstrapDataAggregated{whichRep}(:,3);
        pairMaterialMatchMaterialCoords = thisSubject.bs(whichRep).bootstrapDataAggregated{whichRep}(:,4);
        
        [thisSubject.bs(whichRep).newReturnedParams, thisSubject.bs(whichRep).newLogLikelyFit, ...
            thisSubject.bs(whichRep).newPredictedProbabilitiesBasedOnSolution] = ...
            FitColorMaterialModelMLDS(...
            pairColorMatchColorCoords, ...
            pairMaterialMatchColorCoords,...
            pairColorMatchMaterialCoords, ...
            pairMaterialMatchMaterialCoords,...
            thisSubject.bs(whichRep).bootstrapDataAggregatedFirstChosen, ...
            thisSubject.bs(whichRep).bootstrapDataAggregatednTrials,...
            params);
           disp(thisSubject.bs(whichRep).newReturnedParams(end-1))
    end
    % Save
    cd (analysisDir)
    % this 
    save([subjectList{s} params.whichDistance params.modelCode 'BootstrapBestParamsFit_New'], 'thisSubject'); clear thisSubject
    cd (codeDir)
end