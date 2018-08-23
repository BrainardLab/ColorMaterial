% qPlusEvaluateCrossValidations
% Review the results of the cross validations for different models. 

% Initialize
clear; close all; 

% Set params
subjectList = {'nzf', 'nkh','dca', 'hmn', ...
    'ofv', 'gfn', 'ckf', 'lma',...
    'cjz', 'lza', 'sel', 'jcd'};
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
set(gca,'XTickLabel', {'','nzf', 'nkh','dca', 'hmn', 'ofv', 'gfn', 'ckf', 'lma', 'as', 'lza', 'sel', 'jcd', '' }) 
FigureSave(['CrossValRes2'],gcf,'pdf');



[H(1),P(1),CI(1,:),STATS{1}]  = ttest(full{1}.logLikelyhood, fullcb{1}.logLikelyhood); 
[H(2),P(2),CI(2,:),STATS{2}]  = ttest(full{2}.logLikelyhood, cubiccb{2}.logLikelyhood); 
[H(3),P(3),CI(3,:),STATS{3}]  = ttest(quadratic{3}.logLikelyhood, fullcb{3}.logLikelyhood); 
[H(4),P(4),CI(4,:),STATS{4}]  = ttest(full{4}.logLikelyhood, fullcb{4}.logLikelyhood); 
[H(5),P(5),CI(5,:),STATS{5}]  = ttest(full{5}.logLikelyhood, fullcb{5}.logLikelyhood); 
[H(6),P(6),CI(6,:),STATS{6}]  = ttest(cubic{6}.logLikelyhood, quadraticcb{6}.logLikelyhood); 
[H(7),P(7),CI(7,:),STATS{7}]  = ttest(cubic{7}.logLikelyhood, quadraticcb{7}.logLikelyhood); 
[H(8),P(8),CI(8,:),STATS{8}]  = ttest(quadraticcb{8}.logLikelyhood, quadraticcb{8}.logLikelyhood); 
[H(9),P(9),CI(9,:),STATS{9}]  = ttest(cubic{9}.logLikelyhood, cubiccb{9}.logLikelyhood); 
[H(10),P(10),CI(10,:),STATS{10}]  = ttest(quadratic{10}.logLikelyhood, quadraticcb{10}.logLikelyhood); 
[H(11),P(11),CI(11,:),STATS{11}]  = ttest(quadratic{11}.logLikelyhood, quadraticcb{11}.logLikelyhood); 
[H(12),P(12),CI(12,:),STATS{12}]  = ttest(linear{12}.logLikelyhood, linearcb{12}.logLikelyhood); 



