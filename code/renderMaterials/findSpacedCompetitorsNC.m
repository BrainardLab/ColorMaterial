%function newNCLab = findSpacedCompetitorsNC(subjectMatchNC, theGreenLAB, theBlueLAB, desiredDistance)
function newNCLab  = findSpacedCompetitorsNC(subjectMatchNC, theGreenLAB, theBlueLAB, desiredDistance)

% this function returns the set of 7 values which are all
% spaced by desired distance.
% the center is the subjects' match in the NC condition. 
% three competitors are on the match-BlueNC line. 
% three competitors are on the match-GreenNC line. 

% 07/27/2016 ar Wrote it. 

% Space out the distance between the subject's match and the ends to the
% forth decimal point. 
tol = 0.01; 

for i = 1:3
    tmpGreens(i,:) = linspace(theGreenLAB(i),subjectMatchNC(i),10000);
    tmpBlues(i,:) = linspace(theBlueLAB(i),subjectMatchNC(i),10000);
end

% find how big is the smallest step. 
smallestGreen = pdist([tmpGreens(:,end-1)'; tmpGreens(:,end)'], 'euclidean');
thisGreenIndex = round((desiredDistance/smallestGreen));

smallestBlue = pdist([tmpBlues(:,end-1)'; tmpBlues(:,end)'], 'euclidean');
thisBlueIndex = round((desiredDistance/smallestBlue));

toGreen(:,1) = tmpGreens(:,end-thisGreenIndex); 
toGreen(:,2) = toGreen(:,1) - (subjectMatchNC-tmpGreens(:,end-thisGreenIndex)); 
toGreen(:,3) = toGreen(:,2) - (subjectMatchNC-tmpGreens(:,end-thisGreenIndex)); 

toBlue(:,1) = tmpBlues(:,end-thisBlueIndex);
toBlue(:,2) = toBlue(:,1) - (subjectMatchNC - tmpBlues(:,end-thisBlueIndex));
toBlue(:,3) = toBlue(:,2) - (subjectMatchNC - tmpBlues(:,end-thisBlueIndex));

newNCLab = [toGreen(:,3), toGreen(:,2), toGreen(:,1), subjectMatchNC, toBlue];

% check distance.
for c = 1:(size(newNCLab,2)-1)
    dist(c) = pdist([newNCLab(:,c)'; newNCLab(:,c+1)'], 'euclidean');
    if abs((dist(c)-desiredDistance)) > tol
        error;
    end
end
figure; 
subplot(1,2,1); hold on
for i = 1:7
    if i == 4
        plot(newNCLab(2,i), newNCLab(3,i),'kx');
    end
    plot(newNCLab(2,i), newNCLab(3,i),'ro');
    plot(theGreenLAB(2),theGreenLAB(3), 'go')
    plot(theBlueLAB(2),theBlueLAB(3), 'bo')
end
xlabel('a')
ylabel('b')

subplot(1,2,2); hold on
for i = 1:7
    if i == 4
    plot(newNCLab(1,i), newNCLab(3,i),'kx');
    end
    plot(newNCLab(1,i), newNCLab(3,i),'ro');
    plot(theGreenLAB(1),theGreenLAB(3), 'go')
    plot(theBlueLAB(1),theBlueLAB(3), 'bo')
end
xlabel('L')
ylabel('b')

end




