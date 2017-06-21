% Render blobby Exp1
% This is code
% Initialize
clear; close all; clc;
% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Users1/Shared/Matlab/Experiments/Blobby');

% renderDir
currentDir = pwd;
renderDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials';
addpath(genpath(renderDir));

% use this scene and condition file.
parentSceneFile = 'BobbieRoomCeilingLightsFar.dae';
mappingsFile = 'BobbieRoomCeilingLightsMappingsFar.txt';

% Choose batch renderer options.
hints.imageWidth = 1280;
hints.imageHeight = 960;
hints.renderer = 'Mitsuba';
hints.recipeName = ['ColorSetBlobbyExp1-' date];
ChangeToWorkingFolder(hints);

isScale = 1;
toneMapFactor = 10;
nConditions = 3;
names = {'imageName', 'illuminant', 'reflectance', 'alpha'};
alphaLevels = [0.0070, 0.0200, 0.0500, 0.1000, 0.1500, 0.2000, 0.4000];

reflectance = [1 2 3 4 5 6 7];
mCode = 4;

for c = 1:nConditions
    if c == 1
        values{2} = 'CM6700.spd';
        condCode = 'NC';
        nTests = 5;
    elseif c == 2
        values{2} = 'CM10000.spd';
        condCode = 'CB';
        nTests = 7;
    elseif c == 3
        values{2} = 'CM5000.spd';
        condCode = 'CY';
        nTests = 7;
    end
    for t = 1:nTests
        cCode = t;
        values{1} = [condCode 'C' num2str(cCode), 'M' num2str(mCode)];
        values{3} = [condCode 'CompetitorBlobRef' num2str(cCode) '.spd'];
        values{4} = alphaLevels(mCode);
        conditionsFile = ['cond' values{1} '.txt'];
        conditionsFile = WriteConditionsFile(conditionsFile, names, values);
        
        nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
        radianceDataFiles = BatchRender(nativeSceneFiles, hints);
                montageName = [values{1} ];
                montageFile = [values{1} '.png'];
                % condense multi-spectral renderings into one sRGB montage
                [SRGBMontage, XYZMontage] = ...
                    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
                % display the sRGB montage
                ShowXYZAndSRGB([], SRGBMontage, montageName);
    end
    emailToStr = 'radonjic@sas.upenn.edu';
    setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
    setpref('Internet', 'E_Mail', emailToStr);
    sendmail(emailToStr, 'RenderDone', 'Finished this condition.');
end
   