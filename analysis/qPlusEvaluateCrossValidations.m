% qPlusEvaluateCrossValidations
% Review the results of the cross validations for different models. 

% Initialize
clear; close all; 

% Set params
subjectList = {'lma', 'gfn', 'nkh', 'as'};
analysisDir = [getpref('ColorMaterial', 'analysisDir')]%, '/E3']; 
whichDistance = 'euclidean'; 
cd(analysisDir)
for ss = 1:3%length(subjectList)
    a = load([subjectList{ss} '-8FoldsCV-Full-' whichDistance '.mat']);
    b = load([subjectList{ss} '-8FoldsCV-Cubic-' whichDistance '.mat']);
    hyp(ss,1) = ttest2(a.logLikelyhood, b.logLikelyhood,  'tail' , 'right');
    c = load([subjectList{ss} '-8FoldsCV-Quadratic-' whichDistance '.mat']);
    hyp(ss,2) = ttest2(b.logLikelyhood, c.logLikelyhood, 'tail' , 'right');
    d = load([subjectList{ss} '-8FoldsCV-Linear-' whichDistance '.mat']);
    hyp(ss,3) = ttest2(c.logLikelyhood, d.logLikelyhood, 'tail' , 'right');
end

