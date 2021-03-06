% BlobbyHyperspectralToSRGB
% converts hyperspectral images to the images for the paper
% implements the tonemapping we describe in the paper. 

% Jan 2016 ar Wrote it. 
% May 2018 ar Adapted it as we're preparing images for the paper 

% Initialize
clear; close all;

% Load the hyperspectral image.

targetIm = {'C4M4'};%, 'C1M4', 'C7M4', 'C4M1', 'C4M7', 'C1M7', 'C7M1'}; 
picsDir = '/Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-03-Aug-2017/renderings/Mitsuba';

currentDir = pwd; 

scaleFactor = 650; 
fileList = {};
corrNameList = {};
toneMappingFactor  = 4; 

% load color matching functions
load T_xyz1931
S = [400    10    31];

T_sensorXYZ = 683*SplineCmf(S_xyz1931,T_xyz1931,S);
count = 0; 

tmpStr = {'C7M1', 'C1M7', 'C4M4', 'C7M4', 'C5M4',  'C3M4', 'C1M4', 'C4M1', 'C4M3',  'C4M5', 'C4M7'};
   
for s = 1:length(tmpStr)
    filename = [picsDir '/' 'Exp2NC' tmpStr{s} '.mat'];
    corrFilename = ['Corr2' tmpStr{s}];
    fileList = [fileList, filename];
    corrNameList = [corrNameList, corrFilename];
end

    
cd (picsDir)
for whichFile = 1:length(fileList)
    fprintf('Converting image %d.\n', whichFile)
    count = count+1;
    load(fileList{whichFile});
    
    % convert the hyperspectral image to XYZ, then convert XYZ to sRGB
    cd (currentDir)
    sensorImageXYZ = MultispectralToSensorImage(multispectralImage, S, T_sensorXYZ, S);
    cd (picsDir)
    
   
    % converts to linear primaries.
    [theXYZCalFormat,m,n] = ImageToCalFormat(sensorImageXYZ);
    sRGBPrimaryCalFormat = XYZToSRGBPrimary(theXYZCalFormat);
    
    if whichFile == 1
        indices = (sum(sRGBPrimaryCalFormat,1)~=0);
    end
    
    toneMapping = 1; 
    if toneMapping
        % applyBasicToneMap
        % Step 1: from sRGB to XYZ to xyY
        theXYZFull = SRGBPrimaryToXYZ(sRGBPrimaryCalFormat);
        thexyYFull = XYZToxyY(theXYZFull);
        
        if whichFile == 1
            % get the mean for this image
            imagePixels = sRGBPrimaryCalFormat(:,indices);
            mean(imagePixels,2)
        end
        
        % Step 2: extract only relevant pixels to compute the limits. 
        theXYZ = SRGBPrimaryToXYZ(sRGBPrimaryCalFormat(:,indices));
        thexyY  = XYZToxyY(theXYZ);
        temp = nanmean(thexyY,2);
        limit(count) = temp(3)*toneMappingFactor;
        
        % Step 3:  4 x the mean luminance and replace the top end with value of 1. 
        tempIndices = find(thexyYFull(3,:,:) > scaleFactor);
       % size(tempIndices,2)
        thexyYFull(3,tempIndices) = scaleFactor;
        
        % Step 4: convert back to SRGB
        theXYZFinal = xyYToXYZ(thexyYFull);
        sRGBPrimaryCalFinal = XYZToSRGBPrimary(theXYZFinal);
        sRGBPrimaryCalFinal = sRGBPrimaryCalFinal/scaleFactor; 
        sRGBCalFormat = uint8(SRGBGammaCorrect(sRGBPrimaryCalFinal,0));
       
    else
        sRGBPrimaryCalFormat = sRGBPrimaryCalFormat/tempMax; 
        sRGBCalFormat = uint8(SRGBGammaCorrect(sRGBPrimaryCalFormat,0));
    end
    % convert to SRGB
    sRGBImage = CalFormatToImage(sRGBCalFormat,m,n);
    imwrite(sRGBImage,[corrNameList{whichFile} '.tiff']);
end
