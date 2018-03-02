function [ imageMean ] = computeImageMeanFromSettingsBlobby(cal, imageSettings)
[temp,nX,nY] = ImageToCalFormat(imageSettings);

imagePixelsXYZ = SettingsToSensor(cal, temp); 
imageMean = XYZToxyY(mean(imagePixelsXYZ,2));
end
