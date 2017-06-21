% MakeExp2StimulusList
% Creates stimulus list specific to Experiment 2(Color/Material)

% 4/24/17 ar Wrote it.

% Initialize
clear all; close;

% Define parameters
alphaLevels = {'1', '2', '3', '4', '5', '6', '7'};
lambdaLevels = {'1', '2', '3', '4', '5', '6', '7'};

colorCoords = [-3:1:3]; 
matCoorrs = [-3:1:3];

targetLambda = 4; % color
targetAlpha = 4; % material
conditionList = {'NC'};
stimPairs = nchoosek(1:7,2);

% Get the color and material coordiantes for each member of
% this pair.
% pairColorMatchColorCoords(whichPair) = pair{whichPair, 1}(colorCoordIndex);
% pairMaterialMatchColorCoords(whichPair) = pair{whichPair, 2}(colorCoordIndex);
% pairColorMatchMaterialCoords(whichPair) = pair{whichPair, 1}(materialCoordIndex);
% pairMaterialMatchMaterialCoords(whichPair) = pair{whichPair, 2}(materialCoordIndex);

stimulusList = {};
% for each condition, create the image list
for c = 1:length(conditionList)
    for i = 1:length(alphaLevels)
        imageNameMat{i} = ['Exp2' conditionList{c} 'C' num2str(targetLambda), 'M' num2str(i)];
    end
    
    for i = 1:length(lambdaLevels)
        imageNameColor{i} = ['Exp2' conditionList{c}  'C' num2str(i), 'M' num2str(targetAlpha)];
    end
    
    for i = 1:length(imageNameMat)
        for j = 1:length(imageNameColor)
            stimulusList = [stimulusList, [imageNameMat{i} '-' imageNameColor{j}]];
        end
    end
    
    for i = 1:length(stimPairs)
        imageNameFirstColor{i} = ['Exp2' conditionList{c} 'C' num2str(stimPairs(i,1)), 'M' num2str(targetAlpha)];
        imageNameSecondColor{i} = [ 'Exp2' conditionList{c}  'C' num2str(stimPairs(i,2)), 'M' num2str(targetAlpha)];
        if any(ismember(stimulusList, [imageNameFirstColor{i} '-' imageNameSecondColor{i}])) || ...
                any(ismember(stimulusList, [imageNameSecondColor{i}  '-' imageNameFirstColor{i} ]))
        % do not add to the list
        else
            stimulusList = [stimulusList, [imageNameFirstColor{i} '-' imageNameSecondColor{i}]];
        end
    end
    for i = 1:length(stimPairs)
        imageNameFirstMat{i} = ['Exp2' conditionList{c} 'C' num2str(targetAlpha), 'M' num2str(stimPairs(i,1))];
        imageNameSecondMat{i} = ['Exp2' conditionList{c}  'C' num2str(targetAlpha), 'M' num2str(stimPairs(i,2))];
        if any(ismember(stimulusList, [imageNameFirstMat{i} '-' imageNameSecondMat{i}])) || ...
                any(ismember(stimulusList, [imageNameSecondMat{i}  '-' imageNameFirstMat{i} ]))
        % do not add to the list
        else
            stimulusList = [stimulusList, [imageNameFirstMat{i} '-' imageNameSecondMat{i}]];
        end
    end
end
save('Exp2stimulusList', 'stimulusList');
