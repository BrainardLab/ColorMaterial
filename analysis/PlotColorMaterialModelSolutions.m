% PlotColorMaterialModelSolutions

% Initialize
clear; close

% Specify basic experiment parameters
whichExperiment = 'Pilot';
switch whichExperiment
    case 'E1P2'
        % Specify other experimental parameters
        subjectList = { 'mdc', 'nsk'};
        %         subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
        conditionCode = {'NC', 'CY', 'CB'};
        
        figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1'];
        load([figAndDataDir '/' 'ParamsE1P2FULL.mat'])
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = {'mcv'}; % 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        figAndDataDir = ['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Pilot'];
        load([figAndDataDir '/' 'pairIndicesPilot.mat'])
end

nSubjects = length(subjectList);
nConditions = length(conditionCode);
saveFig = 0; 
weibullplots = 0; 
        
for s = 1:length(subjectList)
    close all;
    for whichCondition = 1:nConditions
        interpCode = 'C';
        if strcmp(whichExperiment, 'E1P2')
            load([figAndDataDir '/' interpCode  subjectList{s} 'SolutionNew-weightVary.mat'])
        else
            load([figAndDataDir '/'   subjectList{s} 'SolutionNew1-weightVary-smoothSpacing.mat'])
        end
        
        ColorMaterialModelPlotSolution(thisSubject.condition{whichCondition}.pFirstChosen, ...
            thisSubject.condition{whichCondition}.bootstrapStructure.predictedProbabilitiesBasedOnSolution, ...
            thisSubject.condition{whichCondition}.bootstrapStructure.returnedParams,...
            indexMatrix, params, figAndDataDir, saveFig, weibullplots)
               
%         ColorMaterialModelPlotSolution(dataSet{whichSet}.probabilitiesFromSimulatedData, ...
%             dataSet{whichSet}.predictedProbabilitiesBasedOnSolution, ...
%             dataSet{whichSet}.returnedParams, ...
%             indexMatrix, params, pwd,  saveFig, weibullplots);
    end
end

%
thisSlope = paramsRange{1}(end-1,:); 
[~, sortIndex] = sort(thisSlope);
nSubjects= (length(subjectList));
xTick = 0:(length(subjectList));
thisMarkerSize = 18;
labelList{length(subjectList)+2} = '';
for i = 1:length(subjectList)
    labelList{i+1} = subjectList{sortIndex(i)};
end
color = [0 153 153]'./255;
thisMarkerSize = 16;
figure;  clf; hold on;
for s = 1:(length(subjectList))
    plot(s, thisSlope(sortIndex(s)), 'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize)
end
axis([0 nSubjects+1 0 1])
xlabel('Subjects','FontName','Helvetica','FontSize',20);
ylabel('Color Weigth','FontName','Helvetica','FontSize',20);%set(gca, 'Ytick', [1:nLevels]);
set(gca, 'YTick', [0.0:0.5:2]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'))
set(gca, 'Xtick', xTick,'FontName','Helvetica','FontSize',20);
set(gca, 'XTickLabel', labelList, 'FontName','Helvetica','FontSize',20);
cd ..
FigureSave(['DavidSlideB'],gcf,'pdf');