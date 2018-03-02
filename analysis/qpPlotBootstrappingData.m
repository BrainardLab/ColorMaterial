% qPlusPlotBootstrappingData
%
% Plot the results of bootstrapping
%
% 12/16/2017 ar Wrote it. 

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3'];
codeDir  = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis'; 

% Exp parameters
% Specify other experimental parameters
subjectList = { 'as'};
subjectListID = { 'as'};

conditionCode = {'NC'};
nSubjects = length(subjectList);
nConditions = length(conditionCode);

CIrange = 68.27; % confidence interval range. %68.27%, 95.45% and 99.73% 
CIlo = (1-CIrange/100)/2;
CIhi = 1-CIlo;

for s = 1:nSubjects
    % load subject data
    load([analysisDir '/' subjectListID{s}, '-BootstrapFull.mat'])
    k = load([analysisDir, '/asfullFit.mat']); 
    
    subject{s} = thisSubject; clear thisSubject
    
    for c = 1:nConditions
        nRepetitions = size(subject{s}.condition{c}.bs,2);
        
        % accumulate all parameters across repetitions
        for rr = 1:nRepetitions
            subject{s}.condition{c}.bootstrapMeans(:,rr) = subject{s}.condition{c}.bs(rr).returnedParams;
        end
        
        subject{s}.condition{c}.bootstrapMean = ...
            mean(subject{s}.condition{c}.bootstrapMeans,2);
        subject{s}.condition{c}.bootstrapStd = ...
            std(subject{s}.condition{c}.bootstrapMeans,1,2);
        subject{s}.condition{c}.bootstrapCI(1,:) = ...
            prctile(subject{s}.condition{c}.bootstrapMeans,100*CIlo,2);
        subject{s}.condition{c}.bootstrapCI(2,:) = ...
            prctile(subject{s}.condition{c}.bootstrapMeans,100*CIhi,2);
    end
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
     errorbar(s,subject{s}.condition{c}.bootstrapMean(end-1),...
        subject{s}.condition{c}.bootstrapStd(end-1), ...
        subject{s}.condition{c}.bootstrapStd(end-1), ...
        'x' , 'MarkerFaceColor', [0 0 0] , 'MarkerEdgeColor', [0 0 0], 'MarkerSize', thisMarkerSize, ...
        'color', [0 0 0], 'LineWidth', 2)
  
    errorbar(s,subject{s}.condition{c}.bootstrapMean(end-1),...
        [subject{s}.condition{c}.bootstrapMean(end-1)-subject{s}.condition{c}.bootstrapCI(1, end-1)], ...
        [subject{s}.condition{c}.bootstrapCI(2, end-1)-subject{s}.condition{c}.bootstrapMean(end-1)], ...
        'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, ...
        'color', color, 'LineWidth', 2)
    
    plot(s, k.thisSubject.condition{1}.returnedParams(end-1), 'ro', 'MarkerSize', thisMarkerSize)
end
axis([0 nSubjects+1 0 1])
xlabel('Observers','FontName','Helvetica','FontSize',20);
ylabel('Color-Material Weight','FontName','Helvetica','FontSize',20);%set(gca, 'Ytick', [1:nLevels]);
set(gca, 'YTick', [0.0:0.25:1]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))
set(gca, 'Xtick', xTick,'FontName','Helvetica','FontSize',20);
set(gca, 'XTickLabel', labelList, 'FontName','Helvetica','FontSize',20);
cd ..
FigureSave(['qPlus' subjectList{s} 'Full'],gcf,'pdf');
