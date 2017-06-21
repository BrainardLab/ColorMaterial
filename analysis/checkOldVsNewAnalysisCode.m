% CheckOldVsNewAnalysisCode

% The code is now rewritten to work with both experiments 1 and 2. 
% Note that the previous versions of the code color and material
% indicis were switched. Therefore, the current code compares the
% transposed results matrix. 
% 
clear all; close all;
subjectList = {'ifj','krz', 'mdc', 'nsk', 'ueh', 'zpf'};
nConditions = 3; 
for s = 1:length(subjectList)
    disp(s)
    cd('/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/E1P2')
    a = load([subjectList{s} 'data.mat']);
    b = load(['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Experiment1/' subjectList{s} 'SummarizedData.mat']);
    for whichCondition = 1:nConditions
        temp = a.thisSubject.condition{whichCondition}.pC-b.thisSubject.condition{whichCondition}.pC';
        if sum(temp(:)) ~=0
            error('stop');
        end
        clear temp; 
    end
    clear a b
end


% Pilot Experiment. 
% also note here that we didn't run target with equivalent tests pC(4,4) in
% this experiment. So we are here overwriting this cell with 0.5, to make the  
% comparison easier. 
clear all; close all;
subjectList = {'flj', 'vtr', 'mcv', 'zhr', 'scd'};
nConditions = 1;
for s = 1:length(subjectList)
    disp(s)
    a = load(['/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/Pilot/' subjectList{s} 'data.mat']);
    a.thisSubject.pC(4,4) = 0.5;
    b = load(['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/Pilot/' subjectList{s} 'SummarizedData.mat']);
    for whichCondition = 1:nConditions
        temp = a.thisSubject.pC'-b.thisSubject.condition{whichCondition}.pC;
        if sum(temp(:)) ~=0
            error('stop');
        end
        clear temp;
    end
    clear a b
end
