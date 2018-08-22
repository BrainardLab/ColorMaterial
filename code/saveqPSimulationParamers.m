
clear; close all; 

%% Define parameters that set up parameter grid for QUEST+
lowerLin = 0.5; % was 1 in previous iteration. 
upperLin = 6;
lowerQuad = -0.3;
upperQuad = -lowerQuad;
lowerCubic = -0.3;
upperCubic = -lowerCubic;
lowerWeight = 0.05;
upperWeight = 0.95;
nLin = 5;
nQuad = 4;
nCubic = 4;
nWeight = 5;
whichInterp = 'Cubic'; 
stimUpperEnds = [1 2 3];
   
% Set up parameter constraints.  
maxStimValue = 3;
maxPosition = 20;
minSpacing = 0.25;

% Experimental params
nSessions = 8;
nTrialsPerQuest = 30;
questOrderIn = [0 1 2 3 3 3 3 3 3];
save('qPSimulationParams')
