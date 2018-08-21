function [f,thePreds,indifferenceNeg,indifferencePos] = FitToColorMaterialFun(x,theVals,theData)

theScaleNeg = x(1);
theScalePos = x(2);
theShape = x(3);
theMin = x(4);
theRange = x(5);

[thePreds,indifferenceNeg,indifferencePos] = ...
    ComputeColorMaterialPreds(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange);

if (nargin > 2)
    theDiff = theData-thePreds;
    f = sqrt(mean(theDiff.^2));
else
    f = [];
end


