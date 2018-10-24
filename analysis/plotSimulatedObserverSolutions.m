% plotSimulatedObserverSolutions
% Plots recovered parameters for simulated observer 
% Simulated observer is obtained via simulation in the experimental code
% (see ColorMatExp3Driver.m, option SIMULATE)
% 
% 10/23/2018 ar Wrote it. 

% Initialize
clear; close all;

whichExperiment = 'E3';
analysisDir  = fullfile(getpref('ColorMaterial', 'analysisDir'),['/' whichExperiment '/']);

% Load real observers and their simulated counterparts
subjectListSim = {'gfksimeuclideanCubic', 'lzasimcityblockQuadratic', 'nkhsimeuclideanFull'};
subjectList = {'gfneuclideanCubic', 'lzacityblockQuadratic', 'nkheuclideanFull'};

for s = 1:length(subjectList)
    cd(analysisDir)
    simulated{s} = load([subjectList{s} 'Fit.mat']);
    recovered{s} = load([subjectListSim{s} 'Fit.mat']);
    
    % Plot diagnostics. 
    fprintf('Simulated weight %0.2f. Recovered weight %0.2f.\n', simulated{s}.thisSubject.returnedW, recovered{s}.thisSubject.returnedW)
end

%Plotting parameters
colors = {[0.9290, 0.6940, 0.1250] , [0.4940, 0.1840, 0.5560], [0.4660, 0.6740, 0.1880]};
thisMarkerSize = 12;
thisFontSize = 13; 
xMin = -20; 
xMax = 20; 
yMin = xMin; 
yMax = xMax;

% Make figure: plot color and material coordinates
figure;title(subjectList{s})
subplot(1,2,1); hold on;
for s = 1:length(subjectList)
    plot(simulated{s}.thisSubject.returnedMaterialMatchColorCoords, recovered{s}.thisSubject.returnedMaterialMatchColorCoords, ...
       'o', 'MarkerFaceColor', colors{s}, 'MarkerEdgeColor', colors{s}, 'MarkerSize', thisMarkerSize);
end
line([xMin, xMax],[yMin,yMax], 'color', 'k')
axis([xMin xMax yMin yMax]); axis square;
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
xlabel('Simulated Positions (Color)', 'FontSize', thisFontSize);
ylabel('Recovered Positions (Color)', 'FontSize', thisFontSize);

subplot(1,2,2); hold on;
for s = 1:length(subjectList)
plot(simulated{s}.thisSubject.returnedColorMatchMaterialCoords, recovered{s}.thisSubject.returnedColorMatchMaterialCoords,...
        'o', 'MarkerFaceColor', colors{s}, 'MarkerEdgeColor', colors{s},  'MarkerSize', thisMarkerSize);

end
line([xMin, xMax],[yMin,yMax], 'color', 'k')
axis([xMin xMax yMin yMax]); axis square;
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
xlabel('Simulated Positions (Material)','FontSize', thisFontSize);
ylabel('Recovered Positions (Material)','FontSize', thisFontSize);
FigureSave(['SimulatedVsRecoveredPositions'],gcf,'pdf');
