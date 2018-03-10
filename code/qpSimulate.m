clear; close all;

for k = 1:2
    if k == 1
        whichDistance = 'euclidean';
    elseif k == 2
        whichDistance = 'cityblock';
    end
    for j = 1:2
        if j == 1
            whichSmoothSpacing = 3;
        elseif j == 2
            whichSmoothSpacing = 1;
        end
        for i = 1:10
            if i == 1
                DO_INITIALIZE = true;
            else
                DO_INITIALIZE = false;
            end
            qpSimulationCubic(whichDistance, whichSmoothSpacing, filename, DO_INITIALIZE)
        end
    end
end