% ImplementColorMaterialModel

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3']; 

% Exp parameters
% Specify other experimental parameters
subjectList = {'ar', 'dhb'};
nBlocks = [2, 1];
conditionCode = {'NC'};

nSubjects = length(subjectList);
nConditions = length(conditionCode); 

% For each subject and each condition, run the model and basic plots
for s = 1:nSubjects
    for c = 1:nConditions
    % Get the full data set for each subject. 
    % Concatenate across 
    subject{s}.condition{c}.trialData = [];
    for b  = 1:nBlocks(s)
        tempSubj = load([dataDir '/' subjectList{s} '/' subjectList{s}  '-'  whichExperiment  '-' num2str(b) '.mat']);
        for t = 1:length(tempSubj.params.data.trialData)
            subject{s}.condition{c}.trialData = [subject{s}.condition{c}.trialData; ...
                tempSubj.params.data.trialData(t).stim, tempSubj.params.data.trialData(t).outcome];
        end
        clear tempSubj
    end
    subject{s}.condition{c}.nTrials = size(subject{s}.condition{c}.trialData,1);
    subject{s}.condition{c}.rawTrialData = subject{s}.condition{c}.trialData; 
    % Concatenate the trials. 
    % For each trial, check if it repeats (by looping through all the other
    % trials). Save the *target* trial information, and add onto this, as
    % more identical trials are found. 
    for i = 1:subject{s}.condition{c}.nTrials
        tempIndList = setdiff([1:subject{s}.condition{c}.nTrials],i);
        matchIndex{i} = subject{s}.condition{c}.trialData(i,:);
        % For all other trials, check if they match (by checking the first
        % 4 key stimulus characteristics. 
        % WHAT IF THEY ARE REVERSED. 
        for j = 1:length(tempIndList)
            match = ((subject{s}.condition{c}.trialData(i,1) == subject{s}.condition{c}.trialData(tempIndList(j),1)) && ...
                (subject{s}.condition{c}.trialData(i,2) == subject{s}.condition{c}.trialData(tempIndList(j),2)) && ...
                (subject{s}.condition{c}.trialData(i,3) == subject{s}.condition{c}.trialData(tempIndList(j),3)) && ...
                (subject{s}.condition{c}.trialData(i,4) == subject{s}.condition{c}.trialData(tempIndList(j),4)));
            matchReversed = ((subject{s}.condition{c}.trialData(i,1) == subject{s}.condition{c}.trialData(tempIndList(j),3)) && ...
                (subject{s}.condition{c}.trialData(i,2) == subject{s}.condition{c}.trialData(tempIndList(j),4)) && ...
                (subject{s}.condition{c}.trialData(i,3) == subject{s}.condition{c}.trialData(tempIndList(j),1)) && ...
                (subject{s}.condition{c}.trialData(i,4) == subject{s}.condition{c}.trialData(tempIndList(j),2)));
            
            % eliminate the 
            if match == true
                matchIndex{i} = [matchIndex{i}; subject{s}.condition{c}.trialData(tempIndList(j),:)];
                subject{s}.condition{c}.trialData(tempIndList(j),:) = nan(size((subject{s}.condition{c}.trialData(tempIndList(j),:))));
            elseif matchReversed == true
                temp = subject{s}.condition{c}.trialData(tempIndList(j),:);
                % reverse which one is chosen, without modifyng the
                % original raw data.
                if temp(end) == 1
                    temp(end) = 2;
                elseif temp(end) == 2
                    temp(end) = 1;
                end
                matchIndex{i} = [matchIndex{i}; temp];
                subject{s}.condition{c}.trialData(tempIndList(j),:) = ...
                    nan(size((subject{s}.condition{c}.trialData(tempIndList(j),:))));
            end
        end
    end
    
    counter = 1;
    for i = 1:subject{s}.condition{c}.nTrials
        if ~sum(isnan(matchIndex{i}(:)))>0
            subject{s}.condition{c}.newTrialData(counter,:) = ...
                [matchIndex{i}(1,1:4), sum(matchIndex{i}(:,5)==1), size(matchIndex{i},1)];
            counter = counter + 1;
        end
    end
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
    
    thisSubject = subject{s};
    cd (analysisDir)
    save([subjectList{s} 'SummarizedqPlusData'], 'thisSubject'); clear thisSubject
end