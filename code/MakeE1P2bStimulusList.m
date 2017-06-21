% Makes a list for within-dimension presentation in Experiment 2

% 3/13/17 ar Wrote it.

% Initialize
clear all; close;

% Define parameters
subjectList = {'nsk', 'mdc'};
conditionList = {'NC', 'CY', 'CB'};
nStimuliPerDim = 7; % number of stimuli per dimension
stimPairs = nchoosek(1:7,2);
targetLambda = 4; % color
targetAlpha = 4; % material

for s = 1:length(subjectList)
    imageList = {};
    
    % for each condition, create the image list
    for c = 1:length(conditionList)
        for i = 1:length(stimPairs)
            imageNameFirstColor{i} = [subjectList{s} conditionList{c} 'C' num2str(stimPairs(i,1)), 'M' num2str(targetAlpha)];
            imageNameSecondColor{i} = [subjectList{s} conditionList{c}  'C' num2str(stimPairs(i,2)), 'M' num2str(targetAlpha)];
            imageList = [imageList, ['E1P2-' imageNameFirstColor{i} '-' imageNameSecondColor{i}]];
        end
        for i = 1:length(stimPairs)
            imageNameFirstMat{i} = [subjectList{s} conditionList{c} 'C' num2str(targetAlpha), 'M' num2str(stimPairs(i,1))];
            imageNameSecondMat{i} = [subjectList{s} conditionList{c}  'C' num2str(targetAlpha), 'M' num2str(stimPairs(i,2))];
            imageList = [imageList, ['E1P2-' imageNameFirstMat{i} '-' imageNameSecondMat{i}]];
        end
    end
    
    save([subjectList{s} 'stimulusList2b'], 'imageList'); 
    clear imageList     imageNameMat	imageNameColor 
end