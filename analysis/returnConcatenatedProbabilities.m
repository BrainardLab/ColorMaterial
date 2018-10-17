% function concatenatedProbabilities = returnConcatenatedProbabilities(subjectData)
function concatenatedProbabilities = returnConcatenatedProbabilities(subjectData)
% Concatenates probabilities for equivalent trials.
% Input
% subjectData - structure contains qPlus data, but the identical pairs
% (competitor 1 and competitor 2) that differ only in place assignment (c1 first or c1 second) have not been integrated.
% Output 
% concatenatedProbabilities - integrated structure 

% 10/17/18 ar Wrote it

% HARDCODED THE INDICES HERE. 
c1Index = 1;
c2Index = 2;
m1Index = 3;
m2Index = 4;
firstChosenIndex = 5;
totalTrialsIndex = 6;

% Loop over all trials.
for i = 1:size(subjectData,1)
    % Get the pattern of data and create an index cell
    clear thisDataTrial
    thisDataTrial = subjectData(i,:);
    indexList{i} = [];
    
    % Now loop through all the other trials and see when the pair repeat
    for j = 1:size(subjectData,1)
        if (subjectData(j,c1Index)==thisDataTrial(c2Index)) & (subjectData(j,c2Index)==thisDataTrial(c1Index)) & ...
                (subjectData(j,m1Index)==thisDataTrial(m2Index)) & (subjectData(j,m2Index)==thisDataTrial(m1Index))
            if j ~= i
                indexList{i} = [indexList{i}, j];
                % combine total trials
                subjectData(i,totalTrialsIndex) = thisDataTrial(totalTrialsIndex)+subjectData(j,totalTrialsIndex);
                
                % combine n First chosen
                subjectData(i,firstChosenIndex) = thisDataTrial(firstChosenIndex)+(subjectData(j,6)-subjectData(j,firstChosenIndex));
                
                % turn into nans
                subjectData(j,:) = nan(size(thisDataTrial));
            end
        else
            % do nothing
        end
    end
end
concatenatedProbabilities = subjectData; 