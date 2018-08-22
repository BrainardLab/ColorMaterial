% findImagesInListE1P2b.m
% used to integrate across parts of the experiment 2. 
clear; close all; 
subjectName = 'mdc'; % nsk (only for subject mdc and nsk)
compList = load(['/Users/Shared/Matlab/Experiments/ColorMaterial/code/Exp2Individualized/' subjectName 'stimulusList.mat']);
load(['/Users/Shared/Matlab/Experiments/ColorMaterial/code/Exp2Individualized/' subjectName 'stimulusList2b.mat']);

nTrialsPerCondition = 49; 
nTrialsPerConditionNew = 42; 
nConditions  = 3; 
for whichCondition = 1:nConditions
    startFrom(whichCondition) = (whichCondition-1)*nTrialsPerCondition+1;
    endAt(whichCondition) = nTrialsPerCondition*whichCondition;
    
    startFromNew(whichCondition) = (whichCondition-1)*nTrialsPerConditionNew+1;
    endAtNew(whichCondition) = nTrialsPerConditionNew*whichCondition;
    
    images = imageList;
    clear list
    list  = {compList.imageList{startFrom:endAt}};
    
    tmpString = intersect(images,list);
    whichIndexOld{whichCondition} = [];
    whichIndexNew{whichCondition} = [];
   
    for i = 1:length(tmpString)
        stringIndex(i, :) = (strfind(list, {tmpString{i}}));
        for j = 1:length(stringIndex(i,:))
            if isempty(stringIndex{i,j})
                %do nothing
            elseif (stringIndex{i,j}==1)
                whichIndexOld{whichCondition} = [whichIndexOld{whichCondition},j];
                for k = 1:length(images)
                    if strcmp(images{k}, list{(whichIndexOld{whichCondition}(end))})
                      %  disp('j')
                        whichIndexNew{whichCondition} = [whichIndexNew{whichCondition},k];
                    end
                end
            end
        end
    end
    
    for i = 1:length(images)
        switchString{i} = [images{i}(1:5) images{i}(16:end) '-' images{i}(6:14)];
        tmpString2 = intersect(switchString,list);
    end
    
    for i = 1:length(tmpString2)
        stringIndex(i, :) = (strfind(list, {tmpString2{i}}));
        for j = 1:length(stringIndex(i,:))
            if isempty(stringIndex{i,j})
                %do nothing
            elseif (stringIndex{i,j}==1)
                whichIndexOld{whichCondition} = [whichIndexOld{whichCondition},j];
                for k = 1:length(images)
                    if strcmp(switchString{k}, list{(whichIndexOld{whichCondition}(end))})
                       % disp('k')
                        whichIndexNew{whichCondition} = [whichIndexNew{whichCondition},k];
                    end
                end
           end
        end
    end
end

whichIndexOldFull = [];
whichIndexNewFull = [];
for whichCondition = 1:nConditions
    for i = 1:length(whichIndexOld{1})
        whichIndexOldFull = [whichIndexOldFull, (whichIndexOld{whichCondition}(i)+startFrom(whichCondition)-1)];
        whichIndexNewFull = [whichIndexNewFull, (whichIndexNew{whichCondition}(i)+startFromNew(whichCondition)-1)];
    end
end
indicesNonRepNewFull = setdiff([1:nConditions*nTrialsPerConditionNew],whichIndexNewFull); 

% find non-repeating new indices
save('E1P2abIndexMapping', 'whichIndexNew', 'whichIndexOld', 'whichIndexOldFull', 'whichIndexNewFull', 'indicesNonRepNew');