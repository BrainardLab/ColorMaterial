% combineDataAcrossExperiments. 
% In Experiment 2 we ran some additional trials. 
% Here we combine this data, for analysis

% Note that a check which compares the reliability of the two data sets by
% looking at probabilities for the trials that have been repeated 
% is NOT yet implemented. 

% Initialize
clear; close all;  

% First set of data
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/'; 
subjectName = 'nsk'; 
a = load([mainDir [subjectName 'SummarizedData.mat']]);

% Second set of data
b = load([mainDir [subjectName 'SummarizedData2b.mat']]);

% mapping 
load('E1P2abIndexMapping.mat')

% need to reconstruct the data matrix.
% find blocks that are repeating and append them.
nBlocks = length(a.thisSubject.block);
nTrials = length(a.thisSubject.block(1).trial);

for whichReplaceIndex = 1:length(whichIndexOldFull)
    for whichBlock = 1:nBlocks
        for t = 1:length(a.thisSubject.block(1).trial)
            % we need to append this same type of trials on the 'other side' (i.e., blocks 25-48)
            if ~isempty(intersect(t,whichIndexOldFull))
                a.thisSubject.block(whichBlock+nBlocks).trial(whichIndexOldFull(whichReplaceIndex)) = ...
                    b.thisSubject.block(whichBlock).trial(whichIndexNewFull(whichReplaceIndex));
                
                s1 = a.thisSubject.block(whichBlock+nBlocks).trial(whichIndexOldFull(whichReplaceIndex)).stimulusOneName;
                s2 = a.thisSubject.block(whichBlock+nBlocks).trial(whichIndexOldFull(whichReplaceIndex)).stimulusTwoName;
                s3 = b.thisSubject.block(whichBlock).trial(whichIndexNewFull(whichReplaceIndex)).stimulusOneName;
                s4 = b.thisSubject.block(whichBlock).trial(whichIndexNewFull(whichReplaceIndex)).stimulusTwoName;
                if (strcmp(s1,s3) + strcmp(s2,s4))~=2
                    error('Incorrect stimuli matched!');
                end
                clear s1 s2 s3 s4
            else % otherwise just add nans
                a.thisSubject.block(whichBlock+nBlocks).trial(t) = ...
                    a.thisSubject.block(whichBlock).trial(t);
                a.thisSubject.block(whichBlock+nBlocks).trial(t).imageChosen = NaN;
            end
        end
    end
end

% I did not do this correctly. 
% find indices of in 2b that are not repeating in 2a and append them.
%(b.thisSubject.nTrialsPerCondition*whichCondition-1)
n = 0; 
for whichReplaceIndex = 1:length(indicesNonRepNew)
    for whichBlock = 1:nBlocks
        a.thisSubject.newCondition.block(whichBlock).trial(whichReplaceIndex) = b.thisSubject.block(whichBlock).trial(indicesNonRepNew(whichReplaceIndex));
        a.thisSubject.newCondition.block(whichBlock+nBlocks).trial(whichReplaceIndex) = b.thisSubject.block(whichBlock).trial(indicesNonRepNew(whichReplaceIndex));
        a.thisSubject.newCondition.block(whichBlock+nBlocks).trial(whichReplaceIndex).imageChosen = NaN;
        n = n + 1; 
    end
end

% Reorganize the whole matrix. 
startFrom = [1, 50, 99];
endAt = [49, 98, 147];
aIndices = [1:49];
bIndices = [1:30];
nConditions = 3; 
nBlocks = length(a.thisSubject.block); 

for whichCondition = 1:nConditions
    for whichBlock = 1:48
        for t = 1:length(aIndices)
            thisSubject.condition{whichCondition}.block(whichBlock).trial(t) = a.thisSubject.block(whichBlock).trial(t+startFrom(whichCondition)-1);
            if whichCondition == 1
                if t~=(t+startFrom(whichCondition)-1)
                    error; 
                end
            end
        end
    end
end

startFrom = [1, 31, 61];
countFrom = length(aIndices); 
for whichCondition = 1:nConditions
    for whichBlock = 1:48
        for t = 1:length(bIndices)
            thisSubject.condition{whichCondition}.block(whichBlock).trial(t+countFrom) = ...
                a.thisSubject.newCondition.block(whichBlock).trial(t+startFrom(whichCondition)-1);
            if whichCondition == 1
                if t~=(t+startFrom(whichCondition)-1)
                    error; 
                end
            end
        end
    end
end

newImageList = [];
for whichCondition = 1:nConditions
    for whichBlock = 1
        for whichTrial = 1:length(thisSubject.condition{whichCondition}.block(whichBlock).trial)
            tmpString = {[char(thisSubject.condition{whichCondition}.block(whichBlock).trial(whichTrial).stimulusOneName) ...
                '-' char(thisSubject.condition{whichCondition}.block(whichBlock).trial(whichTrial).stimulusTwoName)]}; 
            newImageList = [newImageList,tmpString ]; clear tmpString
        end
    end
end
save(['E1P2CompleteStimulusList'], 'newImageList')

clear startFrom
startFrom   = [1 80 159];        
endAt = [79 158 237]; 

nTrails = length(thisSubject.condition{whichCondition}.block(whichBlock).trial);
for whichCondition = 1:nConditions
    thisSubject.condition{whichCondition}.imageList = newImageList(startFrom(whichCondition):endAt(whichCondition));
    thisSubject.condition{whichCondition}.chosenAcrossTrials = NaN(nTrails, nBlocks);
    thisSubject.condition{whichCondition}.firstChosenAcrossTrials = NaN(nTrails, nBlocks);
    
    for whichBlock = 1:24%nBlocks
        for t = 1:nTrails
            if ~isnan(thisSubject.condition{whichCondition}.block(whichBlock).trial(t).imageChosen)
                thisSubject.condition{whichCondition}.chosenAcrossTrials(t,whichBlock) = ...
                    thisSubject.condition{whichCondition}.block(whichBlock).trial(t).imageChosen;
                
                thisSubject.condition{whichCondition}.firstChosenAcrossTrials(t,whichBlock) = ...
                    thisSubject.condition{whichCondition}.block(whichBlock).trial(t).imageChosen==1;
            end
        end
    end
    
    thisSubject.condition{whichCondition}.totalTrials = sum(~isnan(thisSubject.condition{whichCondition}.chosenAcrossTrials),2);
    thisSubject.condition{whichCondition}.firstChosen = nansum(thisSubject.condition{whichCondition}.chosenAcrossTrials==1,2);
    thisSubject.condition{whichCondition}.pFirstChosen = thisSubject.condition{whichCondition}.firstChosen./thisSubject.condition{whichCondition}.totalTrials;

end
cd(mainDir)
save([subjectName 'CompleteData.mat'], 'thisSubject')