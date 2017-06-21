function [matchDerived, positionDerived] = MLDSInferMatchBlob(fit, target)
% function [matchDerived, positionDerived] = MLDSInferMatchBlob(fit, target)
% From the solution of the MLDS fit, derive the position of the inferred
% match and its coordinates in the LAB space.
%
% Aug 2016    ar Adapted it from the MLDSCube version.

% How many competitors delineate the space.
nCompetitors = size(target,2);
xFit = fit(1);
yFit = fit(2:end);

% To find the position/Lab values we first need to identify where on the
% line of competitors does it fall - that is, which are the two reference competitors between which the match falls.
% Then we need to compute how far the
% match falls from the farther reference competitor (reference is always the one with
% the higher index). That is equal to the ratio of the form D = a/b where
% a = the distance between the farther reference competitor (comp) and the inferred
% match (from the fit values)
% b = the distance between the two reference matches (also from the fit
% values).
% We use this ratio to find the position of the inferred match
% (positionDerived) and the LAB coordinates (matchDerived).


% if xFit == 1 or it is just a bit smaller than the first competitor.
if xFit  == yFit(1) || (abs(xFit-yFit(1)) < (0.0001))
    comp = 1;
    matchDerived = target(:,comp);
    positionDerived = comp;
  
% if xFit falls between 1 and 2, including 2. 
elseif (xFit > yFit(1)) && (xFit <= yFit(2))
    comp = 2;
    referenceComp1 = 1;
    [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit);
    
% between 2 and 3 including 3; 
elseif xFit > yFit(2) && xFit <= yFit(3)
    comp = 3;
    referenceComp1 = 2;
    [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit);

% between 3 and 4 including 4; 
elseif (xFit > yFit(3)) && (xFit <= yFit(4))
    comp = 4;
    referenceComp1 = 3;
    [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit);

% between 4 and 5 including 5; 
elseif xFit > yFit(4) && xFit <= yFit(5)
    comp = 5;
    referenceComp1 = 4;
    [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit);
    
% if there are 7 competitors and xFit falls between 5 and 6
elseif (nCompetitors == 7) &&  xFit > yFit(5) && xFit <= yFit(6)
    comp = 6;
    referenceComp1 = 5;
    [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit);

% if there are 6 competitors and xFit falls between 6 and 7
elseif (nCompetitors ==7) &&  xFit > yFit(6) && xFit < yFit(7)
    comp = 7;
    referenceComp1 = 6;
    [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit);

    % if there are 6 competitors and xFit == 6
elseif (nCompetitors ==7) && xFit  == yFit(7)
    comp = 7;
    positionDerived = comp;
    matchDerived = target(:,comp);

% if there are 5 competitors and xFit == 5
elseif (nCompetitors ==5) && xFit  == yFit(5)
    comp = 5;
    positionDerived = comp;
    matchDerived = target(:,comp);

% out of range if there are 5 competitors.   
elseif (nCompetitors ==5) && xFit  > yFit(5)
    matchDerived = [Inf Inf Inf]';
    positionDerived = Inf;

% out of range if there are 6 competitors. 
elseif (nCompetitors ==6) && xFit  > yFit(6)
    matchDerived = [Inf Inf Inf]'; 
    positionDerived = Inf;

% out of range - falls lower than the first competitor (tristimulus match); 
elseif xFit  < yFit(1)
    matchDerived = [-Inf -Inf -Inf]'; 
    positionDerived = -Inf;
    
% no other predicted outcomes.    
else 
    matchDerived = [NaN NaN NaN]';
    positionDerived = NaN;
    
end
end

