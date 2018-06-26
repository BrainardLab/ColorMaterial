% qPlusMakePartitionsForCrossValidation.m
% We create a fixed set of data partitions for cross validations for each
% subject to evaluate multiple instances of the model. 

% 04/20/2018 ar Wrote it. 

% Initialize
clear; close all; 

% Subjects to analyze
subjectList = {'nzf'};
nFolds = 8; 
nTrialsRun = 2160;

% Directory
analysisDir = [getpref('ColorMaterial','analysisDir'), '/E3']';

cd(analysisDir)
for s = 1:length(subjectList)
    c = cvpartition(nTrialsRun,'Kfold',nFolds);
    save([subjectList{s} 'partition'], 'c')
end
