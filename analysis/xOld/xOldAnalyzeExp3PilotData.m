% xOldAnalyzeExp3PilotData
% We used this to analyze pilot qPlus data. 
% It is obsolete: we ended up changing the model parameters and debugging exp code. 
% We're only keeping this for records. 

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';

% Exp parameters
% Specify other experimental parameters
% This can not be re-run because this data is not saved. 
subjectList = {'cjz', 'cjz1', 'cjz2', 'cjz3', 'cjz4'};
nBlocks = [4, 1, 1, 1, 1];
conditionCode = {'NC'};
figAndDataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/E3';

nSubjects = length(subjectList);

% Set up some params
% Here we use the example structure that matches the experimental design of
% our initial experiments.
% load('ColorMaterialExampleStructure.mat')

% Nominal coordinates
%% Set up main params
params.targetIndex = 4;
params.competitorsRangePositive = [1 3];
params.competitorsRangeNegative = [-3 -1];
params.targetMaterialCoord = 0;
params.targetColorCoord = 0;
params.sigma = 1;
params.sigmaFactor = 4;

params.targetPosition = 0;
params.targetIndexColor =  11; % target position on the color dimension in the set of all paramters.
params.targetIndexMaterial = 4; % target position on the material dimension in the set of all paramters.

params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.numberOfMaterialCompetitors = length(params.colorMatchMaterialCoords);
params.numberOfColorCompetitors = length(params.materialMatchColorCoords);
params.numberOfCompetitorsPositive = length(params.competitorsRangePositive(1):params.competitorsRangePositive(end));
params.numberOfCompetitorsNegative = length(params.competitorsRangeNegative(1):params.competitorsRangeNegative(end));


% Set up modeling
% What sort of position fitting ('full', 'smoothOrder').
params.whichPositions = 'full';
if strcmp(params.whichPositions, 'smoothSpacing')
    params.smoothOrder = 1;
end

% Initial position spacing values to try.
trySpacingValues = [0.5 1 2 3 4];
params.tryMaterialSpacingValues = trySpacingValues; 
params.tryColorSpacingValues = trySpacingValues; 
% Does material/color weight vary in fit? ('weightVary', 'weightFixed'). 
params.whichWeight = 'weightVary';

if strcmp(params.whichWeight, 'weightFixed')
    fixedWValue = [0.1:0.1:0.9];
    nWeigthValues = length(fixedWValue); 
else
    tryWeightValues = [0.5 0.2 0.8];
    nWeigthValues = 1; 
end
params.maxPositionValue = 20; 
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'

% Load lookup table
load colorMaterialInterpolateFunLineareuclidean.mat
colorMaterialInterpolatorFunction = colorMaterialInterpolatorFunction;
interpCode = 'Lin';
params.F = colorMaterialInterpolatorFunction; % for lookup.

% For each subject and each condition, run the model and basic plots
for ww = 1:nWeigthValues
    clear subject
    for s = 1:nSubjects
        
        % Accumulate trial data
        subject{s}.trialData = []; 
        for b  = 1:nBlocks(s)
            tempSubj = load([figAndDataDir '/' subjectList{s} '/' subjectList{s}  '-'  whichExperiment  '-' num2str(1) '.mat']);
            for t = 1:length(tempSubj.params.data.trialData)
                subject{s}.trialData = [subject{s}.trialData; tempSubj.params.data.trialData(t).stim, tempSubj.params.data.trialData(t).outcome];
            end
        end
        
        nTrials = size(subject{s}.trialData,1);
        for i = 1:nTrials
            n = 1;
            tempIndList = setdiff([1:nTrials],i);
            matchIndex{i} = [subject{s}.trialData(i,:)];
            for j = 1:length(tempIndList)
                match = ((subject{s}.trialData(i,1) == subject{s}.trialData(tempIndList(j),1)) && ...
                    (subject{s}.trialData(i,2) == subject{s}.trialData(tempIndList(j),2)) && ...
                    (subject{s}.trialData(i,3) == subject{s}.trialData(tempIndList(j),3)) && ...
                    (subject{s}.trialData(i,4) == subject{s}.trialData(tempIndList(j),4)));
                if match == true
                    matchIndex{i} = [matchIndex{i}; subject{s}.trialData(tempIndList(j),:)];
                    subject{s}.trialData(tempIndList(j),:) = nan(size((subject{s}.trialData(tempIndList(j),:))));
                end
            end
        end
        for i = 1:nTrials
            if ~sum(isnan(matchIndex{i}(:)))>0
                subject{s}.newTrialData(n,:) = [matchIndex{i}(1,1:4), sum(matchIndex{i}(:,5)==1), size(matchIndex{i},1)];
                n = n + 1;
            end
        end
        
        % convert to 'our prefered representation'
        pairColorMatchColorCoords = subject{s}.newTrialData(:,1);
        pairMaterialMatchColorCoords = subject{s}.newTrialData(:,3); 
        pairColorMatchMaterialCoords = subject{s}.newTrialData(:,2); 
        pairMaterialMatchMaterialCoords = subject{s}.newTrialData(:,4); 
        subject{s}.firstChosen = subject{s}.newTrialData(:,5);
        subject{s}.nTrials = subject{s}.newTrialData(:,6);
        
        if strcmp(params.whichWeight, 'weightFixed')
            tryWeightValues = fixedWValue(ww);
        end
        
        params.tryWeightValues = tryWeightValues;
        
        
        [subject{s}.returnedParams, subject{s}.logLikelyFit, ...
            subject{s}.predictedProbabilitiesBasedOnSolution] = ...
            FitColorMaterialModelMLDS(pairColorMatchColorCoords, pairMaterialMatchColorCoords,...
            pairColorMatchMaterialCoords, pairMaterialMatchMaterialCoords,...
            subject{s}.firstChosen , subject{s}.nTrials,...
            params);
       
        
            [subject{s}.returnedMaterialMatchColorCoords, ...
                subject{s}.returnedColorMatchMaterialCoords, ...
                subject{s}.returnedW,...
                subject{s}.returnedSigma]  = ColorMaterialModelXToParams(subject{s}.condition{whichCondition}.returnedParams, params);
            
        thisSubject = subject{s};
        cd (figAndDataDir)
        if strcmp(params.whichWeight, 'weightFixed')
            save([interpCode subjectList{s} 'SolutionNew-' params.whichWeight num2str(tryWeightValues*10)], 'thisSubject'); clear thisSubject
        else
            save([interpCode subjectList{s} 'SolutionOld-' params.whichWeight], 'thisSubject'); clear thisSubject
        end
    end
end
save(['Params' whichExperiment], 'params');