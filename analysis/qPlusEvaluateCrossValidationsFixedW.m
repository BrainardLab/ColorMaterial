% qPlusEvaluateCrossValidations
% Review the results of the cross validations for different models. 

% Initialize
clear; close all; 

% Set params
subjectList = {'nzf', 'dca', 'hmn', 'ofv', 'gfn', 'ckf', ...
    'lma', 'lza', 'sel', 'jcd' , 'nkh', 'cjz'};

bestModel = {'Full', 'Full', 'Full', 'Full', 'Cubic', 'Cubic', ...
    'Quadratic', 'Quadratic', 'Quadratic', 'Linear', 'Full',  'Cubic'}; 

distance = {'cityblock', 'cityblock', 'euclidean', 'cityblock','euclidean', 'euclidean', ...
     'cityblock', 'cityblock', 'cityblock','cityblock', 'euclidean', 'cityblock'}; 

analysisDir = [getpref('ColorMaterial', 'analysisDir'), '/E3/']; 

ww = round(linspace(0.01,0.99,10),2); 
for ss = 1:length(subjectList)
    clear temp
    temp = load([analysisDir, subjectList{ss} distance{ss} bestModel{ss} 'Fit.mat']);
    
    % Check that we fit the right distance
    if ~ strcmp( distance{ss}, temp.params.whichDistance)
        error('Not the right distance');
    end
    weight(ss) = temp.thisSubject.returnedW; 
    
    for w = 1:length(ww)
        k = load([analysisDir, subjectList{ss} '-8FoldsCV-' bestModel{ss} 'W' num2str(ww(w)) '-' distance{ss} '.mat']);
        logLik{ss}(w,:) = k.logLikelyhood;
        % check that we fit the right model
        switch bestModel{ss}
            case 'Full'
                if length(k.dataSet{1}.trainingSet.returnedParams) ~= 16
                    error([subjectList{ss} ' wrong model!'])
                end
            case 'Cubic'
                if length(k.dataSet{1}.trainingSet.returnedParams) ~= 8
                    error([subjectList{ss} ' wrong model!'])
                end
            case 'Quadratic'
                if length(k.dataSet{1}.trainingSet.returnedParams) ~= 6
                    error([subjectList{ss} ' wrong model!'])
                end
            case 'Linear'
                if length(k.dataSet{1}.trainingSet.returnedParams) ~= 4
                    error([subjectList{ss} ' wrong model!'])
                end
        end
    end
    
    figure; hold on; title(subjectList{ss});
    sem{ss} = std(logLik{ss}, [], 2)/sqrt(8); 
    errorbar(ww, mean(logLik{ss},2),  sem{ss}, 'ro--'); 
    line([weight(ss), weight(ss)], [-1000 0], 'Color', 'r', 'LineWidth', 2)
    axis([0 1 min(mean(logLik{ss},2))-2, max(mean(logLik{ss},2))+2])
    cd (analysisDir)
    FigureSave([subjectList{ss} bestModel{ss} distance{ss} 'CrossValFixedWeight'],gcf,'pdf');
end
