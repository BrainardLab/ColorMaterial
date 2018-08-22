
%Initialize
clear; close all;
whichExperiment = 'Pilot';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/';
switch whichExperiment
    case 'E1P2'
        % Specify other experimental parameters
        subjectList = {'ifj', 'ueh', 'krz', 'mdc', 'nsk', 'zpf'};
        conditionCode = {'NC', 'CY', 'CB'};
        subjectList = { 'mdc','nsk'};
       
        
        figAndDataDir = [mainDir 'Experiment1'];
        
    case 'Pilot'
        % Specify other experimental parameters
        subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};
        conditionCode = {'NC'};
        figAndDataDir = [mainDir 'Pilot'];
        dataDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/data/';
end

cd(figAndDataDir); 
interpCode = 'C';
% Set params.
fixedWValue = [0.1:0.1:0.9];
whichError = 'logLik'; 
% Compare linear and cubic
for whichCondition = 1:length(conditionCode)
    for s = 1:length(subjectList)
        figure; clf; hold on;
        
        V = load([interpCode subjectList{s} 'SolutionNew-weightVary.mat']);
        
        for i  = 1:length(fixedWValue)
            tic
            F{i} = load([interpCode subjectList{s} 'SolutionNew-weightFixed' num2str(fixedWValue(i)*10) '.mat']);
            
            switch whichError
                case 'rmse'
                    plot(fixedWValue(i), F{i}.thisSubject.condition{whichCondition}.rmse, 'ro')
                    plot(V.thisSubject.condition{whichCondition}.returnedW, V.thisSubject.condition{whichCondition}.rmse, 'bo', 'MarkerFaceColor', 'b')
                    axis([0 1 0 0.3])
                    ylabel('RMSE')
                case 'logLik'
                    plot(fixedWValue(i), F{i}.thisSubject.condition{whichCondition}.logLikelyFit, 'ro')
                    plot(V.thisSubject.condition{whichCondition}.returnedW, V.thisSubject.condition{whichCondition}.logLikelyFit, 'bo', 'MarkerFaceColor', 'b')
                    axis([0 1  -380 -200])
                    ylabel('logLik')
            end
            
            %plot(fixedWValue(i), F{i}.thisSubject.condition{whichCondition}.rmse2, 'bo')
            
            %plot(V.thisSubject.condition{whichCondition}.returnedW, V.thisSubject.condition{whichCondition}.rmse2, 'bx')
            legend('Weigth Fixed', 'Weigth Varied','Location', 'NorthEast')
            line([V.thisSubject.condition{whichCondition}.returnedW, V.thisSubject.condition{whichCondition}.returnedW], [0 1], 'color', 'b', 'MarkerFaceColor', 'b')
            
            if (F{i}.thisSubject.condition{whichCondition}.returnedW ~= fixedWValue(i))
                error;
            end
            
            xlabel('FixedWeigth')
            
        end
        FigureSave([interpCode subjectList{s} conditionCode{whichCondition} 'RMSEFig'], gcf, 'pdf')
    end
end

