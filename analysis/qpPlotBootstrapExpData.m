% qPlusPlotBootstrapExpData
%
% Plot the results of bootstrapping
%
% 12/16/2017 ar Wrote it. 
% 06/04/2018 ar Add comparison when fitting is done with the best params. 
% 06/04/2018 ar Clean up and add comments. 
% 06/13/2018 ar Adding comparison of the weights.  

% Initialize
clear; close all;

% Set directories and set which experiment to bootstrap
whichExperiment = 'E3';
dataDir = [getpref('ColorMaterial', 'dataFolder') '/E3'];
analysisDir = [getpref('ColorMaterial', 'analysisDir') '/E3'];
codeDir = [getpref('ColorMaterial', 'mainCodeDir') 'analysis'];

% Specify subject list+models to fit  and also the number of conditions. 
subjectList = {'hmneuclideanFull', 'dcacityblockFull', 'gfneuclideanCubic', 'lmacityblockQuadratic', 'ofvcityblockFull',...
 'selcityblockQuadratic', 'ckfeuclideanCubic', 'lzacityblockQuadratic', 'cjzcityblockCubic', 'jcdcityblockLinear', 'nkheuclideanFull', 'nzfcityblockFull'};

subjectSecondBest = {'hmncityblockFull', 'dcaeuclideanQuadratic', 'gfncityblockQuadratic', 'lmaeuclideanQuadratic', 'ofveuclideanFull', ...
'seleuclideanQuadratic', 'ckfcityblockQuadratic', 'lzaeuclideanCubic', 'cjzeuclideanCubic', 'jcdeuclideanLinear', 'nkhcityblockCubic', 'nzfeuclideanFull'};

subjectListID = {'hmn','dca', 'gfn', 'lma', 'ofv', 'sel','ckf', 'lza',  'cjz', 'jcd',  'nkh', 'nzf'};

conditionCode = {'NC'};
nSubjects = length(subjectList);
nConditions = length(conditionCode);

% Which confidence interval
CIrange = 68.27; % confidence interval range. %68.27%, 95.45% and 99.73% 
CIlo = (1-CIrange/100)/2;
CIhi = 1-CIlo;

% Set different colors for plotting subjects data
colorsPerSubject = [230, 25, 75
60, 180, 75
255, 225, 25
0, 0, 0
245, 130, 48
145, 30, 180
70, 240, 240
240, 50, 230
210, 245, 60
250, 190, 190
0, 128, 128
230, 190, 255]./255; 

% Other parameters for plotting
color = [0 153 153]'./255;
thisMarkerSize = 14;
thisFontSize = 17; 

for s = 1:nSubjects
    
    % Load subject bootstrap data that includes the fits where with the initial params were those recovered from the model. 
    load([analysisDir '/' subjectList{s}, 'BootstrapBestParamsFit.mat'])
    subject{s} = thisSubject; clear thisSubject
    
    n(s) = 0; % temp variable that keeps track how often the fit with the inital params worked better.   
    
    % loop through the repetitions and choose params that are best fitting,
    % based on the log likelihood. 
    nRepetitions = size(subject{s}.bs,2);
    
    for whichRep = 1:nRepetitions
        if (subject{s}.bs(whichRep).logLikelyFit >= subject{s}.bs(whichRep).newLogLikelyFit)
            subject{s}.bs(whichRep).finalReturnedParams = subject{s}.bs(whichRep).returnedParams;
        else
            subject{s}.bs(whichRep).finalReturnedParams = subject{s}.bs(whichRep).newReturnedParams;
            n(s) = n(s) +1;
        end
    end
    
    % Get the params from full data fit (for plotting)
    k = load([analysisDir '/' subjectList{s}, 'Fit.mat']);
    params = k.params; 
    weight(s) = k.thisSubject.returnedW; 

    % Get the color material slopes from the full model
    [returnedMaterialMatchColorCoords(s,:),returnedColorMatchMaterialCoords(s,:),~, ~]  = ...
        ColorMaterialModelXToParams(k.thisSubject.returnedParams, params);  clear k;
    
    % Check if the minimal enforced step is not in fact enforces
    tolerance = 1e-4;
    minimalEnforcedStep = (params.sigma/params.sigmaFactor)-tolerance;
    if (any(diff(returnedMaterialMatchColorCoords(s,:)) < minimalEnforcedStep)) || (any(diff(returnedColorMatchMaterialCoords(s,:)) < minimalEnforcedStep))
        error('Either minimal step or monotonicity constraint are not enforced.');
    end
    
    if size(returnedMaterialMatchColorCoords(s,:),2) == 7
        colorSlopeFullData(s) = regress(returnedMaterialMatchColorCoords(s,:)', params.colorMatchMaterialCoords');
        materialSlopeFullData(s) = regress(returnedColorMatchMaterialCoords(s,:)', params.materialMatchColorCoords');
    else
        colorSlopeFullData(s) = regress(returnedMaterialMatchColorCoords(s,:), params.colorMatchMaterialCoords');
        materialSlopeFullData(s) = regress(returnedColorMatchMaterialCoords(s,:), params.materialMatchColorCoords');
    end
  
    % Get the second best option.
    k = load([analysisDir '/' subjectSecondBest{s}, 'Fit.mat']);
    weightSecondBest(s) = k.thisSubject.returnedW; clear k;
    
    % Accumulate all parameters across repetitions
    for rr = 1:nRepetitions
        subject{s}.bootstrapMeans(:,rr) = subject{s}.bs(rr).finalReturnedParams;
        
        % Recover parameters and compute the slope for each bootstrap
        % iteration. 
        [subject{s}.returnedMaterialMatchColorCoords(:,rr),...
            subject{s}.returnedColorMatchMaterialCoords(:,rr),...
            subject{s}.returnedW(rr), subject{s}.returnedSigma(rr)]  = ColorMaterialModelXToParams(subject{s}.bs(rr).finalReturnedParams, params);
        
        % Check if the minimal enforced step is not in fact enforces
        if (any(diff(subject{s}.returnedMaterialMatchColorCoords(:,rr)) < minimalEnforcedStep)) || ...
                (any(diff(subject{s}.returnedColorMatchMaterialCoords(:,rr)) < minimalEnforcedStep))
            error('Either minimal step or monotonicity constraint are not enforced.');
        end
        
        
        if size(subject{s}.returnedMaterialMatchColorCoords(:,rr),2) == 7
            subject{s}.colorSlope(rr) = regress(subject{s}.returnedMaterialMatchColorCoords(:,rr)', params.colorMatchMaterialCoords');
            subject{s}.materialSlope(rr) = regress(subject{s}.returnedColorMatchMaterialCoords(:,rr)', params.materialMatchColorCoords');
        else
            subject{s}.colorSlope(rr) = regress(subject{s}.returnedMaterialMatchColorCoords(:,rr), params.colorMatchMaterialCoords');
            subject{s}.materialSlope(rr) = regress(subject{s}.returnedColorMatchMaterialCoords(:,rr), params.materialMatchColorCoords');
        end
    end
    
    subject{s}.bootstrapMean = ...
        mean(subject{s}.bootstrapMeans,2);
    if (abs(max(subject{s}.bootstrapMean(end-1) - mean(subject{s}.returnedW)))/mean(subject{s}.returnedW) > 1e-10)
        error('Oops. Something went wrong in averaging parameter values!')
    end
    
    subject{s}.bootstrapStd = ...
        std(subject{s}.bootstrapMeans,1,2);
    subject{s}.bootstrapCI(1,:) = ...
        prctile(subject{s}.bootstrapMeans,100*CIlo,2);
    subject{s}.bootstrapCI(2,:) = ...
        prctile(subject{s}.bootstrapMeans,100*CIhi,2);
    
    % Make a figure with
    figure; hold on;
    subplot(1,2,1)
    title(subjectListID{s})
    hist(subject{s}.returnedW);
    % mark the best weight
    line([weight(s), weight(s)], [0 nRepetitions], 'Color', colorsPerSubject(s,:), 'LineWidth', 2)
    line([weightSecondBest(s), weightSecondBest(s)], [0 nRepetitions], 'Color', colorsPerSubject(s,:), 'LineWidth', 2, 'LineStyle', '--')
    
    axis([0  1 0 nRepetitions])
    axis square 
    xlabel('weight value')
    ylabel('frequency')
    
    % Plot the color/material ratio vs. weight
    subplot(1,2,2);
    slopeRatios(s,:) = (subject{s}.colorSlope./subject{s}.materialSlope);
    plot(subject{s}.returnedW, (subject{s}.colorSlope./subject{s}.materialSlope), 'ko')
    [slopeWeightCorr(s), slopeWeightCorrP(s)] = corr(subject{s}.returnedW', slopeRatios(s,:)', 'type', 'Pearson');
    axis square 
    axis([0 1 0 4.5])
    xlabel('Weight')
    ylabel('Color Slope/Material Slope ratio')
    cd (analysisDir)
    FigureSave([subjectListID ' BootstrapDetails'],gcf,'pdf');
end

% Make a figure with
figure; hold on;
for s = 1:nSubjects
    subplot(3,4,s)
    title(subjectListID{s})
    hist(subject{s}.returnedW);
    % mark the best weight
    line([weight(s), weight(s)], [0 nRepetitions], 'Color', colorsPerSubject(s,:), 'LineWidth', 2)
    line([weightSecondBest(s), weightSecondBest(s)], [0 nRepetitions], 'Color', colorsPerSubject(s,:), 'LineWidth', 2, 'LineStyle', '--')
    
    axis([0  1 0 nRepetitions])
    axis square
    xlabel('weight value')
    ylabel('frequency')
end
FigureSave('AllSubjectsBootstrapWeights',gcf,'pdf');

% Plot the color/material ratio vs. weight
figure; clf; hold on
for s = 1:nSubjects
    slopeRatios(s,:) = (subject{s}.colorSlope./subject{s}.materialSlope);
    slopeRatiosAll(s) = colorSlopeFullData(s)/materialSlopeFullData(s); 
    plot(subject{s}.returnedW, (subject{s}.colorSlope./subject{s}.materialSlope), 'o', 'MarkerFaceColor', colorsPerSubject(s,:), ...
        'MarkerEdgeColor', colorsPerSubject(s,:), 'MarkerSize', 10)
    [slopeWeightCorr(s), slopeWeightCorrP(s)] = corr(subject{s}.returnedW', slopeRatios(s,:)', 'type', 'Pearson');
    plot(weight(s), slopeRatiosAll(s), 'o', 'MarkerFaceColor', colorsPerSubject(s,:), 'MarkerEdgeColor', 'k', ...
        'MarkerSize', 12, 'LineWidth', 2)
    axis([0 1 0 4.5])
    xlabel('Color-Material Weight','FontName','Helvetica','FontSize',thisFontSize);%set(gca, 'Ytick', [1:nLevels]);
    ylabel('Color-Material Slope Ratio','FontName','Helvetica','FontSize',thisFontSize);%set(gca, 'Ytick', [1:nLevels]);
    set(gca, 'YTick', [0.0:1:4.5]);
    set(gca,'YTickLabel', num2str(get(gca,'YTick')', '%.1f'), 'FontName','Helvetica','FontSize',thisFontSize); 
    set(gca,'XTickLabel',num2str(get(gca,'XTick')','%.1f'), 'FontName','Helvetica','FontSize',thisFontSize)
    cd (analysisDir)
end
FigureSave(['AllSubjectsCMRatioVsWeights'],gcf,'pdf');

% Make a plot for all subjects

figure;  clf; hold on;
xTick = 0:(length(subjectListID)); 
labelList{length(subjectListID)+2} = '';
for i = 1:length(subjectListID)
    labelList{i+1} = subjectListID{i};
end

for s = 1:nSubjects
    errorbar(s, weight(s), [weight(s) - subject{s}.bootstrapCI(1, end-1)], ...
        [subject{s}.bootstrapCI(2, end-1) - weight(s)], 'o', ...
        'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize, 'color', color, 'LineWidth', 2)
    plot(s, subject{s}.bootstrapMean(end-1), 'kx', 'MarkerSize', thisMarkerSize, 'LineWidth', 2)
    plot(s, weightSecondBest(s), 'rs', 'MarkerSize', thisMarkerSize, 'LineWidth', 2)
end

axis([0 nSubjects+1 0 1])
xlabel('Observers','FontName','Helvetica','FontSize',thisFontSize);
ylabel('Color-Material Weight','FontName','Helvetica','FontSize',thisFontSize);%set(gca, 'Ytick', [1:nLevels]);
set(gca, 'YTick', [0.0:0.25:1]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.2f'))
set(gca, 'Xtick', xTick,'FontName','Helvetica','FontSize',thisFontSize);
set(gca, 'XTickLabel', labelList, 'FontName','Helvetica','FontSize',thisFontSize);
cd (analysisDir)
FigureSave(['Figure5:qPlusBestBootstrap'],gcf,'pdf');

for s = 1:12
[RHO(s),PVAL(s)] = corr([subject{s}.colorSlope./subject{s}.materialSlope]', subject{s}.returnedW'); 
end


figure;
xTick = 0:nSubjects;
for i = 1:length(subjectList)
    labelList{i+1} = subjectListID{i};
end
labelList{length(subjectListID)+2} = '';
for s = 1:nSubjects
    plot(s, 0.2, 'o',  'MarkerFaceColor', colorsPerSubject(s,:), 'MarkerEdgeColor', colorsPerSubject(s,:), 'MarkerSize', thisMarkerSize); hold on;
end
axis([0 nSubjects+1 0 2])
set(gca, 'Xtick', xTick, 'FontSize', thisFontSize-2,'XTickLabel', labelList);
xlabel('Observers', 'FontSize', thisFontSize-2);
FigureSave('SubjectMappingCode', gcf, 'pdf')
