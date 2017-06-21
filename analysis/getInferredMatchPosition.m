function positionDerived = getInferredMatchPosition(fit, nCompetitors)

xFit = fit(1);
yFit = fit(2:end);



if xFit  == yFit(1) || (abs(xFit-yFit(1)) < (0.0001))
    positionDerived = 1;
elseif xFit  < yFit(1)
    positionDerived = -Inf;
elseif xFit  > yFit(nCompetitors)
    positionDerived = Inf;
elseif (xFit  > yFit(1)) || xFit  < yFit(xFit  < yFit(1))
    for c = 2:nCompetitors
        if (xFit > yFit(c-1)) && (xFit <= yFit(c))
            ratio = (yFit(c)-xFit)/(yFit(c)-yFit(c-1)); % compute how far is it from the higher competitor and divide by their distance.
            positionDerived = c - ratio;
        end
    end
else
    positionDerived = NaN;
end

end
