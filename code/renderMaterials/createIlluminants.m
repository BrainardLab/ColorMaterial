% CreateBlockIlluminants.m
% Create nice illuminants

clear; close all; 

%% Set the lights
% set the lights for the blocks
load B_cieday
wls = SToWls(S_cieday);

blueTemp = 10000;
yellowTemp = 5000;
standardTemp = 6700; 

scale =  0.00145;
blueScale = scale/1.54;
spdStandard = scale * GenerateCIEDay(standardTemp, B_cieday);
spdBlue = blueScale * GenerateCIEDay(blueTemp, B_cieday);
spdYellow = blueScale * GenerateCIEDay(yellowTemp, B_cieday);

cd('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials')

WriteSpectrumFile(wls, spdStandard, sprintf('CM6700.spd'));
WriteSpectrumFile(wls, spdBlue, sprintf('CM10000.spd'));
WriteSpectrumFile(wls, spdYellow, sprintf('CM5000.spd'));


