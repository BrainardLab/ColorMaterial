% Find selection based match Experiment 2

% Initialize
clear; close all;

subjectList = {'ifj', 'krz', 'ueh'};
nConditions = 3;
nSubjects  = length(subjectList);

currentDir = pwd;
dataDir = '/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/E1P1/';
cd ..
cd code/
load('blobCompetitors.mat')
load('blobConstancyExp1.mat')
cd (currentDir);

nBlocks = 28;
NCtrials = [1:10];
CBtrials = [32:52];
CYtrials = [11:31];
tristimulusSample = 1;
reflectanceSample = 6;
reflectanceSampleNC = 3;
saveData =  1; 

for s = 1:nSubjects
    % Tally up the choices for all blocks (independent of condition).
    for b = 1:nBlocks
        % get the selections from the data for each block
        clear tmp
        tmp = load(['/Users/radonjic/Dropbox (Aguirre-Brainard Lab)/CNST_data/ColorMaterial/E1P1/' subjectList{s} '/' subjectList{s} '-E1P1-' num2str(b) '.mat']);
        for t = 1:length(tmp.params.trial)
            if (tmp.params.trial(t).imageChosen == 1)
                subject{s}.trialChoices(b,t) = 1;
            elseif (tmp.params.trial(t).imageChosen == 2)
                subject{s}.trialChoices(b,t) = 0;
            else
                error('no such image');
            end
        end
    end
    subject{s}.summedSelections = sum(subject{s}.trialChoices,1);
    subject{s}.totalTrials = sum(~isnan(subject{s}.trialChoices));
    % pars into conditions
    subject{s}.selectionsNC = subject{s}.summedSelections(NCtrials);
    subject{s}.selectionsCY = subject{s}.summedSelections(CYtrials);
    subject{s}.selectionsCB = subject{s}.summedSelections(CBtrials);
    
    subject{s}.totalTrialsNC = subject{s}.totalTrials(NCtrials);
    subject{s}.totalTrialsCY= subject{s}.totalTrials(CYtrials);
    subject{s}.totalTrialsCB = subject{s}.totalTrials(CBtrials);
    
    % Get the selection based match from subjects choices
    [subject{s}.targetCompetitorFitNC, subject{s}.logLikelyFitNC, subject{s}.predictedResponsesNC] = MLDSColorSelection(competitorPairs.nPairsNC,subject{s}.selectionsNC,subject{s}.totalTrialsNC, max(competitorPairs.nPairsNC(:))); %#ok<SAGROW>
    [subject{s}.targetCompetitorFitCY, subject{s}.logLikelyFitCY, subject{s}.predictedResponsesCY] = MLDSColorSelection(competitorPairs.nPairsCY,subject{s}.selectionsCY,subject{s}.totalTrialsCY, max(competitorPairs.nPairsCY(:))); %#ok<SAGROW>
    [subject{s}.targetCompetitorFitCB, subject{s}.logLikelyFitCB, subject{s}.predictedResponsesCB] = MLDSColorSelection(competitorPairs.nPairsCB,subject{s}.selectionsCB,subject{s}.totalTrialsCB, max(competitorPairs.nPairsCB(:))); %#ok<SAGROW>
    
    
    % compute LAB for the inferred match and corresponding color constancy
    % index.
    [subject{s}.LabDerivedNC, subject{s}.positionDerivedNC] = ...
        MLDSInferMatchBlob(subject{s}.targetCompetitorFitNC, blobColors.competitorsLAB);
    
    subject{s}.distanceNoChange = ...
        pdist([subject{s}.LabDerivedNC'; blobColors.competitorsLAB(:,reflectanceSampleNC)'], 'euclidean');
    
    [subject{s}.LabDerivedCY, subject{s}.positionDerivedCY] = ...
        MLDSInferMatchBlob(subject{s}.targetCompetitorFitCY, blobColors.competitorsYellowLAB);
    
    [~,~,subject{s}.CCIYellow] = ...
        ComputeCCIndicesLab(blobColors.competitorsYellowLAB(:,tristimulusSample), ...
        blobColors.competitorsYellowLAB(:,reflectanceSample), ...
        subject{s}.LabDerivedCY);
    
    [subject{s}.LabDerivedCB, subject{s}.positionDerivedCB] = ...
        MLDSInferMatchBlob(subject{s}.targetCompetitorFitCB, blobColors.competitorsBlueLAB);
    
    [~,~,subject{s}.CCIBlue] = ...
        ComputeCCIndicesLab(blobColors.competitorsBlueLAB(:,tristimulusSample), ...
        blobColors.competitorsBlueLAB(:,reflectanceSample), ...
        subject{s}.LabDerivedCB);
    
    
    cd E1P1/
    if saveData
        thisSubject = subject{s};
        save([subjectList{s} 'E1P1'],'thisSubject'); clear thisSubject
        cd (currentDir)
    end
end
