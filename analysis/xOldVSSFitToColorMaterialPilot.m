% FitToColorMaterial
%
% Analysis of preliminary data for color material cue combination
% experiment.
%
% 2/18/15  dhb  Wrote it.

% Clear and close
% clear; close all;
%function FitToColorMaterial(data, name)
% Some data to try fitting.  Ana's eye, 20 blocks.
% Each row is data for one value of delta C, each column
% for one value of delta M.  Thus the data down a column
% are for one material lure and each row is for one color lure.
%
% The data give the fraction of time the material lure is chosen.
clear; close all; 
analysisDir = pwd;
figDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/FiguresExp1';

theDeltaCs = [-3 -2 -1 0 1 2 3]';
theDeltaMs = [-3 -2 -1 1 2 3]';
AVERAGE_DM = true;
subjectList = {'vtr','scd','flj', 'zhr',  'mcv'};

blue = [28, 134, 238]./255; 
red = [238, 59, 59]./255; 
green = [34, 139, 34]./255.*1.2; 

for s = 1:length(subjectList)
    clear thisSubject theData
    cd ([analysisDir '/Pilot'])
    
    load([subjectList{s} 'data.mat'])
    
    theData = thisSubject.pC';
    nVals = size(theDeltaCs,1);
    
    % DM = 0 data
    theDataDM0 = thisSubject.pC(4,:)';
    
    %% Average the data for abs delta M.
    if (AVERAGE_DM)
        theDeltaMs = [3 2 1];
        theData = [mean(theData(:,[1,6]),2) mean(theData(:,[2,5]),2) mean(theData(:,[3,4]),2)];
    end
    nData = size(theData,2);
    
    % Smooth values for interpolation
    nSmoothVals = 100;
    theSmoothVals = linspace(theDeltaCs(1),theDeltaCs(end),nSmoothVals)';
    
    % Allocate some space
    thePreds = zeros(nVals,nData);
    theSmoothPreds = zeros(nSmoothVals,nData);
    
    % Set up search
    theScaleNeg0 = 0.5; 
    theScalePos0 = 0.5;
    theShape0 = 2;
    theMin0 = 0.25;
    theRange0 = 0.75;
    x0 = [theScaleNeg0 theScalePos0 theShape0 theMin0 theRange0]';
    
    % Set reasonable bounds on parameters
    vlb = [0.001 0.001 0.01 0 0];
    vub = [100 100 10 1 1];
    
    % Enforce max percent < 1
    A = [0 0 0 1 1]; b = 1;
    
    options = optimset('fmincon');
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
    
    % Fit each data run separately
    for i = 1:nData
        x = fmincon(@(x)FitToColorMaterialFun(x,theDeltaCs,theData(:,i)),x0,A,b,[],[],vlb,vub,[],options);
        [~,thePreds(:,i)] = FitToColorMaterialFun(x,theDeltaCs);
        [~,theSmoothPreds(:,i),indifferenceNeg(i),indifferencePos(i)] = FitToColorMaterialFun(x,theSmoothVals);
        
        % Plot
        figure; clf; hold on
        set(gca,'FontName','Helvetica','FontSize',14);
        plot(theDeltaCs,theData(:,i),'ro','MarkerFaceColor','r','MarkerSize',12);
        plot(theSmoothVals,theSmoothPreds(:,i),'r','LineWidth',2);
        plot([indifferenceNeg(i) indifferenceNeg(i)],[0 0.5],'k');
        plot([indifferencePos(i) indifferencePos(i)],[0 0.5],'k');
        xlabel('Delta color (nominal)','FontName','Helvetica','FontSize',18);
        ylabel('Fraction material lure chosen','FontName','Helvetica','FontSize',18);
        title(sprintf('Delta material = %d',theDeltaMs(i)),'FontName','Helvetica','FontSize',20);
        %  FigureSave(sprintf('DeltaM_%d',i),gcf,'pdf');
    end
    
    % Fit DM = 0 data
    x = fmincon(@(x)FitToColorMaterialFun(x,theDeltaCs,theDataDM0),x0,A,b,[],[],vlb,vub,[],options);
    [~,thePredsDM0] = FitToColorMaterialFun(x,theDeltaCs);
    [~,theSmoothPredsDM0] = FitToColorMaterialFun(x,theSmoothVals);
    
    if (AVERAGE_DM)
        figure; clf; hold on
        set(gca,'FontName','Helvetica','FontSize',14);
        
        plot(theDeltaCs,theDataDM0,'ko','MarkerFaceColor','k','MarkerSize',14);
        plot(0,0.5,'ko','MarkerFaceColor','k','MarkerSize',14);
        plot(theSmoothVals,theSmoothPredsDM0,'k','LineWidth',3);
        
        plot(theDeltaCs,theData(:,3),'o','MarkerSize',14, 'MarkerFaceColor',green, 'MarkerEdgeColor', green);
        plot(theSmoothVals,theSmoothPreds(:,3),'color',green,'LineWidth',3);
        
        plot(theDeltaCs,theData(:,2),'o', 'MarkerSize',14, 'MarkerFaceColor',blue, 'MarkerEdgeColor', blue);
        plot(theSmoothVals,theSmoothPreds(:,2), 'color',blue, 'LineWidth',3);
        
        plot(theDeltaCs,theData(:,1),'o','MarkerSize',14,'MarkerFaceColor',red, 'MarkerEdgeColor', red);
        plot(theSmoothVals,theSmoothPreds(:,1),'color',red,'LineWidth',3);
        
        PLOT_INDLINES = false;
        if (PLOT_INDLINES)
            plot([indifferenceNeg(3) indifferenceNeg(3)],[0 0.5],'r');
            plot([indifferencePos(3) indifferencePos(3)],[0 0.5],'r');
            
            plot([indifferenceNeg(2) indifferenceNeg(2)],[0 0.5],'g');
            plot([indifferencePos(2) indifferencePos(2)],[0 0.5],'g');
            
            plot([indifferenceNeg(1) indifferenceNeg(1)],[0 0.5],'b');
            plot([indifferencePos(1) indifferencePos(1)],[0 0.5],'b');
        end
        
        xlim([-3.1 3.1]);
        set(gca,'XTick',[-3 -2 -1 0 1 2 3]);
        set(gca,'XTickLabel',{'-3' '-2' '-1' '0' '1' '2' '3' },'FontSize',18);
        
        ylim([0 1.02]);
        set(gca,'YTick',[0 0.25 0.5 0.75 1.0]);
        set(gca,'YTickLabel',{'0.00 ' '0.25 ' '0.50 ' '0.75 ' '1.00 '},'FontSize',18);
        
        xlabel('Color Lure Difference \DeltaC','FontName','Helvetica','FontSize',18);
        ylabel('Fraction Material Lure Chosen','FontName','Helvetica','FontSize',18);
        cd FiguresPilot/
        FigureSave([subjectList{s} 'DeltaM_All'],gcf,'pdf');
        
    end
    
    
    %whatLimit = 4;
    colors = {red, blue, green};
    
    % Fit lines to two limbs of indifference plot and make indifference plot
    figure; clf; hold on
    set(gca,'FontName','Helvetica','FontSize',14);
    if 0
        index2 = find(theDeltaMs > 0);
        
        slope3 = indifferenceNeg(index2)'\theDeltaMs(index2)';
        slope4 = indifferencePos(index2)'\theDeltaMs(index2)';
        
        %plot(0,0,'ko','MarkerSize',12,'MarkerFaceColor','w');
        if strcmp(subjectList{s}, 'vtr')
            clear slope3 slope4
            slope3 = [    -1.0966]'\[ 1 ];
            slope4 = [   3.0813    0.5151]'\[ 2 1 ]';
        
            plot(-1.0966, 1, 'o','MarkerSize',14,'MarkerFaceColor', green, 'MarkerEdgeColor',green);
            plot(3.0813,  2,  'o','MarkerSize',14,'MarkerFaceColor',blue, 'MarkerEdgeColor',blue);
            plot(0.5151,  1,  'o','MarkerSize',14,'MarkerFaceColor',green, 'MarkerEdgeColor',green);
        else
            
            plot(indifferenceNeg(1),theDeltaMs(1),'o','MarkerSize',14,'MarkerFaceColor',red, 'MarkerEdgeColor',red);
            plot(indifferencePos(1),theDeltaMs(1),'o','MarkerSize',14,'MarkerFaceColor',red, 'MarkerEdgeColor',red);
            plot(indifferenceNeg(2),theDeltaMs(2),'o','MarkerSize',14,'MarkerFaceColor',blue, 'MarkerEdgeColor',blue);
            plot(indifferencePos(2),theDeltaMs(2),'o','MarkerSize',14,'MarkerFaceColor',blue, 'MarkerEdgeColor',blue);
            plot(indifferenceNeg(3),theDeltaMs(3),'o','MarkerSize',14,'MarkerFaceColor',green, 'MarkerEdgeColor',green);
            plot(indifferencePos(3),theDeltaMs(3),'o','MarkerSize',14,'MarkerFaceColor',green, 'MarkerEdgeColor',green);
        end
        
        plot([0 ; -theDeltaMs(index2)'], -slope3*[0 ; theDeltaMs(index2)'],'k','LineWidth',2);
        plot([0 ; theDeltaMs(index2)'], slope4*[0 ; theDeltaMs(index2)'],'k','LineWidth',2);
        
        
        %plot(0,0,'ko','MarkerSize',12,'MarkerFaceColor','w');
        
        ylim([0 3.2]);
        set(gca,'YTick',[0 1 2 3 4]);
        set(gca,'YTickLabel',{' 0 ' ' 1 ' ' 2 ' ' 3 ' ' 4 '},'FontSize',18);
        xlim([-3.1 3.1]);
        set(gca,'XTick',[-3 -2 -1 0 1 2 3]);
        set(gca,'XTickLabel',{'-3' '-2' '-1' '0' '1' '2' '3' },'FontSize',18);
        %ylabel('Material Lure | \DeltaM_{ind,i} |','FontName','Helvetica','FontSize',20);
        %xlabel('Color Lure \DeltaC_i','FontName','Helvetica','FontSize',20);
    
        theSlopes(s,:) = ([abs(slope3), slope4]); 
        
        thisSlope(s) = mean([abs(slope3), slope4]); 
        thesePointsPos(s,:) = indifferencePos; 
        thesePointsNeg(s,:) = indifferenceNeg;
        
        %plot(0,0,'ko','MarkerSize',12,'MarkerFaceColor','w');
        ylim([0 3.2]);
        set(gca,'YTick',[0 1 2 3 4]);
        set(gca,'YTickLabel',{' 0 ' ' 1 ' ' 2 ' ' 3 ' ' 4 '},'FontSize',18);
        xlim([-3.1 3.1]);
        set(gca,'XTick',[-3 -2 -1 0 1 2 3]);
        set(gca,'XTickLabel',{'-3' '-2' '-1' '0' '1' '2' '3' },'FontSize',18);
        %ylabel('Material Lure | \DeltaM_{ind,i} |','FontName','Helvetica','FontSize',20);
        %xlabel('Color Lure \DeltaC_i','FontName','Helvetica','FontSize',20);
        ylabel('Material Lure Difference | \DeltaM |','FontName','Helvetica','FontSize',18);
        xlabel('Color Lure Difference \DeltaC','FontName','Helvetica','FontSize',18);
    else
        index1 = find(theDeltaMs < 0);
        index2 = find(theDeltaMs > 0);
        slope1 = theDeltaMs(index1)\indifferenceNeg(index1)';
        slope2 = theDeltaMs(index1)\indifferencePos(index1)';
        slope3 = theDeltaMs(index2)\indifferenceNeg(index2)';
        slope4 = theDeltaMs(index2)\indifferencePos(index2)';
        
        plot(theDeltaMs,indifferenceNeg,'ko','MarkerSize',12,'MarkerFaceColor','k');
        plot(theDeltaMs,indifferencePos,'ko','MarkerSize',12,'MarkerFaceColor','k');
        plot(0,0,'ko','MarkerSize',12,'MarkerFaceColor','k');
        plot([theDeltaMs(index1) ; 0],slope1*[theDeltaMs(index1) ; 0],'k','LineWidth',2);
        plot([theDeltaMs(index1) ; 0],slope2*[theDeltaMs(index1) ; 0],'k','LineWidth',2);
        plot([0 ; theDeltaMs(index2)],slope3*[0 ; theDeltaMs(index2)],'k','LineWidth',2);
        plot([0 ; theDeltaMs(index2)],slope4*[0 ; theDeltaMs(index2)],'k','LineWidth',2);
        xlim([-4 4]);
        ylim([-4 4]);
        xlabel('Material Lure \DeltaM_{ind,i}','FontName','Helvetica','FontSize',20);
        ylabel('Color Lure \DeltaC_i','FontName','Helvetica','FontSize',20);
    end
    FigureSave(sprintf([subjectList{s} 'IndifferencePlot']),gcf,'pdf');
end
%%
for i = 1:length(subjectList)
    if strcmp(subjectList{i}, 'scd')
        thisSlope(i) = 0;
    end
end

[~, sortIndex] = sort(thisSlope);
nSubjects= (length(subjectList));
xTick = 0:(length(subjectList));
thisMarkerSize = 18;
labelList{length(subjectList)+2} = '';
for i = 1:length(subjectList)
    labelList{i+1} = subjectList{sortIndex(i)};
end
color = [0 153 153]'./255;
thisMarkerSize = 16;
figure;  clf; hold on;
for s = 1:(length(subjectList))
    plot(s, thisSlope(sortIndex(s)), 'o' , 'MarkerFaceColor', color , 'MarkerEdgeColor', color, 'MarkerSize', thisMarkerSize)
end
axis([0 nSubjects+1 0 2])
xlabel('Subjects','FontName','Helvetica','FontSize',20);
ylabel('Indifference Slopes','FontName','Helvetica','FontSize',20);%set(gca, 'Ytick', [1:nLevels]);
set(gca, 'YTick', [0.0:0.5:2]);
set(gca,'YTickLabel',num2str(get(gca,'YTick')','%.1f'))
set(gca, 'Xtick', xTick,'FontName','Helvetica','FontSize',20);
set(gca, 'XTickLabel', labelList, 'FontName','Helvetica','FontSize',20);
cd ..
FigureSave(['IndifferencePlot'],gcf,'pdf');
