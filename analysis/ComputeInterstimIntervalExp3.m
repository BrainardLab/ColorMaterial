% ComputeInterstimulusIntervalExp3
% Script computes the effective interstimulus interval for our experiment
% which is variable because qPlus takes variable amount of time to prepare
% new trial (and we would like to report the average ISI duration in the
% paper). 

% 06/xx/2018 ar Wrote it. 

% Initialize
clear; close all; 

% Paramters
subjectList = {'cjz', 'lma', 'nkh', 'gfn', 'ofv', 'dca', 'lza', 'ckf', 'hmn', 'sel', 'jcd', 'nzf'};
whichExperiment = 'E3';
nTrialsPerBlock = 270;
nBlocks = 8; 
pauseAfter = 30; % pause after this number of trials
dataDir = fullfile(getpref('ColorMaterial', 'dataFolder'),['/' whichExperiment '/']);

for s = 1:length(subjectList)
    sTime{s} = [];
    for b = 1:nBlocks
        fileName = [subjectList{s}, '/' subjectList{s}, '-E3-' num2str(b) '.mat'];
        warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
           
        temp = load([dataDir, fileName]);
        warnState = warning('off','MATLAB:dispatcher:UnresolvedFunctionHandle');
        
        for t = 1:(nTrialsPerBlock-1)
            if ~(rem(t,pauseAfter) == 0)
            sTime{s} = [sTime{s}, temp.params.trialStart(t+1)-temp.params.trialEnd(t)];
            end
        end
        clear temp
    end
end