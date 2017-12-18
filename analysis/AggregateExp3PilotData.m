% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'E3';


dataDir = getpref('ColorMaterial', 'dataFolder'); 
analysisDir = [getpref('ColorMaterial', 'analysisDir') '/E3']; 
mainDir = fullfile(getpref('ColorMaterial', 'mainExpDir'), 'analysis'); 

% Exp parameters
% Specify other experimental parameters
subjectList = {'ar', 'dhb'};
nBlocks = [2, 1];
conditionCode = {'NC'};
% setIndices for concatinating trial data
indices.stimPairs = 1:4; 
indices.response1 = 5; 
indices.nTrials = 6; 

nSubjects = length(subjectList);
nConditions = length(conditionCode); 

% For each subject and each condition, run the model and basic plots
for s = 1:nSubjects
    for c = 1:nConditions
    % Get the full data set for each subject. 
    % Concatenate across 
    subject{s}.condition{c}.trialData = [];
    for b  = 1:nBlocks(s)
        warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
        tempSubj = load([dataDir '/' subjectList{s} '/' subjectList{s}  '-'  whichExperiment  '-' num2str(b) '.mat']);
        warning(warnState);
        for t = 1:length(tempSubj.params.data.trialData)
            subject{s}.condition{c}.trialData = [subject{s}.condition{c}.trialData; ...
                tempSubj.params.data.trialData(t).stim, tempSubj.params.data.trialData(t).outcome];
        end
        clear tempSubj
    end
    cd(mainDir)
    subject{s}.condition{c}.nTrials = size(subject{s}.condition{c}.trialData,1);
    subject{s}.condition{c}.rawTrialData = subject{s}.condition{c}.trialData;
    subject{s}.condition{c}.newTrialData = qPlusConcatenateRawData(subject{s}.condition{c}.rawTrialData, indices);
    
    clear matchIndex
    
    % Convert the information about pairs to 'our prefered representation'
    subject{s}.condition{c}.pairColorMatchColorCoords = subject{s}.condition{c}.newTrialData(:,1);
    subject{s}.condition{c}.pairMaterialMatchColorCoords = subject{s}.condition{c}.newTrialData(:,3);
    subject{s}.condition{c}.pairColorMatchMaterialCoords = subject{s}.condition{c}.newTrialData(:,2);
    subject{s}.condition{c}.pairMaterialMatchMaterialCoords = subject{s}.condition{c}.newTrialData(:,4);
    subject{s}.condition{c}.firstChosen = subject{s}.condition{c}.newTrialData(:,5);
    subject{s}.condition{c}.newNTrials = subject{s}.condition{c}.newTrialData(:,6);
    subject{s}.condition{c}.pFirstChosen = subject{s}.condition{c}.firstChosen./...
        subject{s}.condition{c}.nTrials; 
    end
    cd(analysisDir)
    thisSubject = subject{s};
    save([subjectList{s} 'SummarizedqPlusData'], 'thisSubject'); clear thisSubject
end