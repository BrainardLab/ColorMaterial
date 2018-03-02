%function [materialMatchColorCoords, colorMatchMaterialCoords] = generatePositionsFromCubicParams
function [materialMatchColorCoords, colorMatchMaterialCoords] = generatePositionsFromCubicParams
% Returns positions on color/material dimension that corespond to a cubic
% model. 
% Output:
% materialMatchColorCoords - recovered positions on color dimension for
%                            given paramters. 
% colorMatchMaterialCoords - recovered positions on material dimension for
%                            given paramters. 

% 02/09/17  ar Wrote it. 
currentDir  = pwd; 

for i  = 1:10
    cd(currentDir)
% get the paramters we used in the experiment, these will limit the range from which we draw the parametes.  
params = getQuestParamsExp3; 
nSamples = 100; 
tempLin = linspace(params.Lin(1), params.Lin(end), nSamples); 
tempQuad = linspace(params.Quad(1), params.Quad(end), nSamples); 
tempCubic = linspace(params.Cubic(1), params.Cubic(end), nSamples); 

% randomly draw parameters for a cubic model for each dimension. 
randomLinC = tempLin(round(rand(1)*nSamples)); 
randomQuadC = tempQuad(round(rand(1)*nSamples)); 
randomCubicC = tempCubic(round(rand(1)*nSamples)); 

randomLinM = tempLin(round(rand(1)*nSamples)); 
randomQuadM = tempQuad(round(rand(1)*nSamples)); 
randomCubicM = tempCubic(round(rand(1)*nSamples)); 

cd(getpref('ColorMaterial', 'mainExpDir')); 
cd('analysis/')
modelParams = getqPlusPilotExpParams; 
modelParams.whichPositions = 'smoothSpacing'; 
modelParams.smoothOrder = 1; 

w = 1; 
sigma = 1; 

% reformat into positions from paramters. 
% x = [randomLinC, randomQuadC, randomCubicC, randomLinM, randomQuadM, randomCubicM,w, sigma]; 
x = [randomLinC, randomLinM, w, sigma]; 
[materialMatchColorCoords(i,:),colorMatchMaterialCoords(i,:),~,~] = ColorMaterialModelXToParams(x,modelParams)

% figure
figure; clf; hold on; 
plot(1:7, materialMatchColorCoords, 'bo-')
plot(1:7, colorMatchMaterialCoords, 'ro-')
axis([0 8 -20 20])
end
end