%findImagesInList.m

images = imageList; 
list  = compList.imageList; 

tmpString = intersect(images,list); 
whichIndex = []; 
for i = 1:length(tmpString)
    stringIndex(i, :) = (strfind(list, {tmpString{i}}));
    for j = 1:length(stringIndex(i,:))
        if isempty(stringIndex{i,j})
            %do nothing
        elseif (stringIndex{i,j}==1)
            whichIndex = [whichIndex,j];
        end
    end
end

 
for i = 1:length(images)
    changeString{i} = [images{i}(1:5) images{i}(16:end) '-' images{i}(6:14)]; 
    tmpString2 = intersect(changeString,list);
end

for i = 1:length(tmpString2)
    stringIndex(i, :) = (strfind(list, {tmpString2{i}}));
    for j = 1:length(stringIndex(i,:))
        if isempty(stringIndex{i,j})
            %do nothing
        elseif (stringIndex{i,j}==1)
            whichIndex = [whichIndex,j];
        end
    end
end
