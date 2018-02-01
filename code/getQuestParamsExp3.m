function params = getQuestParamsExp3
% Get experimental parameters for this particular experiment. 
% All parameters are hardcoded (DHB's best guesses)

% 09/12/2017 ar Pulled this from the demo code. 

% Range over which quest+ will look for the best position of the params. 

lowerLin = 1;
upperLin = 6;
nLin = 4;

lowerQuad = -0.3;
upperQuad = -lowerQuad;
nQuad = 3;

lowerCubic = -0.3;
upperCubic = -lowerCubic;
nCubic = 3;

lowerWeight = 0.05;
upperWeight = 0.95;
nWeight = 5;

params.weights = linspace(lowerWeight,upperWeight,nWeight);
params.Lin = linspace(lowerLin,upperLin,nLin);
params.Quad = linspace(lowerQuad,upperQuad,nQuad);
params.Cubic = linspace(lowerCubic,upperCubic,nCubic);

% Details of the experimental design
params.stimUpperEnds = [1 2 3];
params.nTrialsPerQuest = 30;
params.questOrderIn = [0 1 2 3 3 3 3 3 3];

% initialize or not
params.DO_INITIALIZE = false; 
params.initDir = fullfile([getpref('ColorMaterial', 'dataFolder'), '/E3']);
