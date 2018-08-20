% ConvertMSImageToRGBColorMaterialExp2
% Converts out hyperspectral stimulus images to RGB for display

% 02/11/15 ar Wrote it.
% 12/08/17 ar Adapted it for Experiment 2/3. 

% Initialize
clear; close all;

% Define directories
multispectralDataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-03-Aug-2017/renderings/Mitsuba';
LMSdataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-03-Aug-2017/LMS';
RGBdataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-03-Aug-2017/RGB';

% Load color matching functions, prepare calibration file.
load T_cones_ss2
S = [400, 10, 31];
cal = LoadCalFile(getpref('ColorMaterial','calFileName'),[],getpref('BrainardLabToolbox','CalDataFolder'));
cal = SetGammaMethod(cal, 0);
calLMS = SetSensorColorSpace(cal, T_cones_ss2,  S_cones_ss2);

% Define parameters
load('Exp3ImageList.mat')

% Scaling factor (HARDCODED, based on finding the max primary)
scaleTo = 1;
maxPrimary = 1.9*scaleTo; % this is the one for the new set of stimuli. 

% Create image lists with respect to parameters defined above .
calData.maxPrimary = maxPrimary; 
calData.date = cal.describe.date; 
calData.calFileName = getpref('ColorMaterial','calFileName');   

% Convert the images from MS to LMS to rgb.
% Because these are not rendered relative to the monitor calibration, we
% have to scale them to fit the gamut.
tic
for i = 1:length(imageList.imageName)
    fprintf('Image %s\n', imageList.imageName{i}); 
    % Pick and image and its new name
    cd(multispectralDataFolder);
    thisImageName = imageList.imageName{i};
    image = load([imageList.imageName{i} , '.mat']);
    
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
        error('Settings out of range.');
    end
    % Convert the scaled primaries to RGB and save. 
    [gamut,~] = PrimaryToGamut(calLMS,uncorrectedRGB);
    settings = GamutToSettings(calLMS,gamut);
    sensorImageRGB = CalFormatToImage(settings, m, n);
    cd(RGBdataFolder);
    save([thisImageName, '-RGB.mat'], 'sensorImageRGB', 'calData')
    clear sensorImageLMS imageName image temp tempRGB uncorrectedRGB sensorImageRGB settings gamut
end
toc