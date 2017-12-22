% BootstrapExperimentalData
%
% Run the model on experimental data and implement bootstraping 
% so we can estimate confidence intervals for model paramters. 
%
% 06/19/2017 ar Adapted the code that bootstraps demo data. 

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
codeDir = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis';
analysisDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial'; 
whichExperiment = 'Pilot'; 

% Set paramters for a given expeirment.
switch whichExperiment
    case 'Pilot'
        figAndDataDir = [analysisDir '/' whichExperiment   ];
        subjectList = {'zhr','mcv', 'flj', 'vtr','scd'};
        conditionCode = {'NC'};
        nBlocks = 25;
    case 'E1P2FULL'
        figAndDataDir = [analysisDir '/Experiment1/'];
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        nBlocks = 24;
end

% Set some parameters for bootstrapping. 
nConditions = length(conditionCode); 
nModelTypes = 1; 
showOutcome = 1; 
nSubjects = length(subjectList); 
CIrange = 95; % confidence interval range. 
CIlo = (1-CIrange/100)/2;
CIhi = 1-CIlo;


% addNoise parameter is already a part of the generated data sets. 
% We should not set it again here. Commenting it out. 
% params.addNoise = true; 
%params.maxPositionValue = max(params.F.GridVectors{1});
nRepetitions = 150; 
%% Run the bootstrapping for each subject and condition 
% Leaving an option to enable different models (although for now we just have one model). 
% To introduce other models, we can redefine some of the parameters here. 
for s = 1:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
           % k = load([figAndDataDir '/' subjectList{s} 'SolutionBootstrap' num2str(nRepetitions) '-weightVary-smoothSpacing.mat']);
            load([figAndDataDir '/' subjectList{s} 'Bootstrap' num2str(nRepetitions) '-SmoothSpacingQuad.mat'])
            %      load([figAndDataDir '/' subjectList{s} 'SolutionBootstrap' num2str(nRepetitions) '-weightVary-smoothSpacing.mat'])
            
        case 'E1P2FULL'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
            
    end
    subject{s} = thisSubject; clear thisSubject; 

 end


% make a plot for all subjects
color = [0 153 153]'./255;
thisMarkerSize = 16;
figure;  clf; hold on;
whichCondition = 1;
xTick = 0:(length(subjectList));
labelList{length(subjectList)+2} = '';
for i = 1:length(subjectList)
    labelList{i+1} = subjectList{i};
end
for s = 1:nSubjects
    CI1(s) = ...
        prctile(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1),...
        100*CIlo);
    
    CI2(s) = ...
        prctile(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1),...
        100*CIhi);
    meanW(s) = mean(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1)); 
    stdW(s) = std(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1)); 
    errorbar(s,  meanW(s),  meanW(s)-CI1(s),  CI2(s)-meanW(s), ...
        'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
        'color', color, 'LineWidth', 1.2)
%     errorbar(s, meanW(s),stdW(s), stdW(s), ...
%         'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
%         'color', color, 'LineWidth', 1.2)
end
axis([0 nSubjects+1 0 1])
xlabel('Observers','FontName','Helvetica','FontSize',20);
ylabel('Color-Material Weight','FontName','Helvetica','FontSize',20);%set(gca, 'Ytick', [1:nLevels]);
set(gca, 'YTick', [0.0:0.25:1]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))
set(gca, 'Xtick', xTick,'FontName','Helvetica','FontSize',20);
set(gca, 'XTickLabel', labelList, 'FontName','Helvetica','FontSize',20);
cd ..
FigureSave(['PilotResultsAllLinearModel'],gcf,'pdf');

% Save in the right folder.
cd(figAndDataDir)
%save([subjectName '-BootstrapResults'],  'thisSubject');
cd(codeDir)