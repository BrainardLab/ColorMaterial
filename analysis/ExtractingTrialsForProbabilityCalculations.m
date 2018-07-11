% ExtractingTrailsForProbabiltyCalculations
% Find trials that have repeated more than once and sort them for plotting.

% Initialize;
clear; close all;

subjectList = {'hmneuclideanFull', 'dcacityblockFull', 'gfneuclideanCubic', 'lmacityblockQuadratic', 'ofvcityblockFull',...
    'selcityblockQuadratic', 'ckfeuclideanCubic', 'lzacityblockQuadratic', 'ascityblockCubic', 'jcdcityblockLinear', 'nkheuclideanFull', 'nzfcityblockFull'};
subjectListID = {'hmn','dca', 'gfn', 'lma', 'ofv', 'sel','ckf', 'lza',  'as ', 'jcd',  'nkh', 'nzf'};

% Set directories and set which experiment to bootstrap
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3'];
codeDir  = '/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis';

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
    for c = 1:nColorLevels
        for m = 1:nMatLevels
            
            % Need to loop through all color/material data
            for i  = 1:size(newData,1)
                firstColorMatch = (newData(i,c1Index) == 0) && (newData(i,m1Index) == (m-4));
                secondMaterialMatch = (newData(i,c2Index) == (c-4)) && (newData(i,m2Index) == 0);
                secondColorMatch = (newData(i,c2Index) == 0) && (newData(i,m2Index) == (m-4));
                firstMaterialMatch = (newData(i,c1Index) == (c-4)) && (newData(i,m1Index) == 0);
                
                % Plots the percent of time color match is chosen.
                if firstColorMatch  && secondMaterialMatch
                    if ~isnan(cmMatrixNfirstChosen(c,m))
                        disp('overwriting')
                        cmMatrixNfirstChosen(c,m) = cmMatrixNfirstChosen(c,m) + newData(i,end-1);
                        cmMatrixNtrials(c,m) = cmMatrixNtrials(c,m) + newData(i,end);
                    else
                        cmMatrixNfirstChosen(c,m) = newData(i,end-1);
                        cmMatrixNtrials(c,m) = newData(i,end);
                    end
                elseif secondColorMatch  && firstMaterialMatch
                    if ~isnan(cmMatrixNfirstChosen(c,m))
                        disp('overwriting')
                        cmMatrixNfirstChosen(c,m) = cmMatrixNfirstChosen(c,m) + newDataRev(i);
                        cmMatrixNtrials(c,m) = cmMatrixNtrials(c,m) + newData(i,end);
                    else
                        cmMatrixNfirstChosen(c,m) = newDataRev(i);
                        cmMatrixNtrials(c,m) = newData(i,end);
                    end
                end
            end
        end
    end
    cmDataPoints = cmMatrixNfirstChosen./cmMatrixNtrials;
    cd(analysisDir)
    save([subjectListID{s} 'cmData'], 'cmDataPoints');
end