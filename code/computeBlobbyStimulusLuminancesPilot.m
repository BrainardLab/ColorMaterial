% computeBlobbyStimulusLuminancePilot
% Loads Blobby images and computes mean. 

% Feb 2018 ar  Adapted it from similar code used for illumination
% discriminaiton. 

% Initialize
clear; close all;

% Some params
whichExperiment = 'E3';
switch whichExperiment
    case 'Pilot'
        calFileName = 'EyeTrackerLCD'; 
        tmpDir = getpref('ColorMaterial', 'stimulusFolder');
        expDir = [tmpDir(1:47) 'CNST_temp/ColorMaterial/Pilot/ColorMatStimuliRGB/'];
        nTests = 7;
        calNumber = 11;

    case 'E3'      
        calFileName = 'ColorMaterialCalibration'; 
        expDir = getpref('ColorMaterial', 'stimulusFolder');
        calNumber = 1;
end

% Specify color matching function for conversion
% Note that the numbers are slightly different depending on the color
% matching functions one chooses.
S = [380     2   201];
wls = SToWls(S);
whichCMF = 'XYZ_Phys2'; 
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
switch whichExperiment
    case 'Pilot'
        for t  = 1:nTests
            load([expDir, 'C' num2str(t) 'M4' '-RGB.mat']);
            materialMatch(t,:) = computeImageMeanFromSettingsBlobby(cal, sensorImageRGB)'; clear sensorImageRGB;
            clear sensorImageRGB;
            
            load([expDir, 'C4M' num2str(t) '-RGB.mat']);
            colorMatch(t,:) = computeImageMeanFromSettingsBlobby(cal, sensorImageRGB)'; clear sensorImageRGB;
            clear sensorImageRGB;
        end
    case 'E3'
        load('Exp3ImageList.mat')
        for i = 1:length(imageList.imageName)
            tempImage = load([expDir '/' imageList.imageName{i} '-RGB.mat']);
            thisStimulus(i,:) = computeImageMeanFromSettingsBlobby(cal, tempImage.sensorImageRGB)'; clear tempImage;
        end
end