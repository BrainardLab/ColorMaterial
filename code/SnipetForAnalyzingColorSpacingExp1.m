% Snipet to be used to judge spacing in the previous study. 
clear; close all
% load color matching functions. 
load T_xyzCIEPhys2
S = [400     10    31];
T_sensor = 683*SplineCmf(S_xyzCIEPhys2, T_xyzCIEPhys2, S); 

% load illuminant
tempIllum = load('/Users/radonjic/Desktop/BlobbiesForAna/3.RT3scripts/3.Resources/NewStuff/NeutralDay_0.30.spd'); 
illum = SplineSpd([380     5    81], tempIllum(:,2), [400     10    31]); 
whitePoint = T_sensor*illum; 

colorSamples = [0.50,0.53,0.57,0.60,0.63,0.67,0.70];
for c = 1:length(colorSamples)
    % input here ; 
    tempC = load(['/Users/radonjic/Desktop/BlobbiesForAna/3.RT3scripts/3.Resources/NewStuff/R1_NeutralDay_BlueGreen_' num2str(colorSamples(c)) '.spd']); 
    cRef(:,c) = tempC(:,2); 
    cXYZ(:,c) = T_sensor*(cRef(:,c).*illum);
    cLAB(:,c) = XYZToLab(cXYZ(:,c), whitePoint); 
end

for c = 1:length(colorSamples)
    dist(c) = [pdist([cLAB(:,c)'; cLAB(:,4)'])]; 
end

% dist space
distSpacing = []
for c = 1:(length(colorSamples)-1)
    distSpacing = [distSpacing, pdist([cLAB(:,c)'; cLAB(:,c+1)'])]; 
end



