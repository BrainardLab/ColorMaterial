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
hints.recipeName = ['ColorSetBlobbyExp2-' date];
ChangeToWorkingFolder(hints);

isScale = 1;
toneMapFactor = 10;
nConditions = 1;
names = {'imageName', 'illuminant', 'reflectance', 'alpha'};

% change alpha levels relative to before.
alphaLevels = [0.0350    0.0550    0.0800    0.1000  0.1400    0.1700    0.2000];
reflectance = [1 2 3 4 5 6 7];

stimList =[ ];
for i = 1:length(reflectance)
    for j = 1:length(alphaLevels)
        stimList = [stimList; i,j;];
    end
end

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
        conditionsFile = [values{1} '.txt'];
        conditionsFile = WriteConditionsFile(conditionsFile, names, values);
        
        nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
        radianceDataFiles = BatchRender(nativeSceneFiles, hints);
        % condense multi-spectral renderings into one sRGB montage
        if t == 1
            montageName = [values{1} ];
            montageFile = [values{1} '.png'];
            
            [SRGBMontage, XYZMontage] = ...
                MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
            % display the sRGB montage
            ShowXYZAndSRGB([], SRGBMontage, montageName);
        end
    end
    emailToStr = 'radonjic@sas.upenn.edu';
    setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
    setpref('Internet', 'E_Mail', emailToStr);
    sendmail(emailToStr, 'RenderDone', 'Finished this condition.');
end



   