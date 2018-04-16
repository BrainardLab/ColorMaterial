% qPlusImplementColorMaterialModel
% Main script for data analysis of qPlus implementation

% 04/10/2018 ar Wrote it. 

% Initialize
clear; close

% Experiment and Subjects to analyze
subjectList = {'as', 'lma'};
whichExperiment = 'E3';

% Specify directories
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),['/' whichExperiment '/']);
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');
analysisDir  = fullfile(getpref('ColorMaterial', 'analysisDir'),['/' whichExperiment '/']);

% Specify other experimental parameters
nBlocks = 8;
distances = {'euclidean'};

% Load structure that matches the experimental design of
% our initial experiments.
%
% This is stuff like the number of competitors and thier
% nominal positions -- things that are fixed throughout
% a particular experimental subproject.
params = getqPlusPilotExpParams;

params.whichDistance = 'euclidean';
params.interpCode = 'Cubic';

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

% Set up more modeling parameters
% 1) Which position type are we fitting? ('full', 'smoothSpacing'). 
params.whichPositions = 'full';

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
for ss = 1:length(subjectList) 
    for d = 1:length(distances)
            
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
        
        % Concatenate across blocks
        thisSubject.newTrialData = qPlusConcatenateRawData(thisSubject.rawTrialData, indices);
        
        % Convert the information about pairs and outcomes to 'our prefered representation'
        % This is to pass to our non-Quest+ fitting routine, which can find
        % high likelihood solutions than the Quest+ version, possibly
        % because it knows more about stimulus constraints. Also, it can
        % fit the full model.
        %
        % Our routine works in log10 likelihoods, which is why we convert
        % likelihoods above and not here.
        thisSubject.pairColorMatchColorCoords = thisSubject.newTrialData(:,1);
        thisSubject.pairMaterialMatchColorCoords = thisSubject.newTrialData(:,2);
        thisSubject.pairColorMatchMaterialCoords = thisSubject.newTrialData(:,3);
        thisSubject.pairMaterialMatchMaterialCoords = thisSubject.newTrialData(:,4);
        thisSubject.firstChosen = thisSubject.newTrialData(:,5);
        thisSubject.newNTrials = thisSubject.newTrialData(:,6);
        thisSubject.pFirstChosen = thisSubject.firstChosen./thisSubject.newNTrials;
        
        % Implement the model
        [thisSubject.returnedParams, thisSubject.logLikelyFit, thisSubject.predictedProbabilitiesBasedOnSolution] =  FitColorMaterialModelMLDS(thisSubject.pairColorMatchColorCoords, ...
            thisSubject.pairMaterialMatchColorCoords,...
            thisSubject.pairColorMatchMaterialCoords, ...
            thisSubject.pairMaterialMatchMaterialCoords,...
            thisSubject.firstChosen, thisSubject.newNTrials, params);
        
        % Extract parameters
        [thisSubject.returnedMaterialMatchColorCoords, thisSubject.returnedColorMatchMaterialCoords, ...
            thisSubject.returnedW, thisSubject.returnedSigma]  = ColorMaterialModelXToParams(thisSubject.returnedParams, params);
        fprintf('Log 10 likelihood of data given our model parameters: %0.2f\n', thisSubject.logLikelyFit);
        
        params.qpParamsStart = true; 
        [thisSubject.returnedParamsQP, thisSubject.logLikelyFitQP, thisSubject.predictedProbabilitiesBasedOnSolutionQP] =  FitColorMaterialModelMLDS(thisSubject.pairColorMatchColorCoords, ...
            thisSubject.pairMaterialMatchColorCoords,...
            thisSubject.pairColorMatchMaterialCoords, ...
            thisSubject.pairMaterialMatchMaterialCoords,...
            thisSubject.firstChosen, thisSubject.newNTrials, params);
        
        % Could (and probably should) do our code starting at qp params
        % here, and take whichever has the best overall likelihood. Ana
        % wins an ice cream if she implements this and for no cases in our next
        % experiment do the qp parameters lead to a better solution.  Otherwise David
        % wins the ice cream.
        
        % Save the outcome
        subject{ss,d} = thisSubject; 
        cd (analysisDir)
        save([subjectList{ss} distances{d} 'Fit'], 'thisSubject'); clear thisSubject
        
    end
end
