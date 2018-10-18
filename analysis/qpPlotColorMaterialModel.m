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
    'selcityblockQuadratic', 'ckfeuclideanCubic', 'lzacityblockQuadratic', 'cjzcityblockCubic', 'jcdcityblockLinear', 'nkheuclideanFull', 'nzfcityblockFull'};
subjectListID = {'hmn','dca', 'gfn', 'lma', 'ofv', 'sel','ckf', 'lza',  'cjz', 'jcd',  'nkh', 'nzf'};
nSubjects = length(subjectList);

saveFig = 0;
for s = 1:nSubjects
    % Load subject data
    % fixed weight option
    % for ww = 1:9
    clear params
    load([analysisDir '/' subjectList{s}, 'Fit.mat'])
    colorMaterialData{s} = load([analysisDir '/' subjectListID{s}, '-colorMaterialDataPoints.mat']);
    colorOnlyData{s} = load([analysisDir '/' subjectListID{s}, '-colorOnlyDataPoints.mat']);
    materialOnlyData{s} = load([analysisDir '/' subjectListID{s}, '-materialOnlyDataPoints.mat']);
    
    % fixed weight option
    %load([analysisDir '/' subjectList{s}, num2str(ww) 'FitFixedWeight.mat'])
    
    subject{s} = thisSubject; clear thisSubject
    params.subjectName = subjectListID{s};
    
    % concatenate probabilities across identical trials and compute
    % relevant data for plotting predicted vs. measured probabilities. 
    cd(codeDir)
    subject{s}.concatenatedProbabilities = returnConcatenatedProbabilities(subject{s}.newTrialData); 
    subject{s}.pFirstChosen = ...
        subject{s}.concatenatedProbabilities(:,5)./subject{s}.concatenatedProbabilities(:,6);
    tmpNewTrials = subject{s}.concatenatedProbabilities(:,6); % pass the number of new trials, for plotting.
    
    [colorSlope(s), materialSlope(s)] = qPlusColorMaterialModelPlotSolution(subject{s}.pFirstChosen, ...
        subject{s}.predictedProbabilitiesBasedOnSolution, tmpNewTrials,...
        subject{s}.returnedParams,...
        params, analysisDir, saveFig, colorMaterialData{s}.cmDataPoints);
    
    % Note, we need to flip the colorOnly and matrialOnly matrices (because
    % the first chosen is in the vertical column; the oposite is the case
    % for color material match aggregation - there material match is in the
    % vertical column and we're tracking p of choosing the color match in
    % the graph)
    
    qPlusColorMaterialModelPlotSolutionExtended(subject{s}.pFirstChosen, ...
        subject{s}.predictedProbabilitiesBasedOnSolution, tmpNewTrials,...
        subject{s}.returnedParams,...
        params, analysisDir, saveFig, ...
        colorMaterialData{s}.cmDataPoints, colorOnlyData{s}.cmDataPoints', materialOnlyData{s}.cmDataPoints');
    weight(s) = subject{s}.returnedW;
    
    % ll(s,ww) = subject{s}.logLikelyFit;
    % fixed weight option
    %     if saveFig
    %         FigureSave([subjectList{s} num2str(params.whichPositions) num2str(ww) 'FitFixedWeight'],gcf,'pdf');
    %     end
    %end
end

% Comparison plots of color-material weights and positions across subjects.
% 3 panel plot: 
% 1) weight vs. colorSlope
% 2) weight vs. materialSlope
% 3) weight vs. color-materialSlope
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