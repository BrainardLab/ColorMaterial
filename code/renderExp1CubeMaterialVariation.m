% render blobby Experiment 1

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
hints.recipeName = ['MaterialSetBlobbyExp1-' date];
ChangeToWorkingFolder(hints);

isScale = 1;
toneMapFactor = 10;
nConditions = 3;
names = {'imageName', 'illuminant', 'reflectance', 'alpha'};
nTests = 7;
alphaLevels = [0.0070, 0.0200, 0.0500, 0.1000, 0.1500, 0.2000, 0.4000];

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
    for t = 1%:nTests
        if t == 1
            mCode = 1;
            cCode = 1;
        elseif t == 2
            mCode = 2;
            cCode = 3;
        elseif t == 3
            mCode = 3;
            cCode = 3;
        elseif t == 4
            mCode = 4;
            cCode = 3;
        elseif t == 5
            mCode = 5;
            cCode = 3;
        elseif t == 6
            mCode = 6;
            cCode = 3;
        elseif t == 7
            mCode = 7;
            cCode = 3;
            %         elseif t == 8
            %             mCode = 4;
            %             cCode = 1;
            %         elseif t == 9
            %             mCode = 4;
            %             cCode = 2;
            %         elseif t == 10
            %             mCode = 4;
            %             cCode = 3;
            %         elseif t == 11
            %             mCode = 4;
            %             cCode = 5;
            %         elseif t == 12
            %             mCode = 4;
            %             cCode = 6;
            %         elseif t == 13
            %             mCode = 1;
            %             cCode = 7;
        end
        
        values{1} = [condCode 'C' num2str(cCode), 'M' num2str(mCode)];
        values{3} = [condCode 'CompetitorBlobRef' num2str(cCode) '.spd'];
        values{4} = alphaLevels(mCode);
        conditionsFile = ['cond' values{1} '.txt'];
        conditionsFile = WriteConditionsFile(conditionsFile, names, values);
        
        nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
        radianceDataFiles = BatchRender(nativeSceneFiles, hints);
        %         montageName = [values{1} ];
        %         montageFile = [values{1} '.png'];
        %         % condense multi-spectral renderings into one sRGB montage
        %         [SRGBMontage, XYZMontage] = ...
        %             MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
        %         % display the sRGB montage
        %         ShowXYZAndSRGB([], SRGBMontage, montageName);
     end
end

    emailToStr = 'radonjic@sas.upenn.edu';
        setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
        setpref('Internet', 'E_Mail', emailToStr);
        sendmail(emailToStr, 'RenderDone', 'Finished MATERIAL condition.');
   