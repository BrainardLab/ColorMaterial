% qPlusSaveSubjectFittingParams
% Save the parameters structure for each subject

% 05/30/2018 ar Adapted from qPlusImplementColorMaterialModel..

% Initialize
clear; close all; 

% Set experiment and subjects to analyze
subjectList = {'gfn', 'nkh', 'lma', 'cjz', 'ofv', 'dca', 'lza', 'ckf', 'hmn', 'sel', 'jcd'};
whichExperiment = 'E3';

% Specify directories
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),['/' whichExperiment '/']);
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');
analysisDir  = fullfile(getpref('ColorMaterial', 'analysisDir'),['/' whichExperiment '/']);

% Specify other experimental parameters
nBlocks = 8;
nRepetitions = 100;

best = 0;
for ss = 1:length(subjectList)
    % Load structure that matches the experimental design of
    % our initial experiments.
    %
    % This is stuff like the number of competitors and thier
    % nominal positions -- things that are fixed throughout
    % a particular experimental subproject.
    params = getqPlusPilotExpParams;
    
    params.interpCode = 'Cubic';
   
    switch subjectList{ss}
        case 'gfn'
            if best == 1
                params.whichDistance = 'euclidean';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 3; % cubic
                params.modelCode = 'Cubic';
            else
                params.whichDistance = 'cityblock';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 2; % quadratic
                params.modelCode = 'Quadratic';
            end
            
        case 'nkh'
            if best == 1
                params.whichDistance = 'euclidean';
                params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.modelCode = 'Full';
            else
                params.whichDistance = 'cityblock';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 3; % cubic
                params.modelCode = 'Cubic';
            end
            
        case 'lma'
            if best == 1
                params.whichDistance = 'cityblock';
            else
                params.whichDistance = 'euclidean';
            end
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 2; % quadratic
            params.modelCode = 'Quadratic';
            
        case 'as'
            if best == 1
                params.whichDistance = 'cityblock';
            else
                params.whichDistance = 'euclidean';
            end
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
            
        case 'ofv'
            if best == 1
                params.whichDistance = 'cityblock';
            else
                params.whichDistance = 'euclidean';
            end
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'dca'
            if best == 1
                params.whichDistance = 'cityblock';
                params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.modelCode = 'Full';
            else
                params.whichDistance = 'euclidean';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 2; % quadratic
                params.modelCode = 'Quadratic';
            end
            
        case 'lza'
            if best == 1
                params.whichDistance = 'cityblock';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 2; % quadratic
                params.modelCode = 'Quadratic';
            else
                params.whichDistance = 'euclidean';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 3; % cubic
                params.modelCode = 'Cubic';
            end
            
        case 'ckf'
            if best == 1
                params.whichDistance = 'euclidean';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 3; % cubic
                params.modelCode = 'Cubic';
            else
                params.whichDistance = 'cityblock';
                params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
                params.smoothOrder = 2; % cubic
                params.modelCode = 'Quadratic';
            end
            
        case 'hmn'
            if best == 1
                params.whichDistance = 'euclidean';
            else
                params.whichDistance = 'cityblock';
            end
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'sel'
            if best == 1
                params.whichDistance = 'cityblock';
            else
                params.whichDistance = 'euclidean';
            end
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 2; % quadratic
            params.modelCode = 'Quadratic';
            
        case 'jcd'
            if best == 1
                params.whichDistance = 'cityblock';
            else
                params.whichDistance = 'euclidean';
            end
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 1; % linear
            params.modelCode = 'Linear';
            
            %         case 'as'
            %             if best == 1
            %                 params.whichDistance = 'cityblock';
            %             else
            %                 params.whichDistance = 'euclidean';
            %             end
            %             params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            %             params.smoothOrder = 3; % cubic
            %             params.modelCode = 'Cubic';
    end
    
    
    % Add to the parameters structure parameters that
    % define the modeling we are doing.
    %
    % This is things like grid search parameters and information
    % that defines how we compute likihood in the fitting.
    
    params = getqPlusPilotModelingParams(params);
    
    % Tweak structure so that we can use it with Quest+ routines.
    % This allows us to use Quest+ machinary to get some initial parameters
    % for our search. Quest+ can't handle the full model.
    tempParams = params;
    tempParams.whichPositions = 'smoothSpacing';
    tempParams.smoothOrder = 3;
    
    % Continue setting up the main modeling params.
    % Does material/color weight vary in fit? ('weightVary', 'weightFixed').
    params.whichWeight = 'weightVary';
    
    % Do we start the parameter search from estimated qpParams? (true/false)
    %  If false, we use our rich set of 75 diffent points (takes much longer)
    params.qpParamsStart = false;
    
    % Save
    cd (analysisDir)
    if best
        save([subjectList{ss} 'BestFitParams'], 'params'); clear params
    else
        save([subjectList{ss} 'SecondBestFitParams'], 'params'); clear params
    end
    cd (codeDir)
end