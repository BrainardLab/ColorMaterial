% checkTestLABDistancesPilot
% Writen post hoc, this code check the spacing of sample reflectances.  

% 01/xx/2018 ar Wrote it.

% Initialize 
clear all; 

% Get color matching functions
S = [400, 10, 31];
load T_xyzCIEPhys2
T_sensorXYZ = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);

% Define directories and load files. 
tempDir = '/Users/ana/Desktop/colorMaterial/BlobbieSceneReflectanceFunctions/';
tempL = load([tempDir 'CeilingLight/NeutralDay_0.30.spd']);

% Set levels
whichLevel = {'0.50', '0.53', '0.57', '0.60', '0.63', '0.67', '0.70'};

splineLight = SplineSpd(WlsToS(tempL(:,1)), tempL(:,2), S)*1000; 
whitePoint = T_sensorXYZ*splineLight; 

for i = 1:length(whichLevel)
    temp = load([tempDir 'Blobbie/diffuseSPD/NeutralDay_BlueGreen_' whichLevel{i} '.spd']);
    ref(:,i) = temp(:,2);clear temp
    spectra(:,i) = ref(:,i).*splineLight;
    XYZ(:,i) = T_sensorXYZ*spectra(:,i);
    Lab(:,i) = XYZToLab(XYZ(:,i),whitePoint); 
end
for t = 1:(length(whichLevel)-1)
    distNewY(t) = pdist([Lab(:,t)'; Lab(:,t+1)'], 'euclidean');
end