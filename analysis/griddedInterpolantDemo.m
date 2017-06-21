% griddedInterpolantDemo
% 
% We wrote this when we were first learning to work with the gridded
% interpolant. Here the goal is to compare linear and gridded interpolation. 

% Initialize
clear; close all;

% Set some values. 
x = 0:10;  
y = 10*x; 
interpOverRange = linspace(0,10,100); 

% Use inter1 and griddedInterpolant. 
funInterp = interp1(x,y, interpOverRange); 
funGridded = griddedInterpolant(x,y); 

% Plot for comparison
figure; clf; hold on; 
plot(x,y, 'ko') % "data"
plot(interpOverRange, funInterp,'k-'); % "interp1"

nDimensions = size(funGridded.GridVectors,1);  
for d = 1:nDimensions
    plot(funGridded.GridVectors{d},funGridded.Values, 'g--'); % "gridded interpolant"
end

