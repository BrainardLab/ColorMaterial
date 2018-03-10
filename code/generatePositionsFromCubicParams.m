%function [materialMatchColorCoords, colorMatchMaterialCoords] = generatePositionsFromCubicParams(nSets, whichSmoothSpacing)
function [materialMatchColorCoords, colorMatchMaterialCoords] = generatePositionsFromCubicParams(nSets, whichSmoothSpacing)
% Returns positions on color/material dimension that corespond to a cubic
% model.
% Input:
%   nSets - how many sets to produce.
%   whichSmoothSpacing - determine the order of the polynomial for smooth spacing.
% Output:
%   materialMatchColorCoords - recovered positions on color dimension for
%                            given paramters.
%   colorMatchMaterialCoords - recovered positions on material dimension for
%                            given paramters.

% 02/09/17  ar Wrote it.
%
currentDir  = pwd;
params = getQuestParamsExp3;
nSamples = 100;

for i  = 1:nSets
    notMonotonic = true;
    while notMonotonic
        cd(currentDir)
        % get the paramters we used in the experiment, these will limit the range from which we draw the parametes.
        tempLin = linspace(params.Lin(1), params.Lin(end), nSamples);
        tempQuad = linspace(params.Quad(1), params.Quad(end), nSamples);
        tempCubic = linspace(params.Cubic(1), params.Cubic(end), nSamples);
        
        % randomly draw parameters for a cubic model for each dimension.
        randomLinC = tempLin(ceil(rand(1)*nSamples));
        randomQuadC = tempQuad(ceil(rand(1)*nSamples));
        randomCubicC = tempCubic(ceil(rand(1)*nSamples));
        
        randomLinM = tempLin(ceil(rand(1)*nSamples));
        randomQuadM = tempQuad(ceil(rand(1)*nSamples));
        randomCubicM = tempCubic(ceil(rand(1)*nSamples));
        
        cd([getpref('ColorMaterial', 'mainCodeDir'), '/analysis/']);
        modelParams = getqPlusPilotExpParams;
        cd([getpref('ColorMaterial', 'mainCodeDir'), '/code/']);
        
        modelParams.whichPositions = 'smoothSpacing';
        modelParams.smoothOrder = whichSmoothSpacing;
        
        tempW = NaN; % just set to a missing value, we don't really need this
        sigma = 1;
        
        % reformat into positions from paramters.
        if modelParams.smoothOrder == 1
            x = [randomLinC, randomLinM, tempW, sigma];
        elseif modelParams.smoothOrder == 2
            x = [randomLinC, randomQuadC, randomLinM, randomQuadM,tempW, sigma];
        elseif modelParams.smoothOrder == 3
            x = [randomLinC, randomQuadC, randomCubicC, randomLinM, randomQuadM, randomCubicM,tempW, sigma];
        else
            error('this smooth order is not implemented');
        end
        [materialMatchColorCoords(i,:),colorMatchMaterialCoords(i,:),~,~] = ColorMaterialModelXToParams(x,modelParams);
        monotonicityCheck = (any(diff(materialMatchColorCoords(i,:))<0) || any(diff(colorMatchMaterialCoords(i,:))<0)); 
        positionsOutOfBoundCheck = (any(abs(materialMatchColorCoords(i,:))>20) || any(abs(colorMatchMaterialCoords(i,:))>20));  
        
        if monotonicityCheck && positionsOutOfBoundCheck
            % do nothing if it's monotonic and/or positions are out of
            % bound
            disp([materialMatchColorCoords(i,:), colorMatchMaterialCoords(i,:)])
        else
            notMonotonic = false;
        end
    end
    
%     % plot figure
%     figure; clf; hold on;
%     plot(1:7, materialMatchColorCoords(i,:), 'bo-')
%     plot(1:7, colorMatchMaterialCoords(i,:), 'ro-')
%     axis([0 8 -20 20])
end
end