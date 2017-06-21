% GrantCueCombFigure
%
% Figure for RO1 renewal, with hypothesized data for cue
% combination j, k experiment
%
% 6/29/14  dhb  Wrote it.

%% Clear
clear; close all;

%% Define parameters
psychoStdev = 0.2;
psychoShape = 2;
psychoScale = 1;
kWeight = 1;
jWeight = 1.25;

%% Variables to compute over
ks = [0 0.05 0.1 0.2 0.4 0.6 0.8 -0.8 -0.6 -0.4 -0.2 -0.1 -0.05];
js = linspace(-1,1,1001);
discreteJs = linspace(-1,1,9);

for kindex = 1:length(ks)
    k = abs(ks(kindex));
    thePsychoMin = 0.5-kWeight*k/2;
    thePsychoRange = 1-thePsychoMin;
    thePsychoPoints{kindex} = thePsychoMin+thePsychoRange*wblcdf((jWeight)*abs(discreteJs),psychoScale,psychoShape);
    thePsychoSmooth{kindex} = thePsychoMin+thePsychoRange*wblcdf((jWeight)*abs(js),psychoScale,psychoShape); 
    [~,jindIndex] = min(abs(thePsychoSmooth{kindex}-0.5));
    jinds1(kindex) = abs(js(jindIndex));
    jinds2(kindex) = -jinds1(kindex);
end

figure; clf; hold on
set(gca,'FontName','Helvetica','FontSize',16);
theColors = ['k' 'r' 'g' 'b' 'c' 'r'];
for kindex = [1 4 5 6]
    %plot(discreteJs,thePsychoPoints{kindex},['o' theColors(kindex)],'MarkerFaceColor',theColors(kindex),'MarkerSize',12);
    plot(js,thePsychoSmooth{kindex},theColors(kindex),'LineWidth',2);
end
plot([-1 1],[0.5 0.5],'k:','LineWidth',2); 
xlim([-1.05 1.05]); ylim([-0.05 1.05]);
set(gca,'XTick',[-1.0 -0.5 0.0 0.5 1.0]);
set(gca','XTickLabel',{'-1' '-0.5' '0' '0.5' '1'},'FontSize',20);
set(gca,'YTick',[0.00 0.25 0.50 0.75 1.00]);
set(gca','YTickLabel',{'0.00 ' '0.25 ' '0.50 ' '0.75 ' '1.00 '},'FontSize',20);
legend({' \DeltaC_i = 0.0' ' \DeltaC_i = 0.2' ' \DeltaC_i = 0.4' ' \DeltaC_i = 0.6'},'Location','SouthWest','FontName','Helvetica','FontSize',14);
xlabel('\DeltaM (arbitrary units)','FontSize',22);
ylabel('Fraction color lure chosen','FontSize',22);
FigureSave(sprintf('GrantCueCombPsycho%d',round(100*jWeight)),gcf,{'pdf', 'eps'});

figure; clf; hold on;
set(gca,'FontName','Helvetica','FontSize',16);
[~,index] = sort(ks);
for kindex = 1:length(ks)
    plot(ks,jinds1,['o' 'k'],'MarkerFaceColor','k','MarkerSize',12);
    plot(ks(index),jinds1(index),['k'],'LineWidth',2);
    plot(ks,jinds2,['o' 'k'],'MarkerFaceColor','k','MarkerSize',12);
    plot(ks(index),jinds2(index),['k'],'LineWidth',2);
end
xlim([-1.05 1.05]); ylim([-1.05 1.05]); 
axis('square');
%title('Indifference points','FontSize',22);
set(gca,'XTick',[-1.0 -0.5 0.0 0.5 1.0]);
set(gca','XTickLabel',{'-1' '-0.5' '0' '0.5' '1'},'FontSize',20);
set(gca,'YTick',[-1.0 -0.5 0.0 0.5 1.0]);
set(gca','YTickLabel',{'-1.0 ' '-0.5 ' '0.0 ' '0.5 ' '1.0 '},'FontSize',20);
xlabel('\DeltaC_i','FontSize',22);
ylabel('\DeltaM_{ind,i}','FontSize',22);
FigureSave(sprintf('GrantCueCombIndifference%d',round(100*jWeight)),gcf,{'pdf', 'eps'});
