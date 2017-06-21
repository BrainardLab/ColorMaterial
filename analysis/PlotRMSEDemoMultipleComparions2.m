
%Initialize 
clear; close all; 

% Set params. 
fixedWValue = [0.1:0.1:0.9];
simulateWeigth = [0.25, 0.5, 0.75];
nBlocks1  = 24; 
nBlocks2 = 56; 
interCode = 'C'; 
% Compare linear and cubic
nLoops = 10; 
cd('/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots/')
for i = 1:length(simulateWeigth)
    for whichLoop = 1:nLoops
        F1 = load(['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots/' interCode num2str(nBlocks1) 'saveRetParamsFixed1.mat']);
        F2 = load(['/Users/ana/Dropbox (Aguirre-Brainard Lab)/CNST_analysis/ColorMaterial/demoPlots/' interCode num2str(nBlocks2) 'saveRetParamsFixed1.mat']);
       
        %F1a =   load(['L' num2str(nBlocks1) 'returnedParamsFixed.mat']);
        V1(whichLoop) = load([interCode num2str(nBlocks1) 'saveRetParamsVary' num2str(whichLoop) '.mat']);
        V2(whichLoop) = load([interCode num2str(nBlocks2) 'saveRetParamsVary' num2str(whichLoop) '.mat']);
        
        % F2 = load([interCode num2str(nBlocks2) 'returnedParamsFixed.mat']);
        % %F2a =   load(['L' num2str(nBlocks2) 'returnedParamsFixed.mat']);
        % V2 = load([interCode num2str(nBlocks2) 'returnedParamsVary.mat']);
        
        % get max axis for rmse
        tmpMax = ceil(max([max(F1.rmse),max(V1(whichLoop).rmse)])*10)/10;
        m = [];
        n = [];
        nn = 0;
        mm = 0; 
        % check that recovered positions are within range
        for j = 1:length(fixedWValue)
            for k = 1:length(F1.returnedParams{i,j})
                if (abs(F1.returnedParams{i,j}(k)) >= 20)
                    error;
                end
                if (abs(V1(whichLoop).returnedParams{i}(k)) >= 20)
                    error;
                end
                
                % keep track of the ends of the scale
                m = [m; F1.returnedParams{i,j}(1), F1.returnedParams{i,j}(7)];
                mm = mm+1;
            end
            if j == 1
                n = [n; V1(whichLoop).returnedParams{i}(1), V1(whichLoop).returnedParams{i}(7), ...
                    V1(whichLoop).returnedParams{i}(8), V1(whichLoop).returnedParams{i}(14), ...
                    ];
                nn = nn+1;
            end
        end
        recoveredWVary1(whichLoop, i) = V1(whichLoop).returnedParams{i}(end-1);
        recoveredWVary2(whichLoop, i) = V2(whichLoop).returnedParams{i}(end-1);
    
    end
end

for i = 1:length(simulateWeigth)
    figure; clf; hold on;
    for whichLoop = 1:nLoops
        line([recoveredWVary1(whichLoop, i) recoveredWVary1(whichLoop, i)], [0 1], 'color', 'r')
        line([recoveredWVary2(whichLoop, i) recoveredWVary2(whichLoop, i)], [0 1], 'color', 'b')
        
        for j = 1:length(fixedWValue)
            plot(fixedWValue(j), F1.rmse(i,j), 'ro')
            plot(fixedWValue(j), F2.rmse(i,j), 'bo')
            
            %         plot(fixedWValue(j), F1a.rmse1(i,j), 'mo')
            %         plot(fixedWValue(j), F1a.rmse2(i,j), 'ko')
            %         plot(fixedWValue(j), F2a.rmse1(i,j), 'mo', 'MarkerFaceColor', 'm')
            %         plot(fixedWValue(j), F2a.rmse2(i,j), 'ko', 'MarkerFaceColor', 'k')
            %
            if (F1.returnedParams{i,j}(end-1)) ~= fixedWValue(j)
                error;
            end
        end
        
        %     legend(num2str(nBlocks1),  ['withinDim' num2str(nBlocks1)], ['acrossDim' num2str(nBlocks1)], ...
        %         ['withinDim' num2str(nBlocks2)], ['acrossDim' num2str(nBlocks2)], ...
        %         'Location', 'NorthEast')
        
        plot(recoveredWVary1(whichLoop, i), V1(whichLoop).rmse(i), 'rx', 'LineWidth', 2)
        line([simulateWeigth(i) simulateWeigth(i)], [0 1], 'color', 'k', 'LineWidth', 2)
        
        axis([0 1 0 tmpMax])
        xlabel('FixedWeigth')
        ylabel('RMSE')
    end
    FigureSave([interCode num2str(i) 'RMSE'], gcf, 'pdf')
end


%% plot recovered positions with two different types of weigths.
% Examining positions with recovered weigth vary.
fColor = figure; hold on;
xMin = -20;
yMin = xMin;
xMax = 20;
yMax = xMax;
thisMarkerSize = 10;
thisFontSize = 10; thisLineWidth = 1;
for i = 1:3
    for whichLoop = 1:nLoops
        subplot(1,2,1); hold on % plot of material positions
        plot(V1(whichLoop).params.materialMatchColorCoords, V1(whichLoop).returnedParams{i}(8:14),'ro-', 'MarkerSize', thisMarkerSize);
        plot(V2(whichLoop).params.materialMatchColorCoords, V2(whichLoop).returnedParams{i}(8:14),'bo-', 'MarkerSize', thisMarkerSize);
        
        plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
        axis([xMin, xMax,yMin, yMax])
        axis('square')
        xlabel('"True" position');
        ylabel('Inferred position');
        set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
        set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
        
        subplot(1,2,2); hold on % plot of material positions
        plot(V1(whichLoop).params.colorMatchMaterialCoords, V1(whichLoop).returnedParams{i}(1:7),'ro-', 'MarkerSize', thisMarkerSize);
        plot(V2(whichLoop).params.colorMatchMaterialCoords, V2(whichLoop).returnedParams{i}(1:7),'bo-', 'MarkerSize', thisMarkerSize);
        
        plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
        axis([xMin, xMax,yMin, yMax])
        axis('square')
        xlabel('"True" position');
        ylabel('Inferred position');
        set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
        set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
    end
end
FigureSave([interCode num2str(i) 'Positions'], gcf, 'pdf')
comparison1  = abs(recoveredWVary1 - repmat(simulateWeigth, [nLoops,1])); 
comparison2 = abs(recoveredWVary2 - repmat(simulateWeigth, [nLoops,1])); 
