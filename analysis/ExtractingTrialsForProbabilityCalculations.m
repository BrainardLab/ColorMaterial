% ExtractingTrailsForProbabiltyCalculations
% Find trials that have repeated more than once and sort them for plotting.
% This is used in to plot the data against color material matching
% functions. 
% 07/xx/2018 ar Wrote it. 

% Initialize;
clear; close all;

subjectList = {'hmneuclideanFull', 'dcacityblockFull', 'gfneuclideanCubic', 'lmacityblockQuadratic', 'ofvcityblockFull',...
    'selcityblockQuadratic', 'ckfeuclideanCubic', 'lzacityblockQuadratic', 'cjzcityblockCubic', 'jcdcityblockLinear', 'nkheuclideanFull', 'nzfcityblockFull'};
subjectListID = {'hmn','dca', 'gfn', 'lma', 'ofv', 'sel','ckf', 'lza',  'cjz', 'jcd',  'nkh', 'nzf'};

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3'];
codeDir  = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis';
whichSet = 3; % 2 = colorAxis; 3 = materialAxis

% sort indices.
nRep = 10;
c1Index = 1;
c2Index = 2;
m1Index = 3;
m2Index = 4;
nMatLevels = 7;
nColorLevels = 7;

for s = 1:length(subjectList)
    clear newData newDataRev cmMatrixNtrials cmMatrixNfirstChosen cmDataPoints
    
    % Load data
    load([analysisDir '/' subjectList{s}, 'Fit.mat'])
    
    % Specify the conditions for extraction.
    % 1) Extract data from trials that are repeated at least 10 times.
    moreThanOnce = thisSubject.newNTrials >= nRep;
    % 2) Make sure that at least one of the trials is on axis
    onAxis = sum(thisSubject.newTrialData(:,1:4)==0,2)>0;
    index = moreThanOnce & onAxis;
    
    % Reorganize the data into color material matrix for plotting.
    newData = thisSubject.newTrialData(index,:);
    
    % keep track of different number of trials per subject.
    howMany(s) = sum(index);
    nMaterialVaryOnly(s) = sum((newData(:,c1Index) == 0) & (newData(:,c2Index) == 0));
    nColorVaryOnly(s) = sum((newData(:,m1Index) == 0) & (newData(:,m2Index) == 0));
    nColorMatVary1(s) = sum((newData(:,c1Index) == 0) & (newData(:,m2Index) == 0));
    nColorMatVary2(s) = sum((newData(:,c2Index) == 0) & (newData(:,m1Index) == 0));
    sumAll(s) = nMaterialVaryOnly(s) + nColorVaryOnly(s) + nColorMatVary1(s) + nColorMatVary2(s);
    
    % Get reversed data (case when color match is second)
    newDataRev = newData(:, end) - newData(:,end-1);
    
    % Create matrices we're going to inegrate data over.
    cmMatrixNtrials = nan(7,7);
    cmMatrixNfirstChosen = nan(7,7);
    
    % Integrate all the trials and compute the probability.
    for c1 = 1:nColorLevels % competitor1
        for c2 = 1:nMatLevels % competitor 2
            
            % Need to loop through all combinations
            for i  = 1:size(newData,1)
                if whichSet == 1
                    firstC1 = (newData(i,c1Index) == 0) && (newData(i,m1Index) == (c2-4));
                    secondC2 = (newData(i,c2Index) == (c1-4)) && (newData(i,m2Index) == 0);
                    secondC1 = (newData(i,c2Index) == 0) && (newData(i,m2Index) == (c2-4));
                    firstC2 = (newData(i,c1Index) == (c1-4)) && (newData(i,m1Index) == 0);
                elseif whichSet == 2
                    firstC1 = (newData(i,c1Index) == (c1-4)) && (newData(i,m1Index) == 0);
                    secondC2 = (newData(i,c2Index) == (c2-4)) && (newData(i,m2Index) == 0);
                    secondC1 = (newData(i,c2Index) == (c2-4)) && (newData(i,m2Index) == 0);
                    firstC2 = (newData(i,c1Index) == (c1-4)) && (newData(i,m1Index) == 0);
                elseif whichSet == 3
                    firstC1 = (newData(i,c1Index) == 0 ) && (newData(i,m1Index) == (c1-4));
                    secondC2 = (newData(i,c2Index) == 0) && (newData(i,m2Index) == (c2-4));
                    secondC1 = (newData(i,c2Index) == 0 ) && (newData(i,m2Index) == (c2-4));
                    firstC2 = (newData(i,c1Index) == 0) && (newData(i,m1Index) == (c1-4));
               end
                % Plots the percent of time color match is chosen.
                if firstC1  && secondC2
                    if ~isnan(cmMatrixNfirstChosen(c1,c2))
                        disp('overwriting')
                        cmMatrixNfirstChosen(c1,c2) = cmMatrixNfirstChosen(c1,c2) + newData(i,end-1);
                        cmMatrixNtrials(c1,c2) = cmMatrixNtrials(c1,c2) + newData(i,end);
                    else
                        cmMatrixNfirstChosen(c1,c2) = newData(i,end-1);
                        cmMatrixNtrials(c1,c2) = newData(i,end);
                    end
                elseif secondC1  && firstC2
                    if ~isnan(cmMatrixNfirstChosen(c1,c2))
                        disp('overwriting')
                        cmMatrixNfirstChosen(c1,c2) = cmMatrixNfirstChosen(c1,c2) + newDataRev(i);
                        cmMatrixNtrials(c1,c2) = cmMatrixNtrials(c1,c2) + newData(i,end);
                    else
                        cmMatrixNfirstChosen(c1,c2) = newDataRev(i);
                        cmMatrixNtrials(c1,c2) = newData(i,end);
                    end
                end
            end
        end
    end
    cmDataPoints = cmMatrixNfirstChosen./cmMatrixNtrials;
    cd(analysisDir)
    if whichSet == 1
        save([subjectListID{s} '-colorMaterialDataPoints'], 'cmDataPoints');
    elseif whichSet == 2
        save([subjectListID{s} '-colorOnlyDataPoints'], 'cmDataPoints');
    elseif whichSet == 3
        save([subjectListID{s} '-materialOnlyDataPoints'], 'cmDataPoints');
    end
end



