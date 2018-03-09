clear; close all;

for i = 1:10
    if i == 1
        DO_INITIALIZE = true;
    else
        DO_INITIALIZE = false;
    end
    whichDistance = 'euclidean';
    qpSimulationCubic(whichDistance, num2str(i), DO_INITIALIZE)
end