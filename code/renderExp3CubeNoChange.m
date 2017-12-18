% renderExp3CubeNoChange.m
% This code code is used to render the stimuli for Experiment 2 in which we
% are going to loop through the full grid of stimuli using Quest+
% The stimuli rendered using this code live on Seanemone in the following folder
% /Users1/Shared/Matlab/Experiments/Blobby/ColorSetBlobbyExp2-03-Aug-2017

% August 2017 ar Wrote it. 
% 12/08/2017 ar Added comments. 

% Initialize
clear; close all; clc;
% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Users1/Shared/Matlab/Experiments/Blobby');

% renderDir
currentDir = pwd;
renderDir = '/Users/colorlab/Documents/MATLAB/projects/Experiments/ColorMaterial/code';
addpath(genpath(renderDir));

% use this scene and condition file.
parentSceneFile = 'BobbieRoomCeilingLightsFar.dae';
mappingsFile = 'BobbieRoomCeilingLightsMappingsFar.txt';

% Choose batch renderer options.
hints.imageWidth = 1280;
hints.imageHeight = 960;
hints.renderer = 'Mitsuba';
hints.recipeName = ['ColorSetBlobbyExp2-' date];
ChangeToWorkingFolder(hints);

isScale = true;
toneMapFactor = 100;
nConditions = 1;
names = {'imageName', 'illuminant', 'reflectance', 'alpha'};
offSet = 4; 
% change alpha levels relative to before.
% We empirically got these alpha levels (eyeballing...) 
% We were trying to get the steps in the material space to correspond to
% steps in color space (which we approximately at JND level, we think)
alphaLevels = [0.0350    0.0550    0.0800    0.1000  0.1400    0.1700    0.2000];
reflectance = [1 2 3 4 5 6 7];

stimList =[ ];
for i = 1:length(reflectance)
    for j = 1:length(alphaLevels)
        stimList = [stimList; i,j;];
    end
end
tempImageList = {}; 
for c = 1:nConditions
    if c == 1
        values{2} = 'CM6700.spd';
        condCode = 'Exp2NC';
    end
    
    for t = 1:length(stimList)
        cCode = stimList(t,1);
        mCode = stimList(t,2);
        values{1} = [condCode 'C' num2str(cCode), 'M' num2str(mCode)];
        values{3} = [condCode 'CompetitorBlobRef' num2str(cCode) '.spd'];
        values{4} = alphaLevels(mCode);
        tempImageList = [tempImageList, values{1}];
        conditionsFile = [values{1} '.txt'];
        conditionsFile = WriteConditionsFile(conditionsFile, names, values);
        
        nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
        radianceDataFiles = BatchRender(nativeSceneFiles, hints);
        
%         condense multi-spectral renderings into one sRGB montage (only
%         for the first image)
        if t == 1
            montageName = [values{1} ];
            montageFile = [values{1} '.png'];
            
            [SRGBMontage, XYZMontage] = ...
                MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
            
            % Display the sRGB montage
            ShowXYZAndSRGB([], SRGBMontage, montageName);
        end
    end
    emailToStr = 'radonjic@sas.upenn.edu';
    setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
    setpref('Internet', 'E_Mail', emailToStr);
    sendmail(emailToStr, 'RenderDone', 'Finished this condition.');
end
cd(currentDir)
imageList.imageName = tempImageList; 
imageList.stimulusListColor = stimList(:,1)-offSet; 
imageList.stimulusListMaterial = stimList(:,2)-offSet; 

save('Exp3ImageList', 'imageList')

   