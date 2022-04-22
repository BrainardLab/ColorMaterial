% qPlusBootstrapExpDataInitialParsms
% Repeat the bootstrapping, but initialize with the best fitting params from the
% best model rather than our grid of variable parameters. 
%
% 06/01/2018 ar Adapted it from previous modeling and bootstrapping
%               scripts.

% Initialize
clear; close

% Start timing
tic;

SIMULATED = false;
% Set experiment and subjects to analyze
if SIMULATED
    subjectList = {'gfksim','lzasim','nkhsim'};
    subjectModels = {'gfksimeuclideanCubic','lzasimeuclideanQuadratic','nkhsimeuclideanFull'};
    
else
%     subjectList = {'cjz', 'hmn', 'nkh', 'dca', 'ofv', 'gfn', 'ckf', 'lma',  'sel', 'jcd', 'lza' 'nzf'};
%     subjectModels = {'cjzcityblockCubic', 'hmneuclideanFull', 'nkheuclideanFull', 'dcacityblockFull', 'ofvcityblockFull', 'gfneuclideanCubic', 'ckfeuclideanCubic'...
%         'lmacityblockQuadratic',  'selcityblockQuadratic', 'jcdcityblockLinear', 'lzacityblockQuadratic', 'nzfcityblockFull'};

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
nRepetitions = 1000;

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

        case 'nzf'
            params.whichDistance = 'cityblock';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
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

    % Do bootstraps in parfor
    parfor whichRep = 1:nRepetitions
        [newReturnedParams{whichRep},newLogLikelyFit{whichRep},newPredictedProbabilitiesBasedOnSolution{whichRep}] = InnerLoopFun(whichRep,thisSubject,params);
        disp(newReturnedParams{whichRep}(end-1));
    end

    % Deal bootstraps the way before we wrote the parfor loop.
    for whichRep = 1:nRepetitions
        thisSubject.bs(whichRep).newReturnedParams = newReturnedParams{whichRep};
        thisSubject.bs(whichRep).newLogLikelyFit = newLogLikelyFit{whichRep};
        thisSubject.bs(whichRep).newPredictedProbabilitiesBasedOnSolution = newPredictedProbabilitiesBasedOnSolution{whichRep};
    end
    
    % Save
    cd (analysisDir)
    save([subjectList{s} params.whichDistance params.modelCode 'BootstrapBestParamsFit_New'], 'thisSubject'); clear thisSubject
    cd (codeDir)
end

% Finish timing
toc

function [returnedParams,logLikelyFit,predictedProbabilitiesBasedOnSolution] = InnerLoopFun(i,thisSubject,params)

% Convert the information about pairs to 'our prefered representation'
bs = thisSubject.bs(i);
pairColorMatchColorCoords = bs.bootstrapDataAggregated(:,1);
pairMaterialMatchColorCoords = bs.bootstrapDataAggregated(:,2);
pairColorMatchMaterialCoords = bs.bootstrapDataAggregated(:,3);
pairMaterialMatchMaterialCoords = bs.bootstrapDataAggregated(:,4);

[returnedParams, logLikelyFit, ...
    predictedProbabilitiesBasedOnSolution] = ...
    FitColorMaterialModelMLDS(...
    pairColorMatchColorCoords, ...
    pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, ...
    pairMaterialMatchMaterialCoords,...
    bs.bootstrapDataAggregatedFirstChosen, ...
    bs.bootstrapDataAggregatednTrials,...
    params);

end