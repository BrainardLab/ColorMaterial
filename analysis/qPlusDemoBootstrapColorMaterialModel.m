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
params.qpParamsStart = true;
nRepetitions = 300;
            
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
            clear psiParamsIndex psiParamsQuest
            psiParamsIndex = qpListMaxArg(thisTempSet.questDataAllTrials.posterior);
            psiParamsQuest = thisTempSet.questDataAllTrials.psiParamsDomain(psiParamsIndex,:);
            psiParamsFit = qpFit(thisTempSet.questDataAllTrials.trialData,thisTempSet.questDataAllTrials.qpPF,psiParamsQuest(:),thisTempSet.questDataAllTrials.nOutcomes,...
                'lowerBounds', [1/thisTempSet.upperLin -thisTempSet.upperQuad -thisTempSet.upperCubic ...
                1/thisTempSet.upperLin -thisTempSet.upperQuad -thisTempSet.upperCubic 0], ...
                'upperBounds',[thisTempSet.upperLin thisTempSet.upperQuad thisTempSet.upperCubic thisTempSet.upperLin thisTempSet.upperQuad thisTempSet.upperCubic 1]);
            [thisSet.initialParams(1:7), thisSet.initialParams(8:14), thisSet.initialParams(15), thisSet.initialParams(16) ]= ColorMaterialModelXToParams([psiParamsFit;1],tempParams);
            params.qpInitialParams = thisSet.initialParams;

            thisSet.rawTrialData = thisSet.trialData; 
            
            for whichRep = 1:nRepetitions
                
                % Resample the data for this iteration of bootstraping
                clear nTrials id bootstrapData bootstrapDataAggregated
                nTrials = size(thisSet.rawTrialData,1);
                id = randi(nTrials,[nTrials 1]);
                bootstrapData = thisSet.rawTrialData(id,:);
                bootstrapDataAggregated = qPlusConcatenateRawData(bootstrapData, indices);
                
                thisSet.bs(whichRep).bootstrapDataAggregated = bootstrapDataAggregated;
                
                % Convert the information about pairs to 'our prefered representation'
                clear pairColorMatchColorCoords pairMaterialMatchColorCoords pairColorMatchMaterialCoords pairMaterialMatchMaterialCoords
                pairColorMatchColorCoords = bootstrapDataAggregated(:,1);
                pairMaterialMatchColorCoords = bootstrapDataAggregated(:,2);
                pairColorMatchMaterialCoords = bootstrapDataAggregated(:,3);
                pairMaterialMatchMaterialCoords = bootstrapDataAggregated(:,4);
                thisSet.bs(whichRep).bootstrapDataAggregatedFirstChosen = bootstrapDataAggregated(:,5);
                thisSet.bs(whichRep).bootstrapDataAggregatednTrials = bootstrapDataAggregated(:,6);
                thisSet.bs(whichRep).pFirstChosen = thisSet.bs(whichRep).bootstrapDataAggregatedFirstChosen./...
                    thisSet.bs(whichRep).bootstrapDataAggregatednTrials;
                
                [thisSet.bs(whichRep).returnedParams, thisSet.bs(whichRep).logLikelyFit, ...
                    thisSet.bs(whichRep).predictedProbabilitiesBasedOnSolution] = ...
                    FitColorMaterialModelMLDS(...
                    pairColorMatchColorCoords, ...
                    pairMaterialMatchColorCoords,...
                    pairColorMatchMaterialCoords, ...
                    pairMaterialMatchMaterialCoords,...
                    thisSet.bs(whichRep).bootstrapDataAggregatedFirstChosen, ...
                    thisSet.bs(whichRep).bootstrapDataAggregatednTrials,...
                    params);
            end   
            % Save
            cd (demoDir)
            save([fileName 'BootstrapFit'], 'thisSet'); clear thisSet
            cd (codeDir)
        end
    end
end
