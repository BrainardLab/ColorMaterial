%convertMSImageToRGBColorMaterial
% converts beautiful stimuli Nicolas made to RGB for display

% 2/11/15 ar Wrote it.

% Initialize
clear all; close;

% Define directories
multispectralDataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-28-Apr-2017/renderings/Mitsuba';
LMSdataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-28-Apr-2017/LMS';
RGBdataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-28-Apr-2017/RGB';

% Load color matching functions, prepare calibration file.
load T_cones_ss2
S = [400, 10, 31];
cal = LoadCalFile('EyeTrackerLCD');
cal = SetGammaMethod(cal, 0);
calLMS = SetSensorColorSpace(cal, T_cones_ss2,  S_cones_ss2);

% Define parameters
alphaLevels = {'0.0070', '0.0200', '0.0500', '0.1000', '0.1500', '0.2000', '0.4000'};
lambdaLevels = {'0.500', '0.530', '0.570', '0.600', '0.630', '0.670', '0.700'};
targetLambda = 4; % color
targetAlpha = 4; % material
scaleTo = 1;%

maxPrimary = 1.63; % this is the one for the new set of stimuli. 
% Create image lists with respect to parameters defined above .
for i = 1:length(alphaLevels)
    imageListMat{i} = ['Exp2NCC' num2str(targetLambda), 'M' num2str(i)];
end
for i = 1:length(lambdaLevels)
    imageListColor{i} = ['Exp2NCC' num2str(i) 'M' num2str(targetAlpha)];
end
imageList = union(imageListColor, imageListMat);

% Convert the images from MS to LMS to rgb.
% Because these are not rendered relative to the monitor calibration, we
% have to scale them to fit the gamut.
tic
for i = 1:length(imageList)
    % Pick and image and its new name
    cd(multispectralDataFolder);
    thisImageName = imageList{i};
    image = load([imageList{i} , '.mat']);
    
    % Convert the image to LMS and save it.
    sensorImageLMS = MultispectralToSensorImage(image.multispectralImage, image.S, T_cones_ss2, S_cones_ss2);
    cd(LMSdataFolder);
    save([thisImageName, '-LMS.mat'], 'sensorImageLMS')
    
    % Convert it from LMS to rgb
    [temp,m,n] = ImageToCalFormat(sensorImageLMS);
    uncorrectedRGB = SensorToPrimary(calLMS, temp); % get gamma-uncorrected settings
    thisMax(i) = max(uncorrectedRGB(:));
    uncorrectedRGB = uncorrectedRGB./maxPrimary;
    uncorrectedRGB = uncorrectedRGB.*scaleTo;
    % check for pixels that are out of gamut (should not be any on the
    % high-end. 
    if sum(uncorrectedRGB(uncorrectedRGB>1))>1
        error('Settings out of range.');
    end
    if (sum(uncorrectedRGB(uncorrectedRGB<0)))
        disp(sum(uncorrectedRGB(uncorrectedRGB<0)))
    end
    % Convert the scaled primaries to RGB and save. 
    [gamut,~] = PrimaryToGamut(calLMS,uncorrectedRGB);
    settings = GamutToSettings(calLMS,gamut);
    sensorImageRGB = CalFormatToImage(settings, m, n);
    cd(RGBdataFolder);
    save([thisImageName, '-RGB.mat'], 'sensorImageRGB')
    clear sensorImageLMS imageName image temp tempRGB uncorrectedRGB sensorImageRGB settings gamut
end
toc