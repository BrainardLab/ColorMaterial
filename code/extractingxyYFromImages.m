% extractxyYFromImages
% This script is used to calibrate the color steps for rendering the
% blobbys. Extracts values from rendered images. 

% 02/10/2016 ar Wrote it.
% 03/08/2016 ar Added options to create better spaced reflectances for the
% tests. Added many comments.

% Initialize
clear all; close;

% Define directories
multispectralDataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/NewTestCubeExp1-21-Jul-2016/renderings/Mitsuba';
multispectralDataFolder = '/Users1/Shared/Matlab/Experiments/Blobby/CheckColorSetBlobbyExp1-24-Jul-2016/renderings/Mitsuba';

writeDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials';
currentDir = pwd; 
writeSpectralFiles = 0; 

% Load color matching functions, prepare calibration file.
S = [400, 10, 31];
wls = SToWls(S);
extractLocation = 1;
% location from the top of the cube from which we extract illuminant (20 x
% 20 pixels)
load T_xyzCIEPhys2
T_sensorXYZ = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);

% set the calibration file for converting left image (via LMS)
cal = LoadCalFile('EyeTrackerLCD');
cal = SetGammaMethod(cal, 0);
cal = SetSensorColorSpace(cal, T_sensorXYZ,  S);

% other parameters
computeValues  = 1;
% areas of the image from we want to compute values from.
if computeValues
    xT1 = [120 88    88 148  88 148];
    yT1 = [630 398  398 398 862 862];
    xT2 = [140 168  108 168  108 168];
    yT2 = [650 882  418 418 882 882];
end

imageList = {'ExtendedTestNC','ExtendedTestCY','ExtendedTestCB'};
imageList = {'NCC1M4', 'NCC2M4', 'NCC3M4', ...
    'CYC1M4', 'CYC2M4', 'CYC3M4', ...
    'CBC1M4', 'CBC2M4', 'CBC3M4'};
% extract values from rendered images.
for i = 1:length(imageList)
    thisImageName = imageList{i};
    cd(multispectralDataFolder);
    load([imageList{i} , '.mat']);
    cd (currentDir)
    if i == 1
        spdWhite = squeeze(S(2)*getMeanPixelValue(multispectralImage, xT1(extractLocation), yT1(extractLocation), xT2(extractLocation), yT2(extractLocation)));
        if writeSpectralFiles
            cd(writeDir)
            WriteSpectrumFile(wls, spdWhite, sprintf('spdWhite.spd'));
            cd (currentDir)
        end
    elseif i == 2
        spdYellow = squeeze(S(2)*getMeanPixelValue(multispectralImage, xT1(extractLocation), yT1(extractLocation), xT2(extractLocation), yT2(extractLocation)));
        if writeSpectralFiles
            cd(writeDir)
            WriteSpectrumFile(wls, spdYellow, sprintf('spdYellow.spd'));
            cd (currentDir)
        end
    elseif i == 3
        spdBlue = squeeze(S(2)*getMeanPixelValue(multispectralImage, xT1(extractLocation), yT1(extractLocation), xT2(extractLocation), yT2(extractLocation)));
        if writeSpectralFiles
            cd(writeDir)
            WriteSpectrumFile(wls, spdBlue, sprintf('spdBlue.spd'));
            cd (currentDir)
        end
    end
    % Convert the image to XYZ and save it.
    sensorImageXYZ = MultispectralToSensorImage(multispectralImage, S, T_sensorXYZ, S);
    % Convert it to xyY and rgb
    [tempXYZ,m,n] = ImageToCalFormat(sensorImageXYZ);
    settings = SensorToSettings(cal, tempXYZ);
    tempxyY = XYZToxyY(tempXYZ);
    sensorImagexyY = CalFormatToImage(tempxyY, m, n);
    sensorImageRGB = CalFormatToImage(settings, m, n);
    if computeValues
        for k = 1:length(xT1)
            % just print these
            block{i}(k,:) = getMeanPixelValue(sensorImagexyY, xT1(k), yT1(k), xT2(k), yT2(k));
        end
    end
    % save([thisImageName, '-RGB.mat'], 'sensorImageRGB')
    clear sensorImagexyY settings tempXYZ
end
fprintf('done\n')