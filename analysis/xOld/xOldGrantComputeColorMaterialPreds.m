function [thePreds,indifferenceNeg,indifferencePos] = ComputeColorMaterialPreds(theVals,theScaleNeg,theScalePos,theShape,theMin,theRange)

FORCE_ASYMPTOTE = true;
if (FORCE_ASYMPTOTE)
    theRange = 1-theMin;
end

thePreds = NaN*ones(size(theVals));
index = find(theVals < 0);
if (~isempty(index))
    thePreds(index) = theMin+theRange*wblcdf(abs(theVals(index)),theScaleNeg,theShape);
    if (theMin > 0.5)
        indifferenceNeg = NaN;
    elseif (theMin == 0.5)
        indifferenceNeg = 0;
    else
        % theMin + theRange*p = 0.5;
        invP = (0.5-theMin)/theRange;
        indifferenceNeg = -wblinv(invP,theScaleNeg,theShape);
    end
else
    indifferenceNeg = NaN;
end
index = find(theVals >= 0);
if (~isempty(index))
    thePreds(index) = theMin+theRange*wblcdf(abs(theVals(index)),theScalePos,theShape);
    if (theMin > 0.5)
        indifferencePos = NaN;
    elseif (theMin == 0.5)
        indifferencePos = 0;
    else
        % theMin + theRange*p = 0.5;
        invP = (0.5-theMin)/theRange;
        indifferencePos = wblinv(invP,theScalePos,theShape);
    end
else
    indifferencePos = NaN;
end
