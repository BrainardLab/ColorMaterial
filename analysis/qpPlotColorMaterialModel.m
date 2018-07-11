% qPlusPlotColorMaterialModel
% Plots the color material Model results. 
%
% 12/16/2017 ar Wrote it. 
% 05/30/2018 ar Edited it for paper purposes. 

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3'];
codeDir  = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis'; 

% Specify subject model that is being fit.
subjectList = {'hmneuclideanFull', 'dcacityblockFull', 'gfneuclideanCubic', 'lmacityblockQuadratic', 'ofvcityblockFull',...
    'selcityblockQuadratic', 'ckfeuclideanCubic', 'lzacityblockQuadratic', 'ascityblockCubic', 'jcdcityblockLinear', 'nkheuclideanFull', 'nzfcityblockFull'};
subjectListID = {'hmn','dca', 'gfn', 'lma', 'ofv', 'sel','ckf', 'lza',  'as ', 'jcd',  'nkh', 'nzf'};
% subjectList = {'nkheuclideanFull'};
% subjectListID = {'nkh'};
 

nSubjects = length(subjectList);

saveFig = 0;
for s = 1:nSubjects
    % Load subject data
    % fixed weight option
    % for ww = 1:9
    clear params
    load([analysisDir '/' subjectList{s}, 'Fit.mat'])
    cmData{s} = load([analysisDir '/' subjectListID{s}, 'cmData.mat']); 
    % fixed weight option
    %load([analysisDir '/' subjectList{s}, num2str(ww) 'FitFixedWeight.mat'])
    
    subject{s} = thisSubject; clear thisSubject
    params.subjectName = subjectListID{s};
    
    subject{s}.pFirstChosen = ...
        subject{s}.firstChosen./subject{s}.newNTrials;
    tmpNewTrials = subject{s}.newNTrials; % pass the number of new trials, for plotting.
    
    [colorSlope(s), materialSlope(s)] = qPlusColorMaterialModelPlotSolution(subject{s}.pFirstChosen, ...
        subject{s}.predictedProbabilitiesBasedOnSolution, tmpNewTrials,...
        subject{s}.returnedParams,...
        params, analysisDir, saveFig, cmData{s}.cmDataPoints);
    weight(s) = subject{s}.returnedW;
%    ll(s,ww) = subject{s}.logLikelyFit;
    if saveFig
        FigureSave([subjectList{s} num2str(params.whichPositions) num2str(ww) 'FitFixedWeight'],gcf,'pdf');
    end
    %end
end

figure; 
subplot(1,3, 1); hold on; 
plot(weight, colorSlope, 'ro'); axis square
xlabel('Weight')
ylabel('Color Slope')
subplot(1, 3,2); hold on; 
plot(weight, materialSlope, 'bo'); axis square
xlabel('Weight')
ylabel('Material Slope')
subplot(1, 3,3); hold on; 
plot(weight, colorSlope./materialSlope, 'ko'); axis square
xlabel('Weight')
ylabel('Color/Material Slope Ratio')
cd (analysisDir)
FigureSave(['AllSubjectsSlopes'],gcf,'pdf');
