
%Initialize 
clear; close all; 

% Set params. 
fixedWValue = [0.1:0.1:0.9];
simulateWeigth = [0.25, 0.5, 0.75];
nBlocks1  = 24; 
nBlocks2 = 100; 
interCode = 'C'; 
% Compare linear and cubic
cd('/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots/')
F1 = load([ interCode num2str(nBlocks1) 'saveRetParamsFixed1.mat']); 
V1 = load([interCode num2str(nBlocks1) 'saveRetParamsVary1.mat']); 
F2 = load([interCode num2str(nBlocks2) 'saveRetParamsFixed1.mat']); 
V2 = load([interCode num2str(nBlocks2) 'saveRetParamsVary1.mat']); 

% get max axis for rmse
tmpMax = ceil(max([max(F1.rmse), max(V1.rmse), ...
        max(F2.rmse), max(V2.rmse), max(V2.rmse)])*10)/10; 
m = []; 
n = []; 
nn = 0; 
mm = 0; 
% check that recovered positions are within range
for i = 1:length(simulateWeigth)
    for j = 1:length(fixedWValue)
        for k = 1:length(F1.saveRetParams{i,j})
            if (abs(F1.saveRetParams{i,j}(k)) >= 20)
                error;
            end
            if (abs(V1.saveRetParams{i}(k)) >= 20)
                error;
            end
            if (abs(F2.saveRetParams{i,j}(k)) >= 20)
                error;
            end
            if (abs(V2.saveRetParams{i}(k)) >= 20)
                error;
            end
            % keep track of the ends of the scale
            m = [m; F1.saveRetParams{i,j}(1), F1.saveRetParams{i,j}(7), F2.saveRetParams{i,j}(1), F2.saveRetParams{i,j}(7)];
            mm = mm+1;
        end
        if j == 1
            n = [n; V1.saveRetParams{i}(1), V1.saveRetParams{i}(7), ...
                V1.saveRetParams{i}(8), V1.saveRetParams{i}(14), ...
                V2.saveRetParams{i}(1), V2.saveRetParams{i}(7), ...
                V2.saveRetParams{i}(8), V2.saveRetParams{i}(14), ...
                ];
            nn = nn+1;
        end
    end
end

for i = 1:length(simulateWeigth)
    recoveredWVary1(i) = V1.saveRetParams{i}(end-1); 
    recoveredWVary2(i) = V2.saveRetParams{i}(end-1); 
    
    figure; clf; hold on;
    line([recoveredWVary1(i) recoveredWVary1(i)], [0 1], 'color', 'r')
    line([recoveredWVary2(i) recoveredWVary2(i)], [0 1], 'color', 'r', 'LineStyle', '--')
    
    for j = 1:length(fixedWValue)
        plot(fixedWValue(j), F1.rmse(i,j), 'ro')
        plot(fixedWValue(j), F2.rmse(i,j), 'ro', 'MarkerFaceColor', 'r')
    
        if (F1.saveRetParams{i,j}(end-1)) ~= fixedWValue(j)
            error;
        end
         if (F2.saveRetParams{i,j}(end-1)) ~= fixedWValue(j)
            error;
        end
    end
    
    legend(num2str(nBlocks1), num2str(nBlocks2), ['rmse' num2str(nBlocks1)], ...
        ['rmse' num2str(nBlocks2)], ...
        'Location', 'NorthEast')
    
    plot(recoveredWVary1(i), V1.rmse(i), 'bo', 'LineWidth', 2)
    plot(recoveredWVary2(i), V2.rmse(i), 'bo', 'LineWidth', 2)
 
    line([simulateWeigth(i) simulateWeigth(i)], [0 1], 'color', 'k', 'LineWidth', 2)
    
    axis([0 1 0 tmpMax])
    xlabel('FixedWeigth')
    ylabel('RMSE')
    FigureSave([interCode num2str(i) 'RMSE'], gcf, 'pdf')
end

%% plot recovered positions with two different types of weigths. 
% Examining positions with recovered weigth vary. 
fColor = figure; hold on;
xMin = -10; 
yMin = xMin; 
xMax = 10; 
yMax = xMax; 
thisMarkerSize = 10; 
thisFontSize = 10; thisLineWidth = 1; 
for i = 1:3
    subplot(2,2,1); hold on % plot of material positions
    plot(V1.params.materialMatchColorCoords,V1.saveRetParams{i}(8:14),'ro-', 'MarkerSize', thisMarkerSize);
    plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
    axis([xMin, xMax,yMin, yMax])
    axis('square')
    xlabel('"True" position');
    ylabel('Inferred position');
    set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
    set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
    
    subplot(2,2,2); hold on % plot of material positions
    plot(V1.params.colorMatchMaterialCoords,V1.saveRetParams{i}(1:7),'bo-', 'MarkerSize', thisMarkerSize);
    plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
    axis([xMin, xMax,yMin, yMax])
    axis('square')
    xlabel('"True" position');
    ylabel('Inferred position');
    set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
    set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
    
    subplot(2,2,3); hold on % plot of material positions
    plot(V2.params.materialMatchColorCoords,V2.saveRetParams{i}(8:14),'ro-', 'MarkerSize', thisMarkerSize);
    plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
    %title('Color dimension')
    axis([xMin, xMax,yMin, yMax])
    axis('square')
    xlabel('"True" position');
    ylabel('Inferred position');
    set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
    set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
    
    subplot(2,2,4); hold on % plot of material positions
    plot(V2.params.colorMatchMaterialCoords,V2.saveRetParams{i}(1:7),'bo-', 'MarkerSize', thisMarkerSize);
    plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
    %title('Color dimension')
    axis([xMin, xMax,yMin, yMax])
    axis('square')
    xlabel('"True" position');
    ylabel('Inferred position');
    set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
    set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
end
FigureSave([interCode num2str(i) 'Positions'], gcf, 'pdf')