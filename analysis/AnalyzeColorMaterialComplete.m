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
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
whichExperiment = 'E1P2b';
materialCoords  = [-3:1:3];
colorCoords  =  [-3:1:3];

% Specify other experimental parameters
subjectList = {'mdc', 'nsk'};
nLevels = 7; % number of levels across which color/material vary
nBlocks = 24;
conditionCode = {'NC', 'CY', 'CB'};

figAndDataDir = [mainDir 'CNST_analysis/ColorMaterial/Experiment1/'];
competitorImageName1 = [11, 14]-5;
competitorImageName2 = [21, 24]-5;

nSubjects = length(subjectList);
nConditions  = length(conditionCode);

colorCoordIndexInName = 2;
matCoordIndexInName = 4;

for s = 1:nSubjects
    load([figAndDataDir subjectList{s} 'CompleteData.mat']); 
    subject{s} = thisSubject; clear thisSubject
    subject{s}.Name = subjectList{s};
    fprintf('Subject %s.\n', subject{s}.Name)
   
    % Parse the conditions/stimuli
    for whichCondition = 1:nConditions
        for i = 1:length(subject{s}.condition{whichCondition}.imageList)
            if whichCondition == 1 && s == 1
                firstComp = subject{s}.condition{whichCondition}.imageList{i}(competitorImageName1(1):competitorImageName1(2));
                secondComp = subject{s}.condition{whichCondition}.imageList{i}(competitorImageName2(1):competitorImageName2(2));
                
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
    
    % For each condition, make and fill in the matrix for the color/material trade off.
    for whichCondition = 1:nConditions
        subject{s}.condition{whichCondition}.pColorMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.colorMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.pMaterialMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.materialMatchChosen = NaN(nLevels, nLevels);
        subject{s}.condition{whichCondition}.totalTrialsColorMatch = NaN(nLevels, nLevels);
        trackIndices = [];
        
        %% Got to here.
        for whichMaterialOfTheColorMatch = 1:nLevels % for each of these material changes
            for whichColorOfTheMaterialMatch = 1:nLevels % and each of these color levels
                colorMatchString = [subject{s}.Name conditionCode{whichCondition} 'C4M' num2str(whichMaterialOfTheColorMatch)];
                materialMatchString = [subject{s}.Name conditionCode{whichCondition} 'C' num2str(whichColorOfTheMaterialMatch) 'M4'];
                
                colorMatchFirstString = {[colorMatchString '-' materialMatchString]}; % search for these strings.
                colorMatchSecondString = {[materialMatchString '-' colorMatchString]};
                
                % Record pairs of stimuli. This will set up matrices of indices that will allow us to relate
                % entries of the response matrix to the indices of the
                % stimuli and the reponse matrix.We only need to do this on
                % the first condition and first subject
                % since it is the same for each condition/subject.
                
                for i = 1:length(subject{s}.condition{whichCondition}.imageList)
                    % Set up a total number of trials matrix for both
                    % color- and material-match-based modeling.
                    subject{s}.condition{whichCondition}.totalTrialsColorMatch(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                        subject{s}.condition{whichCondition}.totalTrials(i);
                    clear tempString
                    tempString =  subject{s}.condition{whichCondition}.imageList{i};
                    if strcmp(tempString, colorMatchFirstString) || strcmp(tempString, colorMatchSecondString)
                        % In E1P2, because of the way the subject list is
                        % constructed, the target string is always first.
                        % But the code should work well even if it is not.
                        if strcmp(tempString(1:length(colorMatchString)), colorMatchString)
                            trackIndices = [trackIndices; i, whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch, 1];
                            % if the color match string is first
                            subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = subject{s}.condition{whichCondition}.pFirstChosen(i);
                            subject{s}.condition{whichCondition}.colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = subject{s}.condition{whichCondition}.firstChosen(i);
                            
                        elseif strcmp(tempString((end-length(colorMatchString)+1):end), colorMatchString)
                            trackIndices = [trackIndices; i, whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch, 2];
                            % if color match string is second
                            subject{s}.condition{whichCondition}.pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = 1-subject{s}.condition{whichCondition}.pFirstChosen(i);
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
    save([subject{s}.Name, 'SummarizedDataFULL'], 'thisSubject');
end
pairColorMatchColorCoords = colorMatchColorCoord;
pairMaterialMatchColorCoords = materialMatchColorCoord;
pairColorMatchMaterialCoords = colorMatchMaterialCoord;
pairMaterialMatchMaterialCoords  = materialMatchMaterialCoord;

save('pairIndicesE1P2Complete',  'colorMatchColorCoordIndex', 'materialMatchColorCoordIndex',...
    'colorMatchMaterialCoordIndex', 'materialMatchMaterialCoordIndex', ...
    'pairColorMatchColorCoords', 'pairMaterialMatchColorCoords',...
    'pairColorMatchMaterialCoords', 'pairMaterialMatchMaterialCoords','trackIndices');