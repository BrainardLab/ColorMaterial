% AnalyzeColorMatPilotDataVSS
% 02/11/15 ar Wrote it.
% May 2016 ar Clean up.
%             This is the code used for VSS 2016  

% Initialize.
clc; clear ; close all;

% Specify directories
figDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/FiguresExp1';
dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
codeDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/';
expName = 'Pilot';

% Specify other experimental parameters
nBlocks = 25;

subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
nSubjects = length(subjectList);
nLevels = 7; % number of levels across which color/material vary

colorPairTrials = [ 1, 2, 6, 10, 11, 12, 13, 17, 21, 22, 23, 27, 31, 32, 33, 61, 62, 63, 76, 77, 78];
materialPairTrials =  [34, 35, 36, 37, 38, 39, 43, 44, 45, 46, 47, 51, 52, 53, 54, 58, 59, 60, 64, 65, 69];
colorPairs = nchoosek(1:nLevels,2);

load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/PilotImageList.mat')
competitorPairs = nchoosek(1:length(imageNames),2);
for i = 1:length(competitorPairs) % reconstruct the image names, using the same logic as in the exp. code.
    compPair(i,:) = {[imageNames{competitorPairs(i,1)}, '-' imageNames{competitorPairs(i,2)}]};
end

%other parameters
plotPositions = 0; % do the MLDS
color = [0 153 153]'./255;
thisMarkerSize = 8;
    
for s = 1:nSubjects
    subject{s}.Name = subjectList{s};
    fprintf('Subject %s.\n', subject{s}.Name)
    
    % Step 1. Compute average choices across blocks.
    for b = 1:nBlocks
        % load subject data for this block of trials. Modify the params
        % structure by adding fields for the data and for the session
        % number. Once assigned, clear all the imported data.
        load([dataDir, expName, '/', subjectList{s}, '/', subjectList{s} '-' expName, '-', num2str(b), '.mat']);
        subject{s}.block(b) = params;
        clear params exp
        for t = 1: length(subject{s}.block(b).trial)
            % make sure this is decoded in the experimental code.
            subject{s}.chosenAcrossTrials(t,b) = subject{s}.block(b).trial(t).imageChosen;
        end
    end
    subject{s}.firstChosen = sum(subject{s}.chosenAcrossTrials==1,2);
    subject{s}.totalTrialsChosen =  sum(~isnan(subject{s}.chosenAcrossTrials),2);
    subject{s}.pFirstChosen = subject{s}.firstChosen./subject{s}.totalTrialsChosen;
    
    % Step 2. Assemble data here for the MLDS analysis
    for whichColorPair = 1:length(colorPairs)
        subject{s}.colorPairsOnly(whichColorPair) = subject{s}.firstChosen(colorPairTrials(whichColorPair));
        subject{s}.colorPairsTotal(whichColorPair)  = subject{s}.totalTrialsChosen(colorPairTrials(whichColorPair));
        subject{s}.materialPairsOnly(whichColorPair) = subject{s}.firstChosen(materialPairTrials(whichColorPair));
        subject{s}.materialPairsTotal(whichColorPair)  = subject{s}.totalTrialsChosen(materialPairTrials(whichColorPair));
    end
    
    % Step 3. Make and fill in the matrix for the color/material trade off.
    pC = NaN(nLevels, nLevels);
    for mDifference = 1:nLevels % for each of these material changes
        for whichColor = 1:nLevels % and each of these color levels
            targetString = ['C4M' num2str(mDifference)];
            otherString = ['C' num2str(whichColor) 'M4'];
            whichString1 = {[targetString '-' otherString]}; % search for these strings.
            whichString2 = {[otherString '-' targetString]};
            for i = 1:length(compPair)
                if strcmp(compPair(i), whichString1) || strcmp(compPair(i), whichString2)
                    if strcmp(compPair{i}(1:length(targetString)), targetString) % if target string is first
                        pC(mDifference,whichColor) = subject{s}.pFirstChosen(i);
                    elseif strcmp(compPair{i}((end-length(targetString)+1):end), targetString) % if target string is second
                        pC(mDifference, whichColor) = 1-subject{s}.pFirstChosen(i);
                    end
                end
            end
            clear targetString otherString whichString1 whichString2
        end
    end
    pC(4,4) = 0.5;
    subject{s}.pC = pC; clear pC;
    subject{s}.pCStep3 = mean([subject{s}.pC(1, :); subject{s}.pC(7, :)]);
    subject{s}.pCStep2 = mean([subject{s}.pC(2, :); subject{s}.pC(6, :)]);
    subject{s}.pCStep1 = mean([subject{s}.pC(3, :); subject{s}.pC(5, :)]);
    subject{s}.pCStep0 = subject{s}.pC(4, :);
    
    % Step 4. This is simply an inverse of the matrix above.
    pM = NaN(nLevels, nLevels);
    for cDifference = 1:nLevels % for each of these material changes
        for whichMat = 1:nLevels % and each of these color levels
            targetString = ['C' num2str(cDifference) ,'M4'];
            otherString = ['C4' 'M' num2str(whichMat)];
            whichString1 = {[targetString '-' otherString]}; % search for these strings.
            whichString2 = {[otherString '-' targetString]};
            for i = 1:length(compPair)
                if strcmp(compPair(i), whichString1) || strcmp(compPair(i), whichString2)
                    if strcmp(compPair{i}(1:length(targetString)), targetString)
                        pM(cDifference,whichMat) = subject{s}.pFirstChosen(i);
                    elseif strcmp(compPair{i}((end-length(targetString)+1):end), targetString)
                        pM(cDifference, whichMat) = 1-subject{s}.pFirstChosen(i);
                    end
                end
            end
            clear targetString otherString whichString1 whichString2
        end
    end
    pM(4,4) = 0.5; % hardcoded; has to be 50%.
    
    subject{s}.pM = pM; clear pM; 
    subject{s}.pMStep3 = mean([subject{s}.pM(1, :); subject{s}.pM(7, :)]);
    subject{s}.pMStep2 = mean([subject{s}.pM(2, :); subject{s}.pM(6, :)]);
    subject{s}.pMStep1 = mean([subject{s}.pM(3, :); subject{s}.pM(5, :)]);
    subject{s}.pMStep0 = subject{s}.pM(4, :);
    
    % Step 5: Apply MLDS for color and material.
    if plotPositions
        [subject{s}.targetCompetitorFitC, subject{s}.logLikelyFitC, subject{s}.predictedResponsesC] = MLDSColorSelection(colorPairs,subject{s}.colorPairsOnly,subject{s}.colorPairsTotal, nLevels); %#ok<SAGROW>
        [subject{s}.targetCompetitorFitM, subject{s}.logLikelyFitM, subject{s}.predictedResponsesM] = MLDSColorSelection(colorPairs,subject{s}.materialPairsOnly,subject{s}.materialPairsTotal, nLevels); %#ok<SAGROW>
        subject{s}.positionDerivedColor = getInferredMatchPosition(subject{s}.targetCompetitorFitC, nLevels);
        subject{s}.positionDerivedMat = getInferredMatchPosition(subject{s}.targetCompetitorFitM, nLevels);
    end
    thisSubject = subject{s}; 
    save([subject{s}.Name, 'data'], 'thisSubject');
    
    % Step 6. Plot the color/material differences. 
    colors = {[0.8, 0.8, 0.8]', [0.65, 0.65, 0.65]', [0.35, 0.35, 0.35]', [0, 0, 0]'};
    figure; clf; hold on;
    % material Differences: 3 steps
    plot(subject{s}.pC(1, :), 'o-', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    plot(subject{s}.pC(7,:), 'o--', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    % material Differnces: 2 steps
    plot(subject{s}.pC(2,:), 'o-', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    plot(subject{s}.pC(6,:), 'o--', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    % material Differences: 1 step
    plot(subject{s}.pC(3,:), 'o-', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    plot(subject{s}.pC(5,:), 'o--', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    % material difference 0
    plot(subject{s}.pC(4,:), 'o-', 'MarkerFaceColor', colors{4}, 'color', colors{4},  'MarkerEdgeColor', colors{4})
    axis([0 8 0 1])
    xlabel('delta Color')
    ylabel('p C4Mx Chosen')
    set(gca, 'Xtick', [0:8]);
    set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''});
    line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
    cd (figDir)
    FigureSave([subjectList{s} 'ColorMatchMaterialLure'], gcf, 'pdf')
    cd (analysisDir)
    
    % Step 6a. Plot the color/material differences, summarized. 
    figure; clf; hold on;
    % material Differences: 3 steps
    plot([subject{s}.pCStep3], 'o-', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    % material Differnces: 2 steps
    plot([subject{s}.pCStep2], 'o-', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    % material Differences: 1 step
    plot([subject{s}.pCStep1], 'o-', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    % material difference 0
    plot([subject{s}.pCStep0], 'o-', 'MarkerFaceColor', colors{4}, 'color', colors{4},  'MarkerEdgeColor', colors{4})
    axis([0 8 0 1])
    xlabel('delta Color')
    ylabel('p C4Mx Chosen')
    set(gca, 'Xtick', [0:8]);
    set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''});
    line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
    cd (figDir)
    FigureSave([subjectList{s} 'ColorMatchMaterialLureAveraged'], gcf, 'pdf')
    cd (analysisDir)
    % Step 7: Remake this plot in a fancy way. 
    
    
end
% save this Data

% Plot inferred position across subjects. 
if plotPositions
    xTick = 0:(length(subjectList));
    labelList{length(subjectList)+2} = '';
    for i = 1:length(subjectList)
        labelList{i+1} = subjectList{i};
    end
    
    figure;  clf;
    subplot(1,2,1); hold on;
    for s = 1:nSubjects
        plot(s, subject{s}.positionDerivedColor, 'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize)
    end
    axis([0 nSubjects+1 1 7])
    axis square
    line([0 nSubjects+1], [4 4],'LineStyle','--', 'color', 'k')
    title('Color only')
    xlabel('Subject')
    ylabel('Inferred position')
    set(gca, 'Ytick', [1:nLevels]);
    set(gca, 'YTickLabel', {'Green C-3', 'C-2', 'C-1', 'T', 'C+1', 'C+2', 'Blue C+3'});
    set(gca, 'Xtick', xTick);
    set(gca, 'XTickLabel', labelList);
    
    subplot(1,2,2); hold on;
    title('Material only')
    for s = 1:nSubjects
        plot(s, subject{s}.positionDerivedMat, 'o' , 'MarkerFaceColor', color, 'MarkerEdgeColor', color,'MarkerSize', thisMarkerSize)
    end
    line([0 nSubjects+1], [4 4],'LineStyle','--', 'color', 'k')
    axis([0 nSubjects+1 1 7])
    axis square
    xlabel('Subject')
    ylabel('Inferred position')
    set(gca, 'Ytick', [1:7]);
    set(gca, 'Xtick', xTick);
    set(gca, 'XTickLabel', labelList);
    set(gca, 'YTickLabel', {'Matte C-3', 'C-2', 'C-1', 'T', 'C+1', 'C+2', 'Glossy C+3'});
    cd (figDir)
    savefigghost([ 'RecoveredPositions'], gcf, 'pdf')
    cd (analysisDir)
end