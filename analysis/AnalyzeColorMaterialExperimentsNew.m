% AnalyzeColorMaterialExperimentsNew
% The script extracts the choice patterns and other data needed for
% modeling and analysis from experimental code.
%
% 09/30/16 ar Adapted it from the previous experimental code.
% 12/06/16 ar Modified, added comments. Made sure it gives the same result
%             as the origanal code.
% 07/02/17 ar Reviewed it and added comments. 

% Initialize.
clear ; close all;

% Specify directories
codeDir = fullfile(tbLocateProject('ColorMaterial'),'code'); %'Users/Shared/Matlab/Experiments/ColorMaterial/code/';
%mainDir = getpref('ColorMaterial',mainDir); %'/Users/ana/Dropbox (Aguirre-Brainard Lab)/'; 
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/'; 
whichExperiment = 'Pilot';

switch whichExperiment
    case 'E1P2'
        % Specify other experimental parameters
        subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
        
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 24;
        conditionCode = {'NC', 'CY', 'CB'};
        dataDir = [mainDir 'CNST_data/ColorMaterial/'];
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Experiment1/'];
        competitorImageName1 = [11, 14];
        competitorImageName2 = [21, 24];
        
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = { 'flj','vtr', 'scd', 'mcv', 'zhr'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 25;
        conditionCode = {'NC'};
        figAndDataDir = [mainDir, 'CNST_analysis/ColorMaterial/Pilot'];
        dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/';
        competitorImageName1 = [1, 4];
        competitorImageName2 = [6, 9];
        
    case 'E1P2b'
        % Specify other experimental parameters
        subjectList = {'mdc', 'nsk'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 24;
        conditionCode = {'NC', 'CY', 'CB'};
        dataDir = [mainDir 'CNST_data/ColorMaterial/'];
        figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Experiment1/'];
        competitorImageName1 = [11, 14];
        competitorImageName2 = [21, 24];
end

nSubjects = length(subjectList);
nConditions  = length(conditionCode);
colorCoordIndexInName = 2;
matCoordIndexInName = 4;
materialCoords  = [-3:1:3];
colorCoords  =  [-3:1:3];

for s = 1:nSubjects
    subject{s}.Name = subjectList{s};
    fprintf('Subject %s.\n', subject{s}.Name)
    % Step 1. Compute average choices across blocks.
    for b = 1:nBlocks
        % Load subject data for this block of trials. Modify the params
        % structure by adding fields for the data and for the session
        % number. Once assigned, clear all the imported data.
        load([dataDir, whichExperiment, '/', subjectList{s}, '/', subjectList{s} '-' whichExperiment, '-', num2str(b), '.mat']);
        subject{s}.block(b) = params;
        subject{s}.nTrialsPerCondition = length(subject{s}.block(b).trial)/nConditions; 
        clear params exp
        
        for t = 1: length(subject{s}.block(b).trial)
            % Record the number of trials an image was chosen
            % Note: left and right test positions in the exp. are randomized.
            % In the experimental code we decode if the first or the
            % second element of the pair is chosen.
            subject{s}.chosenAcrossTrials(t,b) = subject{s}.block(b).trial(t).imageChosen;
            subject{s}.firstChosenAcrossTrials(t,b) = subject{s}.block(b).trial(t).imageChosen==1; 
        end
    end
    
    % Extract the data from the response structure
    % (1) How many 'first' image in the pair chosen
    % (2) Count how many valid trials
    % (3) Compute the proportion of choices for the first pair.
    tempFirstChosen = sum(subject{s}.chosenAcrossTrials==1,2);
    tempTotalTrialsChosen =  sum(~isnan(subject{s}.chosenAcrossTrials),2);
    tempPFirstChosen = tempFirstChosen./tempTotalTrialsChosen;
    
    % Parse the stimulus list 
    if strcmp(whichExperiment, 'E1P2')
        % This is the stimulus list. It's the same list we have been using
        % in the experiment.
        load([codeDir '/' subject{s}.Name 'stimulusList.mat']);
    elseif strcmp(whichExperiment, 'E1P2b')
        compList = load([codeDir '/' subject{s}.Name 'stimulusList.mat']);
        load([codeDir '/' subject{s}.Name 'stimulusList2b.mat']);
    elseif strcmp(whichExperiment, 'Pilot')
        load([codeDir '/PilotImageList.mat'])
        competitorPairs = nchoosek(1:length(imageNames),2);
        for whichCondition = 1:nConditions
            for i = 1:length(competitorPairs) % reconstruct the image names, using the same logic as in the exp. code.
                imageList(i,:) = {[imageNames{competitorPairs(i,1)}, '-' imageNames{competitorPairs(i,2)}]};
            end
        end
    end
    
    % Parse the conditions/stimuli
    for whichCondition = 1:nConditions
        startFrom = (whichCondition-1)*subject{s}.nTrialsPerCondition+1;
        endAt = subject{s}.nTrialsPerCondition*whichCondition;
        subject{s}.condition{whichCondition}.imageList = imageList(startFrom:endAt);
        subject{s}.condition{whichCondition}.firstChosen = tempFirstChosen(startFrom:endAt);
        subject{s}.condition{whichCondition}.pFirstChosen = tempPFirstChosen(startFrom:endAt);
        subject{s}.condition{whichCondition}.totalTrials = tempTotalTrialsChosen(startFrom:endAt);
        subject{s}.condition{whichCondition}.firstChosenPerTrial = subject{s}.firstChosenAcrossTrials(startFrom:endAt,:);
        
        % Get the pairs. For each stimulus image, recover which color-material competitors were presented 
        for i = 1:length(subject{s}.condition{whichCondition}.imageList)
            if whichCondition == 1 && s == 1
                firstComp = subject{s}.condition{whichCondition}.imageList{i}(competitorImageName1(1):competitorImageName1(2));
                secondComp = subject{s}.condition{whichCondition}.imageList{i}(competitorImageName2(1):competitorImageName2(2));
                
                colorMatchColorCoordIndex(i) = str2num(firstComp(colorCoordIndexInName));
                materialMatchColorCoordIndex(i) = str2num(secondComp(colorCoordIndexInName));
                colorMatchMaterialCoordIndex(i) = str2num(firstComp(matCoordIndexInName));
                materialMatchMaterialCoordIndex(i) = str2num(secondComp(matCoordIndexInName));
                
                pairColorMatchColorCoords(i) = colorCoords(colorMatchColorCoordIndex(i));
                pairMaterialMatchColorCoords(i) = colorCoords(materialMatchColorCoordIndex(i));
                pairColorMatchMaterialCoords(i) = materialCoords(colorMatchMaterialCoordIndex(i));
                pairMaterialMatchMaterialCoords(i) = materialCoords(materialMatchMaterialCoordIndex(i));
            end
        end
    end
    clear tempFirstChosen tempTotalTrialsChosen tempPFirstChosen
    
    % For each condition, make and fill in the matrix for the color/material trade off.
    for whichCondition = 1:nConditions
        subject{s}.condition{whichCondition}.pColorMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.colorMatchChosen = NaN(nLevels, nLevels);
        trackIndices = [];
       
        % Create the relevant strings
        for whichMaterialOfTheColorMatch = 1:nLevels % for each of these material changes
            for whichColorOfTheMaterialMatch = 1:nLevels % and each of these color levels
                if strcmp(whichExperiment, 'E1P2') || strcmp(whichExperiment, 'E1P2b')
                    colorMatchString = [subject{s}.Name conditionCode{whichCondition} 'C4M' num2str(whichMaterialOfTheColorMatch)];
                    materialMatchString = [subject{s}.Name conditionCode{whichCondition} 'C' num2str(whichColorOfTheMaterialMatch) 'M4'];
                elseif strcmp(whichExperiment, 'Pilot')
                    colorMatchString = ['C4M' num2str(whichMaterialOfTheColorMatch)];
                    materialMatchString = ['C' num2str(whichColorOfTheMaterialMatch) 'M4'];
                end
                colorMatchFirstString = {[colorMatchString '-' materialMatchString]}; % search for these strings.
                colorMatchSecondString = {[materialMatchString '-' colorMatchString]};
                
                % Search through the stimulus list. 
                for i = 1:length(subject{s}.condition{whichCondition}.imageList)
                    
                    clear tempString
                    if strcmp(whichExperiment, 'E1P2')
                        tempString =  subject{s}.condition{whichCondition}.imageList{i}(6:end);
                    elseif strcmp(whichExperiment, 'E1P2b')
                        tempString =  subject{s}.condition{whichCondition}.imageList{i}(6:end);
                    elseif strcmp(whichExperiment, 'Pilot')
                        tempString =  subject{s}.condition{whichCondition}.imageList{i};
                    end
                    
                    if strcmp(tempString, colorMatchFirstString) || strcmp(tempString, colorMatchSecondString)
                        % In E1P2, because of the way the subject list is
                        % constructed, the target string is always first.
                        % But the code should work well even if it is not.
                        if strcmp(tempString(1:length(colorMatchString)), colorMatchString)
                            trackIndices = [trackIndices; i, whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch, 1];
                            % if the color match string is first
                            subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                                subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                                subject{s}.condition{whichCondition}.firstChosen(i);
                            
                        elseif strcmp(tempString((end-length(colorMatchString)+1):end), colorMatchString)
                            trackIndices = [trackIndices; i, whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch, 2];
                            % if color match string is second
                            subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                                1-subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                                subject{s}.condition{whichCondition}.totalTrials(i)-subject{s}.condition{whichCondition}.firstChosen(i);
                        else
                            error('Error: ColorMatch string not found.')
                        end
                    end
                end
                clear targetString otherString whichString1 whichString2
            end
        end
    end
    % Save summarized results.
    cd (figAndDataDir)
    thisSubject = subject{s};
    if strcmp(whichExperiment, 'E1P2b')
        save([subject{s}.Name, 'SummarizedData2b'], 'thisSubject');
    else
        save([subject{s}.Name, 'SummarizedData'], 'thisSubject');
    end
end

indexMatrix.rowIndex = trackIndices(:,2); 
indexMatrix.columnIndex = trackIndices(:,3); 
indexMatrix.overallColorMaterialPairIndices = trackIndices(:,1); 
indexMatrix.colorMatchFirst = trackIndices(:,4); 


% Also save pair indices for each experiment.
if strcmp(whichExperiment, 'E1P2')
    save('pairIndicesE1P2',  'colorMatchColorCoordIndex', 'materialMatchColorCoordIndex',...
        'colorMatchMaterialCoordIndex', 'materialMatchMaterialCoordIndex', ...
        'pairColorMatchColorCoords', 'pairMaterialMatchColorCoords',...
        'pairColorMatchMaterialCoords', 'pairMaterialMatchMaterialCoords','indexMatrix');
elseif strcmp(whichExperiment, 'E1P2b')
    save('pairIndicesE1P2b',  'colorMatchColorCoordIndex', 'materialMatchColorCoordIndex',...
        'colorMatchMaterialCoordIndex', 'materialMatchMaterialCoordIndex', ...
        'pairColorMatchColorCoords', 'pairMaterialMatchColorCoords',...
        'pairColorMatchMaterialCoords', 'pairMaterialMatchMaterialCoords','indexMatrix');
elseif strcmp(whichExperiment, 'Pilot')
    save('pairIndicesPilot', 'colorMatchColorCoordIndex', 'materialMatchColorCoordIndex',...
        'colorMatchMaterialCoordIndex', 'materialMatchMaterialCoordIndex', ...
        'pairColorMatchColorCoords', 'pairMaterialMatchColorCoords',...
        'pairColorMatchMaterialCoords', 'pairMaterialMatchMaterialCoords','indexMatrix');
else
    error('No such experiment.')
end