% function newCLab = findSpacedCompetitorsIllumChange(subjectMatchC, theGreenLABC, theGreenLABNC, theBlueLABC, theBlueLABNC, desiredDistance, constancyIndex);
function newCLab = findSpacedCompetitorsIllumChange(subjectMatchC, theGreenLABC, theGreenLABNC, theBlueLABC, theBlueLABNC, desiredDistance, constancyIndex);

% this is the error in constancy index estimation we will tolerate. 
tol = 0.002;

% for green and blue, slice the space from the tristimulus to reflectance match (perfect constancy).
for i = 1:3
    matchedConstGreenUnderBlue(:,i) = linspace(theGreenLABNC(i), theGreenLABC(i),10000);
    matchedConstBlueUnderBlue(:,i) = linspace(theBlueLABNC(i), theBlueLABC(i),10000);
end

% find the point on this line that corresponds to the constancy subject
% exhibited for this illumination change. 
% (GUCI = 'GreenUnderChangedIllumination', BUCI = 'BlueUnderChangedIllumination')
matchGUCI = matchedConstGreenUnderBlue(round(constancyIndex*10^4),:);
matchBUCI = matchedConstBlueUnderBlue(round(constancyIndex*10^4),:);

% to check that we found the right point, compute the constancy index that corresponds to these two points.
[~,~,CCImatchGUCI] = ...
    ComputeCCIndicesLab(theGreenLABNC, ...
    theGreenLABC, ...
    matchGUCI);

[~,~,CCImatchBUCI] = ...
    ComputeCCIndicesLab(theBlueLABNC, ...
    theBlueLABC, ...
    matchBUCI);

if abs((CCImatchBUCI-constancyIndex)) > tol
    error('CCI for blue is not well matched');
end
if abs((CCImatchGUCI-constancyIndex)) > tol
    error('CCI for green is not well matched');
end

% now we repeat the same steps as in the no change condition
% that is find competitors spaced in the blue and in the green direction
newCLab = findSpacedCompetitorsNC(subjectMatchC, matchGUCI, matchBUCI, desiredDistance);
end