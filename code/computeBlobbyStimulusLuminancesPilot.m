% computeBlobbyStimulusLuminancePilot
% Loads Blobby images and computes mean. 

% Feb 2018 ar  Adapted it from similar code used for illumination
% discriminaiton. 

% Initialize
clear; close all;

% Some params
nTests = 7;
calNumber = 11;
expDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_temp/ColorMaterial/Pilot/ColorMatStimuliRGB/';
calFileName = 'EyeTrackerLCD'; 

% Specify color matching function for conversion
% Note that the numbers are slightly different depending on the color
% matching functions one chooses.
S = [380     2   201];
wls = SToWls(S);
whichCMF = 'XYZ_1931'; 
switch whichCMF
    case 'XYZ_Phys2'
        load T_xyzCIEPhys2
        T_sensorXYZ = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);
    case 'XYZ_1931'
        load T_xyz1931
        T_sensorXYZ=683*SplineCmf(S_xyz1931, T_xyz1931, S);
end

% Set up a calibration file. 
cal = LoadCalFile(calFileName, calNumber);
cal = SetGammaMethod(cal, 0);
cal = SetSensorColorSpace(cal, T_sensorXYZ,  S);

for t  = 1:nTests
    load([expDir, 'C' num2str(t) 'M4' '-RGB.mat']);
    materialMatch(t,:) = computeImageMeanFromSettingsBlobby(cal, sensorImageRGB)'; clear sensorImageRGB;
    clear sensorImageRGB;
    
    load([expDir, 'C4M' num2str(t) '-RGB.mat']);
    colorMatch(t,:) = computeImageMeanFromSettingsBlobby(cal, sensorImageRGB)'; clear sensorImageRGB;
    clear sensorImageRGB;
end