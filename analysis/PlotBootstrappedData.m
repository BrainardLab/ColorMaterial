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
whichModelType = 'full';

% Set some parameters for plotting bootstrapped results.
CIrange = 95; % confidence interval range.
CIlo = (1-CIrange/100)/2;
CIhi = 1-CIlo;
nRepetitions = 150;

% Assign color we will use to plot weight distribution and position
% tradeoff of different subjects. 
colorPerSubject = [230, 25, 75
60, 180, 75
255, 225, 25
145, 30, 180
245, 130, 48]./255

% Quickly define the range of position variation so we can 
% compute color/material slopes later on. 
colorMatchMaterialCoords = [-3:1:3]; 
materialMatchColorCoords = [-3:1:3];
cIndex = [1,7]; % indices of the first and last for the color position in the full param list
mIndex = [8,14]; % indices of the first and last material position in the full param list

% Load the structure with bootstrapped data
for s = 1:length(subjectList)
    switch whichExperiment
        case 'Pilot'
            clear thisSubject
            load([figAndDataDir '/' subjectList{s} 'BootstrapCubic' num2str(nRepetitions) '-' whichModelType '.mat'])
        case 'E1P2FULL'
            clear thisSubject
            %  Currently this is obsolete, we need to get new bootstrap data with the current code.
            %  load([figAndDataDir '/' subjectList{s} 'SummarizedDataFULL.mat']); % data
    end
    
    subject{s} = thisSubject; clear thisSubject;
    
    for whichCondition = 1:nConditions
        
        % Get the weight from full model fit.
        kk = load([figAndDataDir '/' subjectList{s} 'Solution-' whichModelType '.mat']);
        fullWeights(s,whichCondition) = kk.thisSubject.condition{whichCondition}.returnedW;
        % Get the color material slopes from the full model
        colorSlopeFullData(s) = regress(kk.thisSubject.condition{whichCondition}.returnedParams(cIndex(1):cIndex(2)), materialMatchColorCoords');
        materialSlopeFullData(s) = regress(kk.thisSubject.condition{whichCondition}.returnedParams(mIndex(1):mIndex(2)), colorMatchMaterialCoords');
        clear kk
        
       % Extract the bootstrapped parameters and the variability
        CI1(s,whichCondition) = ...
            prctile(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1),...
            100*CIlo);
        CI2(s, whichCondition) = ...
            prctile(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1),...
            100*CIhi);
        meanWeight(s,whichCondition) = mean(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1));
        stdWeight(s, whichCondition) = std(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1));
        
        % Compute the color slope and material slope for each bootstrap iteration.
        for rr = 1:nRepetitions
            subject{s}.condition{whichCondition}.colorSlope(rr) = ...
                regress([subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(rr,cIndex(1):cIndex(2))]', materialMatchColorCoords');
            subject{s}.condition{whichCondition}.materialSlope(rr) = ...
                regress([subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(rr,mIndex(1):mIndex(2))]', colorMatchMaterialCoords');
        end
        
        % Make a figure for each subject where left panel is showing the
        % distribution of the weights (histogram)
        figure; hold on;
        subplot(1,2,1)
        hist(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1));
        % mark the weight from the best model for this subject
        line([fullWeights(s), ...
            fullWeights(s)], [0 nRepetitions], 'Color', colorPerSubject(s,:), 'LineWidth', 2)
        axis([0  1 0 nRepetitions])
        xlabel('weight value')
        ylabel('frequency')
        
        % Right panel of the figure plots color/material slope ratios. 
        subplot(1,2,2);
        slopeRatios(s,:) = (subject{s}.condition{whichCondition}.colorSlope./subject{s}.condition{whichCondition}.materialSlope);
        plot(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1), (subject{s}.condition{whichCondition}.colorSlope./subject{s}.condition{whichCondition}.materialSlope), 'ko')
        axis square
        xlabel('')
        ylabel('Color Slope/Material Slope ratio')
        cd (analysisDir)
    end
end

% Make a common figure with bootstrapped weight distribution across all subjects
figure; hold on;
for  s = 1:nSubjects
    subplot(2,ceil(nSubjects/2),s)
    hist(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1));
    % mark the weight from the best model for this subject
    line([fullWeights(s), ...
        fullWeights(s)], [0 nRepetitions], 'Color', colorPerSubject(s,:), 'LineWidth', 2)
    axis([0  1 0 nRepetitions])
    axis square
    xlabel('weight value')
    ylabel('frequency')
end
FigureSave(['CMSlope-WeightHistogramsPilot'],gcf,'pdf');

% Make a common figure with bootstrapped weight vs.  distribution across all subjects
figure; clf; hold on;
for  s = 1:nSubjects
    % Make a figure with
    slopeRatios(s,:) = (subject{s}.condition{whichCondition}.colorSlope./subject{s}.condition{whichCondition}.materialSlope);
    slopeRatiosAll(s) = colorSlopeFullData(s)/materialSlopeFullData(s); 
    
    plot(subject{s}.condition{whichCondition}.bootstrapStructure.returnedParams(:,end-1), ...
        (subject{s}.condition{whichCondition}.colorSlope./subject{s}.condition{whichCondition}.materialSlope), 'o', 'MarkerFaceColor', colorPerSubject(s,:), ...
        'MarkerEdgeColor', colorPerSubject(s,:))
    plot(fullWeights(s), slopeRatiosAll(s), 'o', 'MarkerFaceColor', colorPerSubject(s,:), 'MarkerEdgeColor', 'k', ...
        'MarkerSize', 10, 'LineWidth', 2)
    %axis square
    %axis([0 1 0  ceil(max(slopeRatios(:)))])
    axis([0 1 0  4.5])
    
    xlabel('Bootstrapped weight')
    ylabel('Ratio of Color/Material Slope')
    cd (analysisDir)
end
FigureSave(['CMSlope-WeightAcrossSubjectsPilot'],gcf,'pdf');

% Plot the results
color = [0 153 153]'./255;
thisMarkerSize = 16;

figure;  clf; hold on;
for s = 1:nSubjects
    errorbar(s,  meanWeight(s),  meanWeight(s)-CI1(s),  CI2(s)-meanWeight(s), ...
        'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
        'color', color, 'LineWidth', 1.2)
    errorbar(s, meanWeight(s),stdWeight(s), stdWeight(s), ...
        'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
        'color', 'k', 'LineWidth', 1)
    plot(s, fullWeights(s,whichCondition), ...
        'o' , 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'MarkerSize', thisMarkerSize, ...
        'color', color, 'LineWidth', 1)
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
%FigureSave(['ReviewPaper-PilotResultsFinal-' whichModelType],gcf,'pdf');
cd(codeDir)