% qPlusEvaluateCrossValidations
% Review the results of the cross validations for different models. 

% Initialize
clear; close all; 

% Set params
subjectList = {'ofv', 'dca', 'lza', 'ckf', 'hmn', 'sel', 'jcd'};
analysisDir = [getpref('ColorMaterial', 'analysisDir'), '/E3']; 
whichDistance = 'euclidean'; 
cd(analysisDir)
for ss = 1:length(subjectList)
    full{ss} = load([subjectList{ss} '-8FoldsCV-Full-' whichDistance '.mat']);
    cubic{ss} = load([subjectList{ss} '-8FoldsCV-Cubic-' whichDistance '.mat']);
    hyp1(ss,1) = ttest(full{ss}.logLikelyhood, cubic{ss}.logLikelyhood,  'tail' , 'right');
    quadratic{ss} = load([subjectList{ss} '-8FoldsCV-Quadratic-' whichDistance '.mat']);
    hyp1(ss,2) = ttest(cubic{ss}.logLikelyhood, quadratic{ss}.logLikelyhood, 'tail' , 'right');
    linear{ss} = load([subjectList{ss} '-8FoldsCV-Linear-' whichDistance '.mat']);
    hyp1(ss,3) = ttest(quadratic{ss}.logLikelyhood, linear{ss}.logLikelyhood, 'tail' , 'right');
end
whichDistance = 'cityblock'; 
for ss = 1:length(subjectList)
    fullcb{ss} = load([subjectList{ss} '-8FoldsCV-Full-' whichDistance '.mat']);
    cubiccb{ss} = load([subjectList{ss} '-8FoldsCV-Cubic-' whichDistance '.mat']);
    hyp2(ss,1) = ttest(fullcb{ss}.logLikelyhood, cubiccb{ss}.logLikelyhood,  'tail' , 'right');
    quadraticcb{ss} = load([subjectList{ss} '-8FoldsCV-Quadratic-' whichDistance '.mat']);
    hyp2(ss,2) = ttest(cubiccb{ss}.logLikelyhood, quadraticcb{ss}.logLikelyhood, 'tail' , 'right');
    linearcb{ss} = load([subjectList{ss} '-8FoldsCV-Linear-' whichDistance '.mat']);
    hyp2(ss,3) = ttest(quadraticcb{ss}.logLikelyhood, linearcb{ss}.logLikelyhood, 'tail' , 'right');
end

% 
figure; hold on 
for ss =  1:length(subjectList)
    errorbar(ss-0.15, full{ss}.meanLogLiklihood, std(full{ss}.logLikelyhood)/sqrt(8), 'rd');
    errorbar(ss-0.15, cubic{ss}.meanLogLiklihood, std(cubic{ss}.logLikelyhood)/sqrt(8), 'gx');
    errorbar(ss-0.15, quadratic{ss}.meanLogLiklihood, std(quadratic{ss}.logLikelyhood)/sqrt(8), 'bs');
    errorbar(ss-0.15, linear{ss}.meanLogLiklihood, std(linear{ss}.logLikelyhood)/sqrt(8), 'mo');
    errorbar(ss+0.15, fullcb{ss}.meanLogLiklihood, std(fullcb{ss}.logLikelyhood)/sqrt(8), 'rd');
    errorbar(ss+0.15, cubiccb{ss}.meanLogLiklihood, std(cubiccb{ss}.logLikelyhood)/sqrt(8), 'gx');
    errorbar(ss+0.15, quadraticcb{ss}.meanLogLiklihood, std(quadraticcb{ss}.logLikelyhood)/sqrt(8), 'bs');
    errorbar(ss+0.15, linearcb{ss}.meanLogLiklihood, std(linearcb{ss}.logLikelyhood)/sqrt(8), 'mo');
end
axis([0 length(subjectList)+1 -70 -40])
set(gca,'XTick', [0:(length(subjectList)+1)]) 
set(gca,'XTickLabel', {'', 'ofv', 'dca', 'lza', 'ckf', 'hmn', 'sel', 'jcd', '' }) 
FigureSave(['CrossValRes2'],gcf,'pdf');