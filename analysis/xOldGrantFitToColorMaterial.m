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

analysisDir = pwd;
figDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/FiguresExp1';

theDeltaCs = [-3 -2 -1 0 1 2 3]';
theDeltaMs = [-3 -2 -1 1 2 3]';
AVERAGE_DM = true;
subjectList = {'zhr', 'vtr', 'scd', 'mcv', 'flj'};

for s = 1:length(subjectList)
    clear thisSubject theData
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
    theScaleNeg0 = 1;
    theScalePos0 = 1;
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
        
        plot(theDeltaCs,theDataDM0,'kv','MarkerFaceColor','k','MarkerSize',14);
        plot(0,0.5,'wv','MarkerFaceColor','w','MarkerSize',20);
        plot(theSmoothVals,theSmoothPredsDM0,'k','LineWidth',3);
        
        plot(theDeltaCs,theData(:,3),'g^','MarkerFaceColor','g','MarkerSize',14);
        plot(theSmoothVals,theSmoothPreds(:,3),'g','LineWidth',3);
        
        plot(theDeltaCs,theData(:,2),'bs','MarkerFaceColor','b','MarkerSize',14);
        plot(theSmoothVals,theSmoothPreds(:,2),'b','LineWidth',3);
        
        plot(theDeltaCs,theData(:,1),'ro','MarkerFaceColor','r','MarkerSize',14);
        plot(theSmoothVals,theSmoothPreds(:,1),'r','LineWidth',3);
        
        PLOT_INDLINES = false;
        if (PLOT_INDLINES)
            plot([indifferenceNeg(3) indifferenceNeg(3)],[0 0.5],'g');
            plot([indifferencePos(3) indifferencePos(3)],[0 0.5],'g');
            
            plot([indifferenceNeg(2) indifferenceNeg(2)],[0 0.5],'b');
            plot([indifferencePos(2) indifferencePos(2)],[0 0.5],'b');
            
            plot([indifferenceNeg(1) indifferenceNeg(1)],[0 0.5],'r');
            plot([indifferencePos(1) indifferencePos(1)],[0 0.5],'r');
        end
        
        xlim([-3.1 3.1]);
        set(gca,'XTick',[-3 -2 -1 0 1 2 3]);
        set(gca,'XTickLabel',{'-3' '-2' '-1' '0' '1' '2' '3' },'FontSize',18);
        
        ylim([0 1.02]);
        set(gca,'YTick',[0 0.25 0.5 0.75 1.0]);
        set(gca,'YTickLabel',{'0.00 ' '0.25 ' '0.50 ' '0.75 ' '1.00 '},'FontSize',18);
        
        xlabel('Color Lure \DeltaC','FontName','Helvetica','FontSize',20);
        ylabel('Fraction Material Lure Chosen','FontName','Helvetica','FontSize',20);
        
        FigureSave([subjectList{s} 'DeltaM_All'],gcf,'pdf');
        
    end
    
    % Fit lines to two limbs of indifference plot and make indifference plot
    figure; clf; hold on
    set(gca,'FontName','Helvetica','FontSize',14);
    if (AVERAGE_DM)
        index2 = find(theDeltaMs > 0);
        slope3 = theDeltaMs(index2)'\indifferenceNeg(index2)';
        slope4 = theDeltaMs(index2)'\indifferencePos(index2)';
        
        plot(indifferenceNeg,theDeltaMs,'ko','MarkerSize',14,'MarkerFaceColor','k');
        plot(indifferencePos,theDeltaMs,'ko','MarkerSize',14,'MarkerFaceColor','k');
        %plot(0,0,'ko','MarkerSize',12,'MarkerFaceColor','w');
        plot(slope3*[0 ; theDeltaMs(index2)'],[0 ; theDeltaMs(index2)'],'k','LineWidth',2);
        plot(slope4*[0 ; theDeltaMs(index2)'],[0 ; theDeltaMs(index2)'],'k','LineWidth',2);
        ylim([0 3.2]);
        set(gca,'YTick',[0 1 2 3 4]);
        set(gca,'YTickLabel',{' 0 ' ' 1 ' ' 2 ' ' 3 ' ' 4 '},'FontSize',18);
        xlim([-3.1 3.1]);
        set(gca,'XTick',[-3 -2 -1 0 1 2 3]);
        set(gca,'XTickLabel',{'-3' '-2' '-1' '0' '1' '2' '3' },'FontSize',18);
        %ylabel('Material Lure | \DeltaM_{ind,i} |','FontName','Helvetica','FontSize',20);
        %xlabel('Color Lure \DeltaC_i','FontName','Helvetica','FontSize',20);
        ylabel('Material Lure | \DeltaM |','FontName','Helvetica','FontSize',20);
        xlabel('Color Lure \DeltaC','FontName','Helvetica','FontSize',20);
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
