% qPlusPlotColorMaterialModelAnyObserverParams
% Helper function to visualize some version of our model for different
% observers. We specifically used it to compare two bootstrapped outcomes
% for our observer (low weight vs. high weight) as we were revising the
% manuscript. 
%
% 12/15/2018 ar Adapted it for paper revision from
% qPlusPlotColorMaterialModel code

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';
dataDir = [getpref('ColorMaterial', 'dataFolder') '/E3'];
analysisDir = [getpref('ColorMaterial', 'analysisDir') '/E3'];
codeDir = [getpref('ColorMaterial', 'mainExpDir'), '/analysis'];

thisSParams{1} = [-4.2926
-3.3973
-1.596
0
2.8624
4.5587
5.95
-19.7746
-12.0305
-3.8497
0
11.5131
16.6996
18.7696
0.8816
1]; 

thisSParams{2} = [-14.2331
-10.6353
-1.8523
0
7.379
15.2261
19.9
-3.6131
-2.5451
-1.4707
0
2.4659
3.4723
4.1071
0.1921
1]; 

thisSParams{3} = [  -2.9650
   -1.9987
   -0.9577
         0
    1.4499
    2.1794
    3.2067
   -3.3879
   -2.1322
   -1.1485
         0
    1.7660
    2.2131
    3.1501
    0.5237
    1.0000
]; 

thisSParams{4} = [   -2.8580
   -1.8563
   -1.2394
         0
    1.3742
    2.1816
    2.7790
   -7.0603
   -4.8270
   -2.3288
         0
    2.3663
    4.5315
    6.9871
    0.5662
    1.0000]; 

load([analysisDir '/' 'nzfcityblockFull', 'Fit.mat'])
subName = {'nzfMax', 'nzfMin', 'EqPos', '2xEqPos'};  
saveFig = 1; 
for s = 4%1:length(thisSParams)
    % Load subject data
    
    % fixed weight option
    % for ww = 1:9
    
    params.subjectName = subName{s}; 

    
    % fixed weight option
    % load([analysisDir '/' subjectList{s}, num2str(ww) 'FitFixedWeight.mat'])
    
    [colorSlope(s), materialSlope(s)] = qPlusColorMaterialModelPlotSolution(NaN, ...
        NaN, NaN,...
        thisSParams{s},...
        params, analysisDir, saveFig, []);
     
    
end
