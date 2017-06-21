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
parentSceneFile = 'BobbieRoomCeilingLights.dae';
mappingsFile = 'BobbieRoomCeilingLightsMappingsTest.txt';

% Choose batch renderer options.
hints.imageWidth = 1280;
hints.imageHeight = 960;
hints.renderer = 'Mitsuba';
hints.recipeName = ['TestBlobbyArtifacts-' date];
ChangeToWorkingFolder(hints);

isScale = 1;
toneMapFactor = 10;
names = {'imageName', 'illuminant', 'reflectance', 'alpha', 'integrator', 'sampleCount', 'maxDepth', 'sampler'};
alphaLevels = [0.0070];
nTests = 6;
cCode = 1;

values{2} = 'CM5000.spd';
condCode = 'CY';

values{3} = ['CYCompetitorBlobRef' num2str(cCode) '.spd'];
values{4} = alphaLevels(1);
  

for t = 7%:nTests
    values{1} = [condCode 'Test' num2str(t)];
    if t == 1
        
        values{5} = 'path'; % integrator
        values{6} = 1024; % sample count
        values{7} = -1; % max depth
        values{8} = 'ldsampler'; % sampler
        
    elseif t == 2
        
        values{5} = 'bdpt'; % integrator
        values{6} = 320; % sample count
        values{7} = 5; % max depth
        values{8} = 'ldsampler'; % sampler
        
    elseif t == 3
        
        values{5} = 'bdpt'; % integrator
        values{6} = 1024; % sample count
        values{7} = 5; % max depth
        values{8} = 'ldsampler'; % sampler
        
    elseif t == 4
        
        values{5} = 'bdpt'; % integrator
        values{6} = 1024; % sample count
        values{7} = 5; % max depth
        values{8} = 'stratified'; % sampler
        
    elseif t == 5
        
        values{5} = 'bdpt'; % integrator
        values{6} = 1024; % sample count
        values{7} = 5; % max depth
        values{8} = 'independent'; % sampler
        
    
     elseif t == 6
        
        values{5} = 'bdpt'; % integrator
        values{6} = 1024; % sample count
        values{7} = 7; % max depth
        values{8} = 'ldsampler'; % sampler
        
    
    elseif t == 7
        
        values{5} = 'bdpt'; % integrator
        values{6} = 1024; % sample count
        values{7} = 5; % max depth
        values{8} = 'ldsampler'; % sampler
        
        hints.imageWidth =  hints.imageWidth/2;
        hints.imageHeight = hints.imageHeight/2;
        
    end
    
    
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

