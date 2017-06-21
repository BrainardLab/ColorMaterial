% AnalyzeColorMaterialExperiments
% The script extracts the choice patterns and other data needed for
% modeling and analysis from experimental code.
%
% 09/30/16 ar Adapted it from the previous experimental code.
% 12/06/16 ar Modified, added comments. Made sure it gives the same result
%             as the origanal code.

% Initialize.
clc; clear ; %close all;

% Specify directories
codeDir = 'Users/Shared/Matlab/Experiments/ColorMaterial/code/';
whichExperiment = 'Pilot';
materialCoords  =  [-3:1:3];
colorCoords  =   [-3:1:3];

switch whichExperiment
    case 'E1P2'
        % Specify other experimental parameters
        subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 24;
        conditionCode = {'NC', 'CY', 'CB'};
        dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/';
        figAndDataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1';
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = { 'flj','vtr', 'scd', 'mcv', 'zhr'};
        nLevels = 7; % number of levels across which color/material vary
        nBlocks = 25;
        conditionCode = {'NC'};
        figAndDataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Pilot';
        dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
end

nSubjects = length(subjectList);
nConditions  = length(conditionCode);
nTrialsPerCondition = 49;

for s = 1:nSubjects
    subject{s}.Name = subjectList{s};
    fprintf('Subject %s.\n', subject{s}.Name)
    
    % Step 1. Compute average choices across blocks.
    for b = 1:nBlocks
        % load subject data for this block of trials. Modify the params
        % structure by adding fields for the data and for the session
        % number. Once assigned, clear all the imported data.
        load([dataDir, whichExperiment, '/', subjectList{s}, '/', subjectList{s} '-' whichExperiment, '-', num2str(b), '.mat']);
        subject{s}.block(b) = params;
        clear params exp
        for t = 1: length(subject{s}.block(b).trial)
            % Record the number of trials an image was chosen
            % Note: left and right test positions in the exp. are randomized.
            % In the experimental code we decode if the first or the
            % second element of the pair is chosen.
            subject{s}.chosenAcrossTrials(t,b) = subject{s}.block(b).trial(t).imageChosen;
        end
    end
    
    % Extract the data from the response structure
    % (1) How many 'first' image in the pair chosen
    tempFirstChosen = sum(subject{s}.chosenAcrossTrials==1,2);
    % (2) Count how many valid trials
    tempTotalTrialsChosen =  sum(~isnan(subject{s}.chosenAcrossTrials),2);
    % (3) Compute the proportion of choices for the first pair.
    tempPFirstChosen = tempFirstChosen./tempTotalTrialsChosen;
    
    % Parse the conditions
    if strcmp(whichExperiment, 'E1P2')
        % This is the stimulus list. It's the same list we have been using
        % in the experiment.
        load(['/Users/Shared/Matlab/Experiments/ColorMaterial/code/' subject{s}.Name 'stimulusList.mat']);
        
        for whichCondition = 1:nConditions
            startFrom = (whichCondition-1)*nTrialsPerCondition+1;
            endAt = nTrialsPerCondition*whichCondition;
            subject{s}.condition{whichCondition}.competitorPairList = imageList(startFrom:endAt);
            subject{s}.condition{whichCondition}.firstChosen = tempFirstChosen(startFrom:endAt);
            subject{s}.condition{whichCondition}.totalTrials = tempTotalTrialsChosen(startFrom:endAt);
            subject{s}.condition{whichCondition}.pFirstChosen = tempPFirstChosen(startFrom:endAt);
            subject{s}.condition{whichCondition}.chosenAcrossTrials = subject{s}.chosenAcrossTrials(startFrom:endAt,:)==1;
            
            for i = 1:length(subject{s}.condition{whichCondition}.competitorPairList)
                if whichCondition == 1 && s == 1
                    firstComp = subject{s}.condition{whichCondition}.competitorPairList{i}(11:14);
                    secondComp = subject{s}.condition{whichCondition}.competitorPairList{i}(21:end);
                    colorCoordIndexInName = 2;
                    matCoordIndexInName = 4;
                    
                    colorMatchColorCoordIndex(i) = str2num(firstComp(colorCoordIndexInName));
                    materialMatchColorCoordIndex(i) = str2num(secondComp(colorCoordIndexInName));
                    colorMatchMaterialCoordIndex(i) = str2num(firstComp(matCoordIndexInName));
                    materialMatchMaterialCoordIndex(i) = str2num(secondComp(matCoordIndexInName));
                    
                    colorMatchColorCoord(i) = colorCoords(colorMatchColorCoordIndex(i));
                    materialMatchColorCoord(i) = colorCoords(materialMatchColorCoordIndex(i));
                    colorMatchMaterialCoord(i) = materialCoords(colorMatchMaterialCoordIndex(i));
                    materialMatchMaterialCoord(i) = materialCoords(materialMatchMaterialCoordIndex(i));
                end
            end
        end
        clear tempFirstChosen tempTotalTrialsChosen tempPFirstChosen
        
    elseif strcmp(whichExperiment, 'Pilot')
        % PILOT
        load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/PilotImageList.mat')
        competitorPairs = nchoosek(1:length(imageNames),2);
        colorCoordIndexInName = 2;
        matCoordIndexInName = 4;
        
        for whichCondition = 1:nConditions
            for i = 1:length(competitorPairs) % reconstruct the image names, using the same logic as in the exp. code.
                subject{s}.condition{whichCondition}.competitorPairList(i,:) = {[imageNames{competitorPairs(i,1)}, '-' imageNames{competitorPairs(i,2)}]};
                %   subject{s}.condition{whichCondition}.competitorPairList = imageList;
                subject{s}.condition{whichCondition}.firstChosen(i) = tempFirstChosen(i);
                subject{s}.condition{whichCondition}.totalTrials(i) =  tempTotalTrialsChosen(i);
                subject{s}.condition{whichCondition}.pFirstChosen(i) = tempPFirstChosen(i);
                
                if whichCondition == 1 && s == 1
                    
                    colorMatchColorCoordIndex(i) = str2num(imageNames{competitorPairs(i,1)}(colorCoordIndexInName));
                    materialMatchColorCoordIndex(i) = str2num(imageNames{competitorPairs(i,2)}(colorCoordIndexInName));
                    colorMatchMaterialCoordIndex(i) = str2num(imageNames{competitorPairs(i,1)}(matCoordIndexInName));
                    materialMatchMaterialCoordIndex(i) = str2num(imageNames{competitorPairs(i,2)}(matCoordIndexInName));
                    
                    colorMatchColorCoord(i) = colorCoords(colorMatchColorCoordIndex(i));
                    materialMatchColorCoord(i) = colorCoords(materialMatchColorCoordIndex(i));
                    colorMatchMaterialCoord(i) = materialCoords(colorMatchMaterialCoordIndex(i));
                    materialMatchMaterialCoord(i) = materialCoords(materialMatchMaterialCoordIndex(i));
                end
            end
        end
    end
    
    
    % For each condition, make and fill in the matrix for the color/material trade off.
    for whichCondition = 1:nConditions
        subject{s}.condition{whichCondition}.pColorMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.colorMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.pMaterialMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.materialMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.totalTrialsColorMatchMatrix = NaN(nLevels, nLevels);
        temp = [];
        for whichMaterialOfTheColorMatch = 1:nLevels % for each of these material changes
            for whichColorOfTheMaterialMatch = 1:nLevels % and each of these color levels
                
                if strcmp(whichExperiment, 'E1P2')
                    colorMatchString = [subject{s}.Name conditionCode{whichCondition} 'C4M' num2str(whichMaterialOfTheColorMatch)];
                    materialMatchString = [subject{s}.Name conditionCode{whichCondition} 'C' num2str(whichColorOfTheMaterialMatch) 'M4'];
                elseif strcmp(whichExperiment, 'Pilot')
                    colorMatchString = ['C4M' num2str(whichMaterialOfTheColorMatch)];
                    materialMatchString = ['C' num2str(whichColorOfTheMaterialMatch) 'M4'];
                end
                colorMatchFirstString = {[colorMatchString '-' materialMatchString]}; % search for these strings.
                colorMatchSecondString = {[materialMatchString '-' colorMatchString]};
                
                % Record pairs of stimuli. This will set up matrices of indices that will allow us to relate
                % entries of the response matrix to the indices of the
                % stimuli and the reponse matrix.We only need to do this on
                % the first condition and first subject
                % since it is the same for each condition/subject.
                
                for i = 1:length(subject{s}.condition{whichCondition}.competitorPairList)
                    
                    % Set up a total number of trials matrix for both
                    % color- and material-match-based modeling.
                    subject{s}.condition{whichCondition}.totalTrialsColorMatchMatrix(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                        subject{s}.condition{whichCondition}.totalTrials(i);
                    subject{s}.condition{whichCondition}.totalTrialsMaterialMatchMatrix(whichMaterialOfTheColorMatch, whichColorOfTheMaterialMatch) = ...
                        subject{s}.condition{whichCondition}.totalTrials(i);
                    
                    clear tempString
                    if strcmp(whichExperiment, 'E1P2')
                        tempString =  subject{s}.condition{whichCondition}.competitorPairList{i}(6:end);
                    elseif strcmp(whichExperiment, 'Pilot')
                        tempString = subject{s}.condition{whichCondition}.competitorPairList{i};
                    end
                    
                    if strcmp(tempString, colorMatchFirstString) || strcmp(tempString, colorMatchSecondString)
                        % In E1P2, because of the way the subject list is
                        % constructed, the target string is always first.
                        if strcmp(tempString(1:length(colorMatchString)), colorMatchString)
                            temp = [temp; i, whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch, 1 ];
                            % if the color match string is first
                            subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = subject{s}.condition{whichCondition}.firstChosen(i);
                            
                            % an alternative look: we reverse the matrix
                            % and we compute the proportion of trials the
                            % material match is chosen.
                            subject{s}.condition{whichCondition}.pMaterialMatchChosen(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch) = 1 - subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.materialMatchChosen(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch) = ...
                                subject{s}.condition{whichCondition}.totalTrials(i) - subject{s}.condition{whichCondition}.firstChosen(i);
                            
                        elseif strcmp(tempString((end-length(colorMatchString)+1):end), colorMatchString)
                            temp = [temp; i, whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch, 2  ];
                            % if color match string is second
                            subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = 1-subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                                subject{s}.condition{whichCondition}.totalTrials(i)-subject{s}.condition{whichCondition}.firstChosen(i);
                            
                            subject{s}.condition{whichCondition}.pMaterialMatchChosen(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch) = subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.materialMatchChosen(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch) = subject{s}.condition{whichCondition}.firstChosen(i);
                            
                        else
                            error('Error: ColorMatch string not found.')
                        end
                    end
                end
                clear targetString otherString whichString1 whichString2
                
                % A few sanity checks
                % color and matrial probs should add up to 1
                % also color and material counts should add up to nTrials.
                test1 = subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch)+subject{s}.condition{whichCondition}.pMaterialMatchChosen(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch)';
                test2 = subject{s}.condition{whichCondition}.colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch)+subject{s}.condition{whichCondition}.materialMatchChosen(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch)';
                %                 if test1 ~= 1
                %                     error('Probabilities do not add up to 1.')
                %                 end
                %                 if test2 ~= subject{s}.condition{whichCondition}.totalTrialsColorMatchMatrix(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch)
                %                     if  whichColorOfTheMaterialMatch == 4 && whichMaterialOfTheColorMatch == 4
                %                     else
                %                         error('Numbers do not add up to total number of trials in color matrix.')
                %                     end
                %                 end
                %                 if test2 ~= subject{s}.condition{whichCondition}.totalTrialsMaterialMatchMatrix(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch)
                %                      if  whichColorOfTheMaterialMatch == 4 && whichMaterialOfTheColorMatch == 4
                %                      else
                %                          error('Numbers do not add up to total number of trials in material-match matrix, but not color?')
                %                      end
                %                 end
                
                
            end
        end
        
        % implement fix for a data point that is not run in the pilot
        % experiment
        if strcmp(whichExperiment, 'Pilot')
            nanIndex = ~isnan(subject{s}.condition{whichCondition}.colorMatchChosen);
            
            subject{s}.condition{whichCondition}.colorMatchChosen = subject{s}.condition{whichCondition}.colorMatchChosen(nanIndex);
            subject{s}.condition{whichCondition}.totalTrialsColorMatchMatrix = subject{s}.condition{whichCondition}.totalTrialsColorMatchMatrix(nanIndex);
            subject{s}.condition{whichCondition}.pColorMatchChosen = subject{s}.condition{whichCondition}.pColorMatchChosen(nanIndex);
            
            pairColorMatchMaterialCoordIndices = pairColorMatchMaterialCoordIndexMatrixFitColorMatch(nanIndex);
            pairMaterialMatchColorCoordIndices = pairMaterialMatchColorCoordIndexMatrixFitColorMatch(nanIndex);
        end
    end
    
    % Save summarized results.
    cd (figAndDataDir)
    thisSubject = subject{s};
    save([subject{s}.Name, 'SummarizedData'], 'thisSubject');
end
% Also save pair indices for each experiment.
if strcmp(whichExperiment, 'E1P2')
    save('pairIndicesE1P2',  'colorMatchColorCoordIndex', 'materialMatchColorCoordIndex',...
        'colorMatchMaterialCoordIndex', 'materialMatchMaterialCoordIndex', ...
        'colorMatchColorCoord', 'materialMatchColorCoord',...
        'colorMatchMaterialCoord', 'materialMatchMaterialCoord');
elseif strcmp(whichExperiment, 'Pilot')
    save('pairIndicesPilot', 'colorMatchColorCoordIndex', 'materialMatchColorCoordIndex',...
        'colorMatchMaterialCoordIndex', 'materialMatchMaterialCoordIndex', ...
        'colorMatchColorCoord', 'materialMatchColorCoord',...
        'colorMatchMaterialCoord', 'materialMatchMaterialCoord');
    %    save('pairIndicesPilot', 'pairColorMatchMaterialCoordIndices', 'pairMaterialMatchColorCoordIndices');
else
    error('No such experiment.')
end

              
