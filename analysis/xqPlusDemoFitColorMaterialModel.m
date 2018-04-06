% qPlusDemoFitColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Demo';
demoDir = fullfile( getpref('ColorMaterial', 'demoDataDir'));
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');

% Exp parameters
% Specify other experimental parameters
nSets = 5;
distances = {'euclidean', 'cityblock'};
positionSmoothSpacing = 3;
positionCode = {'Linear', 'Quad', 'Cubic'};

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

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';

% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% setIndices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;
simulatedPsiParams = [3 0 0 2 0 0 0.2];


lowerLin = 1;
upperLin = 6;
lowerQuad = -0.3;
upperQuad = -lowerQuad;
lowerCubic = -0.3;
upperCubic = -lowerCubic;
lowerWeight = 0.05;
upperWeight = 0.95;
nLin = 5;
nQuad = 4;
nCubic = 4;
nWeight = 5;



for ss = 1 % we can modigy this is we have sets with different position spacings. 
    for d = 1%:length(distances)
        for i = 1:nSets
            % Load the data set
            fileName = fullfile(tempdir,'qpQuestPlusColorMaterialCubicModelDemo'); 
            warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
            thisTempSet = load([fullfile(fileName)]);
            warning(warnState);
            thisSet.trialData = [];
            for t = 1:length(thisTempSet.questDataAllTrials.trialData)
                thisSet.trialData = [thisSet.trialData; ...
                    thisTempSet.questDataAllTrials.trialData(t).stim, thisTempSet.questDataAllTrials.trialData(t).outcome];
            end
            % Print some diagnostics
            clear psiParamsIndex psiParamsQuest
            stimCounts = qpCounts(qpData(thisTempSet.questDataAllTrials.trialData),thisTempSet.questDataAllTrials.nOutcomes);

            psiParamsIndex = qpListMaxArg(thisTempSet.questDataAllTrials.posterior);
            psiParamsQuest = thisTempSet.questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
            fprintf('Simulated parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
                simulatedPsiParams(1),simulatedPsiParams(2),simulatedPsiParams(3),simulatedPsiParams(4), ...
                simulatedPsiParams(5),simulatedPsiParams(6),simulatedPsiParams(7));
            fprintf('Log 10 likelihood of data given simulated params: %0.2f\n', ...
                qpLogLikelihood(stimCounts,thisTempSet.questDataAllTrials.qpPF,simulatedPsiParams)/log(10));
            fprintf('Max posterior QUEST+ parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
                psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4), ...
                psiParamsQuest(5),psiParamsQuest(6),psiParamsQuest(7));
            fprintf('Log 10 likelihood of data quest''s max posterior params: %0.2f\n', ...
                qpLogLikelihood(stimCounts,thisTempSet.questDataAllTrials.qpPF, psiParamsQuest)/log(10));
            % Maximum likelihood fit.  Use psiParams from QUEST+ as the starting
            % parameter for the search, and impose as parameter bounds the range
            % provided to QUEST+.
            clear psiParamsFit
            psiParamsFit = qpFit(thisTempSet.questDataAllTrials.trialData,thisTempSet.questDataAllTrials.qpPF,psiParamsQuest(:),thisTempSet.questDataAllTrials.nOutcomes,...
                'lowerBounds', [1/upperLin -upperQuad -upperCubic ...
                1/upperLin -upperQuad -upperCubic 0], ...
                'upperBounds',[upperLin upperQuad upperCubic upperLin upperQuad upperCubic 1]);
            fprintf('Maximum likelihood fit parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
                psiParamsFit(1),psiParamsFit(2),psiParamsFit(3),psiParamsFit(4), ...
                psiParamsFit(5),psiParamsFit(6),psiParamsFit(7));
            fprintf('Log 10 likelihood of data fit max likelihood params: %0.2f\n', ...
                qpLogLikelihood(stimCounts,thisTempSet.questDataAllTrials.qpPF, psiParamsFit)/log(10));
            clear thisTempSet;
            [thisSet.initialParams(1:7), thisSet.initialParams(8:14), thisSet.initialParams(15), thisSet.initialParams(16) ]= ColorMaterialModelXToParams([psiParamsFit;1],tempParams);
            % Concatenate across blocks
            thisSet.rawTrialData = thisSet.trialData;
            thisSet.newTrialData = qPlusConcatenateRawData(thisSet.rawTrialData, indices);
            
            % Convert the information about pairs to 'our prefered representation'
            thisSet.pairColorMatchColorCoords = thisSet.newTrialData(:,1);
            thisSet.pairMaterialMatchColorCoords = thisSet.newTrialData(:,2);
            thisSet.pairColorMatchMaterialCoords = thisSet.newTrialData(:,3);
            thisSet.pairMaterialMatchMaterialCoords = thisSet.newTrialData(:,4);
            thisSet.firstChosen = thisSet.newTrialData(:,5);
            thisSet.newNTrials = thisSet.newTrialData(:,6);
            thisSet.pFirstChosen = thisSet.firstChosen./thisSet.newNTrials;
            
            % Implement the model
            params.qpParamsStart = true; 
            params.qpInitialParams = thisSet.initialParams;
            [thisSet.returnedParams, thisSet.logLikelyFit, thisSet.predictedProbabilitiesBasedOnSolution] =  FitColorMaterialModelMLDS(thisSet.pairColorMatchColorCoords, ...
                thisSet.pairMaterialMatchColorCoords,...
                thisSet.pairColorMatchMaterialCoords, ...
                thisSet.pairMaterialMatchMaterialCoords,...
                thisSet.firstChosen, thisSet.newNTrials, params);
            
            % Extract parameters
            [thisSet.returnedMaterialMatchColorCoords, thisSet.returnedColorMatchMaterialCoords, ...
                thisSet.returnedW, thisSet.returnedSigma]  = ColorMaterialModelXToParams(thisSet.returnedParams, params);
            fprintf('Log likelihood of data given our model parameters: %0.2f\n', thisSet.logLikelyFit);
           
            % Save
            cd (demoDir)
            save([fileName 'Fit'], 'thisSet'); clear thisSet
            cd (codeDir)
        end
    end
end
