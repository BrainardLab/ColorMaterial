% AnalyzeColorMatExp1

% 09/30/16 ar Adapted it from the pilot code.

% Initialize.
clc; clear ; close all;

% Specify directories
analysisDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/E1P2';
dataDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/';
codeDir = 'Users/Shared/Matlab/Experiments/ColorMaterial/code/';
expName = 'E1P2';
figDir = ['/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/' expName '/FiguresExp1'];

% Specify other experimental parameters
subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
nSubjects = length(subjectList);
nLevels = 7; % number of levels across which color/material vary
nBlocks = 24;
conditionCode = {'NC', 'CY', 'CB'};
nConditions  = 3;
nTrialsPerCondition = 49;
colorCondition = {[0.5, 0.5, 0.5], [255, 204, 102]./255, [0, 153, 255]./255};
colors = {'r', 'g', 'b', [0, 0, 0]'};
nConditions = length(conditionCode);

for s = 1:nSubjects
    subject{s}.Name = subjectList{s};
    fprintf('Subject %s.\n', subject{s}.Name)
    load(['/Users/Shared/Matlab/Experiments/ColorMaterial/code/' subject{s}.Name 'stimulusList.mat']);
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
    
    % parse the conditions
    for whichCondition = 1:nConditions
        startFrom = (whichCondition-1)*nTrialsPerCondition+1;
        endAt = nTrialsPerCondition*whichCondition;
        subject{s}.condition{whichCondition}.pChosen = subject{s}.pFirstChosen(startFrom:endAt);
        subject{s}.condition{whichCondition}.competitorPairList = imageList(startFrom:endAt);
    end
    
    for whichCondition = 1:nConditions
        % Step 2. Make and fill in the matrix for the color/material trade off.
        subject{s}.condition{whichCondition}.pC = NaN(nLevels, nLevels);
        for whichMaterialOfTheColorMatch = 1:nLevels % for each of these material changes
            for whichColorOfTheMaterialMatch = 1:nLevels % and each of these color levels
                targetString = [subject{s}.Name conditionCode{whichCondition} 'C4M' num2str(whichMaterialOfTheColorMatch)];
                otherString = [subject{s}.Name conditionCode{whichCondition} 'C' num2str(whichColorOfTheMaterialMatch) 'M4'];
                whichString1 = {[targetString '-' otherString]}; % search for these strings.
                whichString2 = {[otherString '-' targetString]};
                for i = 1:length(subject{s}.condition{whichCondition}.competitorPairList)
                    clear tempString
                    tempString =  subject{s}.condition{whichCondition}.competitorPairList{i}(6:end);
                    if strcmp(tempString, whichString1) || strcmp(tempString, whichString2)
                        if strcmp(tempString(1:length(targetString)), targetString) % if target string is first
                            subject{s}.condition{whichCondition}.pC(whichMaterialOfTheColorMatch,whichColorOfTheMaterialMatch) = subject{s}.condition{whichCondition}.pChosen(i);
                        elseif strcmp(tempString((end-length(targetString)+1):end), targetString) % if target string is second
                            subject{s}.condition{whichCondition}.pC(whichMaterialOfTheColorMatch, whichColorOfTheMaterialMatch) = 1-subject{s}.condition{whichCondition}.pChosen(i);
                        end
                    end
                end
                clear targetString otherString whichString1 whichString2
            end
        end
        
        % Note that we can also make an inverse data calculation from the one above. 
        
    end
    
    thisFontSize = 6; 
    thisMarkerSize = 4; 
    
    % Step 5. Plot the color/material differences.
    figure; clf; 
    for whichCondition = 1:nConditions
        subplot(1,3,whichCondition); hold on; 
        % material Differences: 3 steps
        plot(subject{s}.condition{whichCondition}.pC(1,:), 'o-', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1}, 'MarkerSize', thisMarkerSize)
        plot(subject{s}.condition{whichCondition}.pC(7,:), 'o--', 'MarkerFaceColor', colors{1}, 'color', colors{1},  'MarkerEdgeColor', colors{1},'MarkerSize',thisMarkerSize)
        % material Differnces: 2 steps
        plot(subject{s}.condition{whichCondition}.pC(2,:), 'o-', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2},'MarkerSize', thisMarkerSize)
        plot(subject{s}.condition{whichCondition}.pC(6,:), 'o--', 'MarkerFaceColor', colors{2}, 'color', colors{2},  'MarkerEdgeColor', colors{2},'MarkerSize', thisMarkerSize)
        % material Differences: 1 step
        plot(subject{s}.condition{whichCondition}.pC(3,:), 'o-', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3},'MarkerSize', thisMarkerSize)
        plot(subject{s}.condition{whichCondition}.pC(5,:), 'o--', 'MarkerFaceColor', colors{3}, 'color', colors{3},  'MarkerEdgeColor', colors{3},'MarkerSize', thisMarkerSize)
        % material difference 0
        plot(subject{s}.condition{whichCondition}.pC(4,:), 'o-', 'MarkerFaceColor', colors{4}, 'color', colors{4},  'MarkerEdgeColor', colors{4},'MarkerSize', thisMarkerSize)
        axis([0 8 0 1])
        xlabel('delta Color')
        ylabel('p C4Mx Chosen')
        if whichCondition==1
            title([ subjectList{s} ' ' conditionCode{whichCondition}])
        else
            title(conditionCode{whichCondition})
        end
        axis square
        set(gca, 'Xtick', [0:8]);
        set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''}, 'FontSize', thisFontSize);
        line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
        cd (figDir)
    end
    FigureSave([subjectList{s} 'ColorMatchMaterialLure'], gcf, 'pdf')
    cd (analysisDir)
    
    % Step 6a. Plot the color/material differences, summarized.
    figure; clf; hold on;
    % material Differences: 3 steps
    for whichCondition = 1:nConditions
        
        subplot(1,4,1); hold on
        title([subjectList{s} ' Step 0'])
        plot([subject{s}.condition{whichCondition}.pC(4, :)], 'o-', ...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        axis([0 8 0 1]); axis square
        xlabel('delta Color')
        ylabel('p C4Mx Chosen')
        set(gca, 'Xtick', [0:8]);
        set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''}, 'FontSize', thisFontSize);
        line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
        axis square
        
        subplot(1,4,2); hold on
        title(['Step 1'])
        plot([subject{s}.condition{whichCondition}.pC(3, :)], 'o-', ...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        plot([subject{s}.condition{whichCondition}.pC(5, :)], 'o--', ...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        axis([0 8 0 1]); axis square
        xlabel('delta Color')
        ylabel('p C4Mx Chosen')
        set(gca, 'Xtick', [0:8]);
        set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''}, 'FontSize', thisFontSize);
        line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
        axis square
        
        subplot(1,4,3); hold on
        title(['Step 2'])
        plot([subject{s}.condition{whichCondition}.pC(2, :)], 'o-', ...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        plot([subject{s}.condition{whichCondition}.pC(6, :)], 'o--', ...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        axis([0 8 0 1]); axis square
        xlabel('delta Color')
        ylabel('p C4Mx Chosen')
        set(gca, 'Xtick', [0:8]);
        set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''}, 'FontSize', thisFontSize);
        line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
        axis square
        
        subplot(1,4,4); hold on
        title(['Step 3'])
        plot([subject{s}.condition{whichCondition}.pC(1, :)], 'o-', ...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        plot([subject{s}.condition{whichCondition}.pC(7, :)], 'o--',...
            'MarkerFaceColor', colorCondition{whichCondition}, 'color', colorCondition{whichCondition},  'MarkerEdgeColor', colorCondition{whichCondition}, 'MarkerSize', thisMarkerSize)
        axis([0 8 0 1]); axis square
        xlabel('delta Color')
        ylabel('p C4Mx Chosen')
        set(gca, 'Xtick', [0:8]);
        set(gca, 'xTickLabel', {'', 'C-3', 'C-2', 'C-1', 'C0','C+1', 'C+2', 'C+3', ''}, 'FontSize', thisFontSize);
        line([4 4],[0 1], 'LineStyle','--', 'color', 'k')
        axis square
    end
    cd (figDir)
    FigureSave([subjectList{s} 'ColorMatchMaterialLureAveraged'], gcf, 'pdf')
    cd (analysisDir)
    
    thisSubject = subject{s};
    save([subject{s}.Name, 'data'], 'thisSubject');
    
end
