% convertMSImageToRGBColorMaterial
% converts beautiful stimuli Nicolas made to RGB for display

% 2/11/15 ar Wrote it.

% Initialize
clear all; close;

% Define parameters
alphaLevels = {'1', '2', '3', '4', '5', '6', '7'};
lambdaLevels = {'1', '2', '3', '4', '5', '6', '7'};
targetLambda = 4; % color
targetAlpha = 4; % material
subjectList = {'zpf'};
conditionList = {'NC', 'CY', 'CB'};

for s = 1:length(subjectList)
    imageList = {};
    
    % for each condition, create the image list
    for c = 1:length(conditionList)
        for i = 1:length(alphaLevels)
            imageNameMat{i} = [subjectList{s} conditionList{c} 'C' num2str(targetLambda), 'M' num2str(i)];
        end
        
        for i = 1:length(lambdaLevels)
            imageNameColor{i} = [subjectList{s} conditionList{c}  'C' num2str(i), 'M' num2str(targetAlpha)];
        end
        
        for i = 1:length(imageNameMat)
            for j = 1:length(imageNameColor)
                imageList = [imageList, ['E1P2-' imageNameMat{i} '-' imageNameColor{j}]];
            end
        end
    end
    
    save([subjectList{s} 'stimulusList'], 'imageList'); 
    clear imageList     imageNameMat	imageNameColor 
end