% BootstrapExperimentalData
%
% Run the model on experimental data and implement bootstraping 
% so we can estimate confidence intervals for model paramters. 
%
% 06/19/2017 ar Adapted the code that bootstraps demo data. 
% 01/07/2018 ar Clean up the code a little bit. 

% Initialize
clear; close all;

% Set directories and set which experiment whose bootstrap results we want to plot.
codeDir = pwd;
analysisDir = getpref('ColorMaterial', 'analysisDir'); 
whichExperiment = 'Pilot'; 

% Set parameters for a given expeirment.
switch whichExperiment
    case 'Pilot'
        figAndDataDir = [analysisDir '/' whichExperiment];
        subjectList = {'zhr','mcv', 'flj', 'vtr','scd'};
        conditionCode = {'NC'};
        nBlocks = 25;
    case 'E1P2FULL'
        figAndDataDir = [analysisDir '/Experiment1/'];
        subjectList = {'mdc','nsk'};
        conditionCode = {'NC', 'CY', 'CB'};
        nBlocks = 24;
end
nConditions = length(conditionCode); 
nSubjects = length(subjectList); 
whichModelType = 'full'
% Set some parameters for plotting bootstrapped results. 
CIrange = 95; % confidence interval range. 
CIlo = (1-CIrange/100)/2;
CIhi = 1-CIlo;
nRepetitions = 150; 

% Load the structure with bootstrapped data
for s = 1:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'Bootstrap' num2str(nRepetitions) '-' whichModelType '.mat'])
        case 'E1P2FULL'
            clear thisSubject
          %  Currently this is obsolete, we need to get new bootstrap data with the current code.   
          %  load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
            
    end
    
    subject{s} = thisSubject; clear thisSubject;
    kk = load([figAndDataDir '/' subjectList{s} 'SolutionNew-' whichModelType '.mat']);
    for whichCondition = 1:nConditions
        % Extract the bootstrapped parameters and the variability
        CI1(s,whichCondition) = ...
            prctile(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1),...
            100*CIlo);
        CI2(s, whichCondition) = ...
            prctile(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1),...
            100*CIhi);
        meanWeight(s,whichCondition) = mean(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1));
        stdWeight(s, whichCondition) = std(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1));
        
        % also get the weight from full model fit. 
        fullWeights(s,whichCondition) = kk.thisSubject.condition{whichCondition}.returnedW; 
        clear kk
    
    end
end

% Plot the results
color = [0 153 153]'./255;
thisMarkerSize = 16;

figure;  clf; hold on;
for s = 1:nSubjects
    %     errorbar(s,  meanWeight(s),  meanWeight(s)-CI1(s),  CI2(s)-meanWeight(s), ...
    %         'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
    %         'color', color, 'LineWidth', 1.2)
    errorbar(s, meanWeight(s),stdWeight(s), stdWeight(s), ...
        'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
        'color', color, 'LineWidth', 1.2)
    plot(s, fullWeights(s,whichCondition), ...
        'o' , 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', thisMarkerSize-6, ...
        'color', color, 'LineWidth', 1.2)
end
axis([0 nSubjects+1 0 1])

% Make axis and tick labels
xlabel('Observers','FontName','Helvetica','FontSize',20);
ylabel('Color-Material Weight','FontName','Helvetica','FontSize',20);%set(gca, 'Ytick', [1:nLevels]);
xTick = 0:(length(subjectList));
labelList{length(subjectList)+2} = '';
for i = 1:length(subjectList)
    labelList{i+1} = subjectList{i};
end
set(gca, 'YTick', [0.0:0.25:1]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))
set(gca, 'Xtick', xTick,'FontName','Helvetica','FontSize',20);
set(gca, 'XTickLabel', labelList, 'FontName','Helvetica','FontSize',20);

% Save figure
cd(figAndDataDir)
FigureSave(['PilotResultsAll222-' whichModelType],gcf,'pdf');
cd(codeDir)