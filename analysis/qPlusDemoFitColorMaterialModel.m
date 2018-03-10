% qPlusDemoFitColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Demo';
demoDir = fullfile( getpref('ColorMaterial', 'demoDataDir'));
codeDir  = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis'); 

% Exp parameters
% Specify other experimental parameters
nSets = 10;
distances = {'euclidean', 'cityblock'}; 
positionSmoothSpacing = [1, 3]; 
positionCode = {'Linear', 'Quad', 'Cubic'};

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
params = getqPlusPilotExpParams;

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

for ss = 1%:length(positionSmoothSpacing)
    for d = 1%:length(distances)
        for i = 1%:nSets
            % load the data set
            fileName = ['qpSimulation' distances{d} 'Positions-' positionCode{ss} '-' num2str(i) '.mat']; %qpSimulationcityblockPositions-Linear-10
            warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
            thisTempSet = load([fullfile(demoDir, fileName)]);
            %thisSet = thisTempSet.questDataAllTrials; 
            warning(warnState);
            thisSet.trialData = []; 
            for t = 1:length(thisTempSet.questDataAllTrials.trialData)
                thisSet.trialData = [thisSet.trialData; ...
                    thisTempSet.questDataAllTrials.trialData(t).stim, thisTempSet.questDataAllTrials.trialData(t).outcome];
            end
            clear thisTempSet; 
            % concatenate across blocks
            thisSet.nTrials = size(thisSet.trialData);
            thisSet.rawTrialData = thisSet.trialData;
            thisSet.newTrialData = qPlusConcatenateRawData(thisSet.rawTrialData, indices);
            
            % Convert the information about pairs to 'our prefered representation'
            thisSet.pairColorMatchColorCoords = thisSet.newTrialData(:,1);
            thisSet.pairMaterialMatchColorCoords = thisSet.newTrialData(:,3);
            thisSet.pairColorMatchMaterialCoords = thisSet.newTrialData(:,2);
            thisSet.pairMaterialMatchMaterialCoords = thisSet.newTrialData(:,4);
            thisSet.firstChosen = thisSet.newTrialData(:,5);
            thisSet.newNTrials = thisSet.newTrialData(:,6);
            thisSet.pFirstChosen = thisSet.firstChosen./thisSet.newNTrials;
            
            % model
            [thisSet.returnedParams, thisSet.logLikelyFit, thisSet.predictedProbabilitiesBasedOnSolution] = ...
                FitColorMaterialModelMLDS(thisSet.pairColorMatchColorCoords, ...
                thisSet.pairMaterialMatchColorCoords,...
                thisSet.pairColorMatchMaterialCoords, ...
                thisSet.pairMaterialMatchMaterialCoords,...
                thisSet.firstChosen, thisSet.newNTrials, params);
            
            % extract parameters
            [thisSet.returnedMaterialMatchColorCoords, thisSet.returnedColorMatchMaterialCoords, ...
                thisSet.returnedW, thisSet.returnedSigma]  = ColorMaterialModelXToParams(thisSet.returnedParams, params);
            
            % save
             save([fileName 'Fit'], 'thisSet'); clear thisSet
        end
    end
end
