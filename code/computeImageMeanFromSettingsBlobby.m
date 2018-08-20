function [ imageMean ] = computeImageMeanFromSettingsBlobby(cal, imageSettings)

% function [ imageMean ] = computeImageMeanFromSettingsBlobby(cal, imageSettings)
% helper function for computing mean images from settings and the desired
% calibration file. 

[temp,~,~] = ImageToCalFormat(imageSettings);

imagePixelsXYZ = SettingsToSensor(cal, temp); 
imageMean = XYZToxyY(mean(imagePixelsXYZ,2));
end
