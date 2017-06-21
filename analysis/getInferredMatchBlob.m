function [matchDerived, positionDerived] = getInferredMatchBlob(competitorsInLAB, referenceComp1, comp, yFit, xFit)
%function [matchDerived, positionDerived] = getInferredMatchBlob(target, referenceComp1, comp, yFit, xFit)

% Helper function for finding the position of the inferred match and its
% LAB coordinates for the 
% Input
% competitorsInLAB - the values of all competitors in Lab
% referenceComp1 and comp - indices of competitors between which the target
% falls
% yFit - derived positions of all competitors on some subjective dimension based on the MLDS fit 
% xFit - derived positions of the match on this subjective dimension. 
% Output
% matchDerived - position of the inferred match in LAB
% positionDerived - position of the inferred match in the competitor space.
% 
% 04/09/13 ar Wrote it. 

ratio = (yFit(comp)-xFit)/(yFit(comp)-yFit(referenceComp1)); % compute how far is it from the higher competitor and divide by their distance.
adjustColor = (competitorsInLAB(:,comp)-competitorsInLAB(:,referenceComp1))*ratio; % get the distance between the two competitors from color coordinates
matchDerived  = competitorsInLAB(:,comp)-adjustColor;
positionDerived = comp - ratio;

end

