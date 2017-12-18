function concatData = qPlusConcatenateRawData(trialData, indices)

% Concatinates raw data into a new data array and updates the total number
% of trials that are responded with 1 or 0. 
% Input: trial data - raw trial data with index pairs and the outcome
%        indices - structure with indices (for pairs, outcome, nTrials columns), 
%                  these are assigned in the main data analysis code
% Output: concatData - new, concatenated data structure
% 
% 12/18/2017    ar, dhb Wrote it

uniqueStimuli = unique(trialData(:,indices.stimPairs ),'rows');
nStimuli = size(trialData,1);
nUniqueStimuli = size(uniqueStimuli,1);
concatData = zeros(nUniqueStimuli,indices.nTrials);
for rr = 1:nUniqueStimuli
    concatData(rr,indices.stimPairs) = uniqueStimuli(rr,:);
    for jj = 1:nStimuli
        if (all(trialData(jj,indices.stimPairs) == uniqueStimuli(rr,:)))
            if (trialData(jj,indices.response1) == 1)
                concatData(rr,indices.response1) = concatData(rr,indices.response1) + 1;
            end
            concatData(rr,indices.nTrials ) = concatData(rr,indices.nTrials ) + 1;
        end
    end
end
