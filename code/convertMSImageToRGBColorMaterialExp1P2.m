% convertMSImageToRGBColorMaterial
% converts new stimuli for display

% 2/11/15 ar Wrote it.

% Initialize
clear ; close all;

% Define directories
subjectName = 'nsk';
multispectralDataFolder = ['/Users1/Shared/Matlab/Experiments/Blobby/' subjectName 'Part2StimulusSetBlobbyExp1-03-Nov-2016/renderings/Mitsuba'];
LMSdataFolder = ['/Users1/Shared/Matlab/Experiments/Blobby/' subjectName 'Part2StimulusSetBlobbyExp1-03-Nov-2016/LMS'];
RGBdataFolder = ['/Users1/Shared/Matlab/Experiments/Blobby/' subjectName 'Part2StimulusSetBlobbyExp1-03-Nov-2016/RGB'];
mainDir = pwd; 
% Load color matching functions, prepare calibration file.
load T_cones_ss2
S = [400, 10, 31];
cal = LoadCalFile('EyeTrackerLCD');
cal = SetGammaMethod(cal, 0);
calLMS = SetSensorColorSpace(cal, T_cones_ss2,  S_cones_ss2);

% Define parameters
conditionCode = {'NC','CB','CY'};
nCompetitors =[5, 7, 7];
nMatCompetitors = 7;
nConditions = length(conditionCode);
targetLambda = 3; % color
targetAlpha = 4; % material
scaleTo = 1;%0.9;%
maxPrimary = 1.6;%  
saveImages = 1;

% Create image lists with respect to parameters defined above .
imageList = [];
load([subjectName 'MSList.mat']); 
stimulusList = imageList;
% Convert the images from MS to LMS to rgb.
% Because these are not rendered relative to the monitor calibration, we
% have to scale them to fit the gamut.
tic
for i = 1: length(stimulusList)
    fprintf('Image %d\n',i)
    
    % Pick and image and its new name
    cd(multispectralDataFolder);
    thisImageName = stimulusList{i};
    image = load([stimulusList{i} , '.mat']);
    
    % Convert the image to LMS and save it.
    sensorImageLMS = MultispectralToSensorImage(image.multispectralImage, image.S, T_cones_ss2, S_cones_ss2);
    if saveImages
        cd(LMSdataFolder);
        save([thisImageName, '-LMS.mat'], 'sensorImageLMS')
    end
    
    % Convert it from LMS to rgb
    [temp,m,n] = ImageToCalFormat(sensorImageLMS);
    uncorrectedRGB = SensorToPrimary(calLMS, temp); % get gamma-uncorrected settings
    thisMax(i) = max(uncorrectedRGB(:));
    
    uncorrectedRGB = uncorrectedRGB./maxPrimary;
    uncorrectedRGB = uncorrectedRGB.*scaleTo;
    %
    % compute number of bad pixels.
    for jj = 1:length(uncorrectedRGB)
        more(jj) = any((uncorrectedRGB(:,jj)>1));
        less(jj) = any((uncorrectedRGB(:,jj)<0));
    end
    moreInd(i) = sum(more);
    lessInd(i) = sum(less);
    
    % Convert the scaled primaries to RGB and save.
    [gamut,~] = PrimaryToGamut(calLMS,uncorrectedRGB);
    settings = GamutToSettings(calLMS,gamut);
    
    sensorImageRGB = CalFormatToImage(settings, m, n);
    cd(mainDir)
   % figure; imshow(sensorImageRGB)
    sensorImageRGB = FixImageArtifactsExp1P1(sensorImageRGB, 15);
    
    if saveImages
        cd(RGBdataFolder);
        save([thisImageName, '-RGB.mat'], 'sensorImageRGB')
    end
    clear sensorImageLMS imageName image temp tempRGB uncorrectedRGB sensorImageRGB settings gamut
end
toc