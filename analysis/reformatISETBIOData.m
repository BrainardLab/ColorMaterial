function [modelFitData, indexMatrix, imageList] = reformatISETBIOData(modelFitData, nLevels, codes)
% cleans and reformats ISETBIO data for the analysis
% Input: 
% modelFitData - original data (should have 6 columns)
% nLevels - number of levels of test variation in color/material
% codes - coding of the levels in the pair structures

% check that the data has 6 columns, otherwise throw an error

% 

nums = 1:nLevels;
trackIndices = [];

% Create and image list
for i  = 1:length(modelFitData)
    imageList{i} = ['C' num2str(nums(find(codes==modelFitData(i,1)))), 'M', num2str(nums(find(codes==modelFitData(i,2)))), '-', ...
        'C' num2str(nums(find(codes==modelFitData(i,3)))), 'M', num2str(nums(find(codes==modelFitData(i,4))))];
end

% Compute probabilities from the data
modelFitData = [modelFitData, (modelFitData(:,5)./modelFitData(:,6))];

% Create the relevant strings to track color vs. material cross pairing.
for whichMaterialOfTheColorMatch = 1:nLevels % for each of these material changes
    for whichColorOfTheMaterialMatch = 1:nLevels % and each of these color levels
        
        colorMatchString = ['C4M' num2str(whichMaterialOfTheColorMatch)];
        materialMatchString = ['C' num2str(whichColorOfTheMaterialMatch) 'M4'];
        
        colorMatchFirstString = {[colorMatchString '-' materialMatchString]}; % search for these strings.
        colorMatchSecondString = {[materialMatchString '-' colorMatchString]};
        
        % Search through the stimulus list.
        for i = 1:length(imageList)
            clear tempString
            tempString =  imageList{i};
            
            if strcmp(tempString, colorMatchFirstString) || strcmp(tempString, colorMatchSecondString)
                % In E1P2, because of the way the subject list is
                % constructed, the target string is always first.
                % But the code should work well even if it is not.
                if strcmp(tempString(1:length(colorMatchString)), colorMatchString)
                    trackIndices = [trackIndices; i, whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch, 1];
                    % if the color match string is first
                    pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                        modelFitData(i,7);
                    colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                        modelFitData(i,5);
                    
                elseif strcmp(tempString((end-length(colorMatchString)+1):end), colorMatchString)
                    disp('checking')
                    trackIndices = [trackIndices; i, whichColorOfTheMaterialMatch, whichMaterialOfTheColorMatch, 2];
                    % if color match string is second
                    pColorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                        1-modelFitData(i,7);
                    colorMatchChosen(whichColorOfTheMaterialMatch,whichMaterialOfTheColorMatch) = ...
                        modelFitData(i,6)-modelFitData(i,5);
                else
                    error('Error: ColorMatch string not found.')
                end
            end
        end
        clear targetString otherString whichString1 whichString2
    end
end

% format index matrix for plotting
indexMatrix.rowIndex = trackIndices(:,2);
indexMatrix.columnIndex = trackIndices(:,3);
indexMatrix.overallColorMaterialPairIndices = trackIndices(:,1);
indexMatrix.colorMatchFirst = trackIndices(:,4);
indexMatrix.pColorMatchChosen = pColorMatchChosen; % p first chosen in cases where the two elements in the pair are reversed; 
indexMatrix.colorMatchChosen = colorMatchChosen; % first chosen in cases where the two elements in the pair are reversed; 
end
