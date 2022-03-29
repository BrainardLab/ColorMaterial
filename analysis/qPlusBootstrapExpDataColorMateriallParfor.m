% qPlusBootstrapExpDataColorMaterial
% Main script for bootstrapping the model parameters with Quest+
% model implementation

% 04/13/2018 ar Adapted it from previous modeling and bootstrapping
%               scripts.
% 03/10/2022 dhb Appended _New to output filename as I'm going to try to
%               rerun to get more bootstrap iterations.

% Initialize
clear; close

% Start timer
tic

SIMULATED = false; 
% Experiment and subjects to analyze
if SIMULATED
        subjectList = { 'gfksim','lzasim','nkhsim'};
else
%     subjectList = {'nzf', 'nkh','dca', 'hmn', ...
%         'ofv', 'gfn', 'ckf', 'lma',...
%         'cjz', 'lza', 'sel', 'jcd'};
    subjectList = {'nzf'};
end

whichExperiment = 'E3';

% Specify directories
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),['/' whichExperiment '/']);
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');
analysisDir  = fullfile(getpref('ColorMaterial', 'analysisDir'),['/' whichExperiment '/']);

% Specify other experimental parameters
nBlocks = 8;
nRepetitions = 1000;

% Load structure that matches the experimental design of
% our initial experiments.
%
% This is stuff like the number of competitors and thier
% nominal positions -- things that are fixed throughout
% a particular experimental subprojeasct.
params = getqPlusPilotExpParams;

params.interpCode = 'Cubic';

% Add to the parameters structure parameters that
% define the modeling we are doing.
%
% This is things like grid search parameters and information
% that defines how we compute likihood in the fitting.
for ss = 1:length(subjectList)
    
    switch subjectList{ss}
        case 'gfn'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
            
        case 'gfksim' 
            params.whichDistance = 'euclidean';
            params.whichPositions = 'smoothSpacing'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.smoothOrder = 3; % cubic
            params.modelCode = 'Cubic';
            
        case 'nkh'
            params.whichDistance = 'euclidean';
            params.whichPositions = 'full'; %1) Which position type are we fitting? ('full', 'smoothSpacing').
            params.modelCode = 'Full';
            
        case 'nkhsim'
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
            
        case 'lzasim'
            params.whichDistance = 'euclidean';
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
            
    end
    params = getqPlusPilotModelingParams(params);
    
    % Tweak structure so that we can use it with Quest+ routines.
    % This allows us to use Quest+ machinary to get some initial parameters
    % for our search. Quest+ can't handle the full model.
    tempParams = params;
    tempParams.whichPositions = 'smoothSpacing';
    tempParams.smoothOrder = 3;
    
    % 2) Does material/color weight vary in fit? ('weightVary', 'weightFixed').
    params.whichWeight = 'weightVary';
    
    % 3) Do we start the parameter search from estimated qpParams? (true/false)
    %  If false, we use our rich set of 75 diffent points (takes much longer)
    params.qpParamsStart = false;
    
    % Set indices for concatinating trial data
    indices.stimPairs = 1:4;
    indices.response1 = 5;
    indices.nTrials = 6;
    
    % Load the same qPlus params as in the experiment.
    eval(['tempqPParams = fullfile(getpref(''ColorMaterial'',''mainCodeDir''),''getQuestParamsExp3'');']);
    lowerLin = 0.5;
    upperLin = 6;
    nLin = 5;
    
    lowerQuad = -0.3;
    upperQuad = -lowerQuad;
    nQuad = 4;
    
    lowerCubic = -0.3;
    upperCubic = -lowerCubic;
    nCubic = 4;
    
    lowerWeight = 0.05;
    upperWeight = 0.95;
    nWeight = 5;
    
    % Load the initialization file.
    warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
    qpInit = load([dataDir, 'initalizedQuestsExp3-09-Apr-2018.mat']);
    warning(warnState);
    
    
    % Set up the quest data structure that updates.
    clear questDataAllTrials;
    questDataAllTrials = qpInit.questData{end};
    questDataAllTrials.noentropy = true;
    
    % Start the counter for concatenating trials.
    n = 0;
    
    % Load and reformat all trials.
    for i = 1:nBlocks
        % Load the data set
        fileName = [subjectList{ss}, '/' subjectList{ss}, '-E3-' num2str(i) '.mat'];
        clear thisTempSet
        warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
        thisTempSet = load([dataDir, fileName]);
        warning(warnState);
        
        % Get few params that do not change across trials/blocks and that we
        % need to compute qPlus likelihoods.
        qpPF = thisTempSet.params.data.qpPF;
        nOutcomes = thisTempSet.params.data.nOutcomes;
        
        for t = 1:length(thisTempSet.params.data.trialData)
            n = n+1;
            % Reformat the data for stimCounts below. Note that we need
            % the (n,1) format so that the struct array will be a
            % column thing, which is what Quest+ needs.
            thisSubject.trialData(n,1).stim = thisTempSet.params.data.trialData(t).stim;
            thisSubject.trialData(n,1).outcome = thisTempSet.params.data.trialData(t).outcome;
            
            % Update the posterior across all trials in the experiment.
            questDataAllTrials = qpUpdate(questDataAllTrials, thisTempSet.params.data.trialData(t).stim, ...
                thisTempSet.params.data.trialData(t).outcome);
            
            % Make a duplicate matrix that works with our experimental
            % code that does concatination.
            thisSubject.rawTrialData(n,:) = [thisSubject.trialData(n,1).stim, thisSubject.trialData(n,1).outcome];
        end
    end
    
    % Compute qPlus estimates and some diagnostics
    clear psiParamsIndex psiParamsQuest psiParamsFit stimCounts
    
    % Get discretized MAP estimate from the combined quest structure we
    % built above.
    stimCounts = qpCounts(qpData(thisSubject.trialData),nOutcomes);
    psiParamsIndex = qpListMaxArg(questDataAllTrials.posterior);
    psiParamsQuest = thisTempSet.params.data.psiParamsDomain(psiParamsIndex,:);
    
    % Do max likelihood fit using the MAP estiamte to start
    psiParamsFit = qpFit(thisSubject.trialData,qpPF,psiParamsQuest(:),nOutcomes,...
        'lowerBounds', [1/upperLin -upperQuad -upperCubic ...
        1/upperLin -upperQuad -upperCubic 0], ...
        'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
    fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
        psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4), ...
        psiParamsFit(5),psiParamsFit(6),psiParamsFit(7));
    fprintf('Log 10 likelihood of data fit max likelihood params: %0.2f\n', ...
        qpLogLikelihood(stimCounts, qpPF, psiParamsFit)/log(10));
    
    % Save maximum likelihood params according to qplus
    [thisSubject.initialParams(1:7), thisSubject.initialParams(8:14), thisSubject.initialParams(15), thisSubject.initialParams(16)] =...
        ColorMaterialModelXToParams([psiParamsFit;1],tempParams);
    params.qpInitialParams = thisSubject.initialParams;
    
    parfor whichRep = 1:nRepetitions
        
        % Resample the data for this iteration of bootstraping
        %clear nTrials id bootstrapData bootstrapDataAggregated
        nTrials{whichRep} = size(thisSubject.rawTrialData,1);
        id{whichRep} = randi(nTrials{whichRep},[nTrials{whichRep} 1]);
        bootstrapData{whichRep} = thisSubject.rawTrialData(id{whichRep},:);
        bootstrapDataAggregated{whichRep} = qPlusConcatenateRawData(bootstrapData{whichRep}, indices);
        bootstrapDataAggregatedFirstChosen{whichRep} = bootstrapDataAggregated{whichRep}(:,5);
        bootstrapDataAggregatednTrials{whichRep} = bootstrapDataAggregated{whichRep}(:,6);
 
        % Do the work in a function
        [returnedParams{whichRep},logLikelyFit{whichRep},predictedProbabilitiesBasedOnSolution{whichRep}] = InnerLoopFun(bootstrapDataAggregated{whichRep},params);
        disp(returnedParams{whichRep}(end-1));
    end

    % Deal bootstraps the way before we wrote the parfor loop.
    for whichRep = 1:nRepetitions
        thisSubject.bs(whichRep).bootstrapDataAggregated{whichRep};
        thisSubject.bs(whichRep).bootstrapDataAggregatedFirstChosen = bootstrapDataAggregatedFirstChosen{whichRep};
        thisSubject.bs(whichRep).bootstrapDataAggregatednTrials = bootstrapDataAggregatednTrials{whichRep};
        thisSubject.bs(whichRep).pFirstChosen = bootstrapDataAggregatedFirstChosen{whichRep}./...
            bootstrapDataAggregatednTrials{whichRep};
        thisSubject.bs(whichRep).returnedParams = returnedParams{whichRep};
        thisSubject.bs(whichRep).logLikelyFit = logLikelyFit{whichRep};
        thisSubject.bs(whichRep).predictedProbabilitiesBasedOnSolution = predictedProbabilitiesBasedOnSolution{whichRep};
    end

    % Save
    cd (analysisDir)
    save([subjectList{ss} params.whichDistance params.modelCode 'BootstrapFit_New'], 'thisSubject'); clear thisSubject
    cd (codeDir)
end

% Report timer
toc

function [returnedParams,logLikelyFit,predictedProbabilitiesBasedOnSolution] = InnerLoopFun(bootstrapDataAggregated,params)

% Convert the information about pairs to 'our prefered representation'
pairColorMatchColorCoords = bootstrapDataAggregated(:,1);
pairMaterialMatchColorCoords = bootstrapDataAggregated(:,2);
pairColorMatchMaterialCoords = bootstrapDataAggregated(:,3);
pairMaterialMatchMaterialCoords = bootstrapDataAggregated(:,4);
firstChosen = bootstrapDataAggregated(:,5);
nTrials = bootstrapDataAggregated(:,6);

[returnedParams, logLikelyFit, ...
    predictedProbabilitiesBasedOnSolution] = ...
    FitColorMaterialModelMLDS(...
    pairColorMatchColorCoords, ...
    pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords, ...
    pairMaterialMatchMaterialCoords,...
    firstChosen, ...
    nTrials,...
    params);

end

