% render test cube for Experiment1

% Initialize
clear; close all; 
% Set preferences
setpref('RenderToolbox3', 'workingFolder', '/Users1/Shared/Matlab/Experiments/Blobby');

% renderDir
currentDir = pwd;
renderDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials';
addpath(genpath(renderDir));

% use this scene and condition file.
parentSceneFile = 'BobbieCubeRoomCeilingLightsFar.dae';
mappingsFile = 'BobbieCubeRoomCeilingLightsMappingsFar.txt';

% Choose batch renderer options.
hints.imageWidth = 1280;
hints.imageHeight = 960;
hints.renderer = 'Mitsuba';
hints.recipeName = ['NewTestCubeExp1-' date];
ChangeToWorkingFolder(hints);

isScale = 1;
toneMapFactor = 10;
nConditions = 3;
names = {'imageName', 'illuminant', 'reflectance'};
nTests = 13;
reflectance = [1 2 3 4 5 6 7];

for c = 1:nConditions
    if c == 1
        values{2} = 'CM6700.spd';
        condCode = 'NC';
    elseif c == 2
        values{2} = 'CM10000.spd';
        condCode = 'CB';
    elseif c == 3
        values{2} = 'CM5000.spd';
        condCode = 'CY';
    end
    
    
    values{1} = ['ExtendedTest'  condCode ];
    values{3} = ['perfect.spd'];
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
sendmail(emailToStr, 'RenderDone', 'Finished test cube.');