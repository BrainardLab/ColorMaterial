function params = getQuestParamsExp3
% Get experimental parameters for this particular experiment. 
% All parameters are hardcoded (DHB's best guesses)

% 09/12/2017 ar Pulled this from the demo code. 

% Range over which quest+ will look for the best position of the params. 
params.upperLin = 6;
params.upperQuad = 0.5;
params.upperCubic = 0.5;
params.weights = linspace(0.05,0.95,5);

% Details of the experimental design
params.stimUpperEnds = [1 2 3];
params.nTrialsPerQuest = 30;
params.questOrderIn = [0 1 2 3 3 3 3 3 3];

% initialize or not
params.DO_INITIALIZE = false; 
params.initDir = fullfile([getpref('ColorMaterial', 'dataFolder'), '/E3']);
