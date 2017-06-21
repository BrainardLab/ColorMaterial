% AnalyzeColorMatPilotData
%
% 02/11/15 ar Wrote it

% Initialize.
clc; clear ; close all;

% Specify directories
analysisDir = pwd;
dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
codeDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/';
expName = 'Pilot';

% Specify other experimental parameters
nBlocks = 25;
subjectList = { 'scd', 'vtr',  'mcv','flj', 'zhr'};

nSubjects = length(subjectList);
colorPairTrials = [ 1     2     6    10    11    12    13    17    21    22    23, ...
    27    31    32    33    61    62    63    76    77    78];
colorPairs = nchoosek(1:7,2);
materialPairTrials =  [34    35    36    37    38    39    43    44    45    46    47    51    52    53    54    58    59    60    64    65    69];
nCompetitors = max(colorPairs(:));
load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/PilotImageList.mat')
competitorPairs = nchoosek(1:length(imageNames),2);
for i = 1:length(competitorPairs)
    compPair(i,:) = {[imageNames{competitorPairs(i,1)}, '-' imageNames{competitorPairs(i,2)}]};
end

for s = 1:nSubjects
    close all
    fprintf('Subject %s.\n', subjectList{s})
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
    % this is for MLDS
    for whichColorPair = 1:length(colorPairs)
        subject{s}.colorPairsOnly(whichColorPair) = subject{s}.firstChosen(colorPairTrials(whichColorPair));
        subject{s}.colorPairsTotal(whichColorPair)  = subject{s}.totalTrialsChosen(colorPairTrials(whichColorPair));
        subject{s}.materialPairsOnly(whichColorPair) = subject{s}.firstChosen(materialPairTrials(whichColorPair));
        subject{s}.materialPairsTotal(whichColorPair)  = subject{s}.totalTrialsChosen(materialPairTrials(whichColorPair));
    end
    
    
    % color variation across different material steps
    for mDifference = 1:7;
        pM{mDifference} = [];
        for j = 1:7 % which color level
            whichPair{j} = [];
            name{j} = [];
            targetString = ['C4M' num2str(mDifference)];
            otherString = ['C' num2str(j) 'M4'];
            whichString1 = {[targetString '-' otherString]};
            whichString2 = {[otherString '-' targetString]};
            for i = 1:length(compPair)
                if strcmp(compPair(i), whichString1) || strcmp(compPair(i), whichString2)
                    whichPair{j} = [whichPair{j}, i];
                    name{j} = [name{j}, compPair(i)];
                    if strcmp(compPair{i}(1:length(targetString)), targetString)
                        pM{mDifference}  = [pM{mDifference}, subject{s}.pFirstChosen(i)];
                    elseif strcmp(compPair{i}((end-length(targetString)+1):end), targetString)
                        pM{mDifference}  = [pM{mDifference}, 1-subject{s}.pFirstChosen(i)];
                    end
                end
            end
            clear targetString otherString whichString1 whichString2
        end
        if mDifference ==4
            pM{mDifference} = [pM{4}(1:3) NaN pM{4}(4:6) ];
        end
    end
    
    subject{s}.pM = pM; 
  
    
    % get something that computes slopes. 
    subject{s}.slopes(1) = getSlopesCM(subject{s}.pM{1});
    subject{s}.slopes(2) = getSlopesCM(subject{s}.pM{2});
    subject{s}.slopes(3) = getSlopesCM(subject{s}.pM{3});
    subject{s}.slopes(4) = getSlopesCM(subject{s}.pM{5});
    subject{s}.slopes(5) = getSlopesCM(subject{s}.pM{6});
    subject{s}.slopes(6) = getSlopesCM(subject{s}.pM{7});
    
    
    % for one subject, I should try to fit the data?
    
    % plot
    colors = {'r', 'g', 'b', 'm', 'k', 'c', 'y'};
    %colors = {[0 153 153]'./255, [0 153 153]'./255, [0 153 153]'./255, [0 153 153]'./255, [0 153 153]'./255, [0 153 153]'./255, [0 153 153]'./255};
    figure; clf; hold on;
    plot(pM{1}, 'o-', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    plot(pM{7}, 'o--', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    plot(pM{2}, 'o-', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    plot(pM{6}, 'o--', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    plot(pM{3}, 'o-', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    plot(pM{5}, 'o--', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    plot(pM{4}, 'o-', 'MarkerFaceColor', colors{4}, 'color', colors{4},  'MarkerEdgeColor', colors{4})
    axis([0 8 0 1])
    xlabel('delta Color')
    ylabel('p C4Mx Chosen')
    set(gca, 'Xtick', [0:8]);
    set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''});
    line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
    savefigghost(['MaterialStepsAcrossColorDifferences'], gcf, 'pdf')
    clear pM;
    
    clear whichPair name
    % material variation across different color steps
    for cDifference = 1:7;
        pC{cDifference} = []; %#ok<*SAGROW>
        for j = 1:7 % which material level
            whichPair{j} = [];
            name{j} = [];
            targetString = ['C' num2str(cDifference) 'M4'];
            otherString = ['C4M' num2str(j)];
            whichString1 = {[targetString '-' otherString]};
            whichString2 = {[otherString '-' targetString]};
            for i = 1:length(compPair)
                if strcmp(compPair(i), whichString1) || strcmp(compPair(i), whichString2)
                    whichPair{j} = [whichPair{j}, i];
                    name{j} = [name{j}, compPair(i)];
                    if strcmp(compPair{i}(1:length(targetString)), targetString)
                        pC{cDifference}  = [pC{cDifference}, subject{s}.pFirstChosen(i)];
                    elseif strcmp(compPair{i}((end-length(targetString)+1):end), targetString)
                        pC{cDifference}  = [pC{cDifference}, 1-subject{s}.pFirstChosen(i)];
                    end
                end
            end
            clear targetString otherString whichString1 whichString2
        end
        if cDifference ==4
            pC{cDifference} = [pC{4}(1:3) NaN pC{4}(4:6) ];
        end
    end
    
    subject{s}.pC = pC; 
      
    subject{s}.slopes2(1) = getSlopesCM(subject{s}.pC{1});
    subject{s}.slopes2(2) = getSlopesCM(subject{s}.pC{2});
    subject{s}.slopes2(3) = getSlopesCM(subject{s}.pC{3});
    subject{s}.slopes2(4) = getSlopesCM(subject{s}.pC{5});
    subject{s}.slopes2(5) = getSlopesCM(subject{s}.pC{6});
    subject{s}.slopes2(6) = getSlopesCM(subject{s}.pC{7});
    
    %% % plot
    colors = {'r', 'g', 'b', 'm', 'k', 'c', 'y'};
    figure; clf; hold on;
    plot(pC{1}, 'o-', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    plot(pC{7}, 'o--', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1})
    plot(pC{2}, 'o-', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    plot(pC{6}, 'o--', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2})
    plot(pC{3}, 'o-', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    plot(pC{5}, 'o--', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3})
    plot(pC{4}, 'o-', 'MarkerFaceColor', colors{4}, 'color', colors{4},  'MarkerEdgeColor', colors{4})
    axis([0 8 0 1])
    xlabel('delta Material')
    ylabel('p CxM4 Chosen')
    set(gca, 'Xtick', [0:8]);
    set(gca, 'xTickLabel', {'', 'M-3', 'M-2', 'M-1', 'M0','M+1', 'M+2', 'M+3', ''});
    line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
    savefigghost(['ColorStepsAcrossMaterialDifferences'], gcf, 'pdf')
    clear pC;
%     [subject{s}.targetCompetitorFitC, subject{s}.logLikelyFitC, subject{s}.predictedResponsesC] = MLDSColorSelection(colorPairs,subject{s}.colorPairsOnly,subject{s}.colorPairsTotal, nCompetitors); %#ok<SAGROW>
%     [subject{s}.targetCompetitorFitM, subject{s}.logLikelyFitM, subject{s}.predictedResponsesM] = MLDSColorSelection(colorPairs,subject{s}.materialPairsOnly,subject{s}.materialPairsTotal, nCompetitors); %#ok<SAGROW>
%     subject{s}.positionDerivedColor = getInferredMatchPosition(subject{s}.targetCompetitorFitC, 7);
%     subject{s}.positionDerivedMat = getInferredMatchPosition(subject{s}.targetCompetitorFitM, 7);

end

% %% Plot inferredPosition
% xTick = 0:(length(subjectList));
% labelList{length(subjectList)+2} = '';
% for i = 1:length(subjectList)
%     labelList{i+1} = subjectList{i};
% end
% color = [0 153 153]'./255;
% thisMarkerSize = 10;
% figure;  clf;
% subplot(1,2,1); hold on;
% for s = 1:nSubjects
%     plot(subject{s}.positionDerivedColor, 'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize)
% end
% axis([0 nSubjects+1 1 7])
% line([0 nSubjects+1], [4 4],'LineStyle','--', 'color', 'k')
% title('Color only')
% xlabel('Subject')
% ylabel('Inferred position')
% set(gca, 'Ytick', [1:nCompetitors]);
% set(gca, 'YTickLabel', {'Green C-3', 'C-2', 'C-1', 'T', 'C+1', 'C+2', 'Blue C+3'});
% set(gca, 'Xtick', xTick);
% set(gca, 'XTickLabel', labelList);
% 
% subplot(1,2,2); hold on;
% title('Material only')
% for s = 1:nSubjects
%     plot(subject{s}.positionDerivedMat, 'o' , 'MarkerFaceColor', color, 'MarkerEdgeColor', color,'MarkerSize', thisMarkerSize)
% end
% line([0 nSubjects+1], [4 4],'LineStyle','--', 'color', 'k')
% axis([0 nSubjects+1 1 7])
% xlabel('Subject')
% ylabel('Inferred position')
% set(gca, 'Ytick', [1:7]);
% set(gca, 'Xtick', xTick);
% set(gca, 'XTickLabel', labelList);
% set(gca, 'YTickLabel', {'Matte C-3', 'C-2', 'C-1', 'T', 'C+1', 'C+2', 'Glossy C+3'});
% savefigghost(['RecoveredPositions'], gcf, 'pdf')
% 
% %close all;
% figure;  hold on
% plot(targetCompetitorFitC(2:end), 'ko-');
% plot(targetCompetitorFitM(2:end), 'bo-');
% plot(4,targetCompetitorFitC(1), 'kx');
% plot(4,targetCompetitorFitM(1), 'bx');
% legend('color', 'material', 'Location', 'Best')
% axis([0 8 0 2])