% qPlusDemoFitColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Demo';
demoDir = fullfile( getpref('ColorMaterial', 'demoDataDir'));
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis');

% Exp parameters
% Specify other experimental parameters
nSets = 4;
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

% Set up more modeling parameters
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';

% Does material/color weight vary in fit? ('weightVary', 'weightFixed').
params.whichWeight = 'weightVary';

% setIndices for concatinating trial data
indices.stimPairs = 1:4;
indices.response1 = 5;
indices.nTrials = 6;

for ss = 1 % we can modigy this is we have sets with different position spacings. 
    for d = 1%:length(distances)
        for i = 1:nSets
            % Load the data set
            fileName = ['testQuest' num2str(i)]; 
            warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
            thisTempSet = load([fullfile(demoDir, fileName)]);
            warning(warnState);
            thisSet.trialData = [];
            for t = 1:length(thisTempSet.questDataAllTrials.trialData)
                thisSet.trialData = [thisSet.trialData; ...
                    thisTempSet.questDataAllTrials.trialData(t).stim, thisTempSet.questDataAllTrials.trialData(t).outcome];
            end
            % Print some diagnostics
            psiParamsIndex = qpListMaxArg(thisTempSet.questDataAllTrials.posterior);
            psiParamsQuest = thisTempSet.questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
            fprintf('Simulated parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
                thisTempSet.simulatedPsiParams(1),thisTempSet.simulatedPsiParams(2),thisTempSet.simulatedPsiParams(3),thisTempSet.simulatedPsiParams(4), ...
                thisTempSet.simulatedPsiParams(5),thisTempSet.simulatedPsiParams(6),thisTempSet.simulatedPsiParams(7));
            fprintf('Log 10 likelihood of data given simulated params: %0.2f\n', ...
                qpLogLikelihood(thisTempSet.stimCounts,thisTempSet.questDataAllTrials.qpPF,thisTempSet.simulatedPsiParams)/log(10));
            fprintf('Max posterior QUEST+ parameters: %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f, %0.2f\n', ...
                psiParamsQuest(1),psiParamsQuest(2),psiParamsQuest(3),psiParamsQuest(4), ...
                psiParamsQuest(5),psiParamsQuest(6),psiParamsQuest(7));
            fprintf('Log 10 likelihood of data quest''s max posterior params: %0.2f\n', ...
                qpLogLikelihood(thisTempSet.stimCounts,thisTempSet.questDataAllTrials.qpPF, psiParamsQuest)/log(10));
            
            clear thisTempSet;
            
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
