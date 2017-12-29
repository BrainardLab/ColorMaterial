function params = getQuestParamsExp3
% Get experimental parameters for this particular experiment. 
% All parameters are hardcoded (DHB's best guesses)

% 09/12/2017 ar Pulled this from the demo code. 

% Range over which quest+ will look for the best position of the params. 
params.slope1 = [1/6 0.5 1 2 6]; %[0.25 0.5 1 2 4];
params.slope2 = [1/6 0.5 1 2 6];%[0.25 0.5 1 2 4];
params.quad1 = [-1 0 1]; 
params.quad2 = [-1 0 1]; 
params.weights = [0.05:0.15:0.95];

% Details of the experimental design
params.stimUpperEnds = [1 2 3];
params.nTrialsPerQuest = 30;
params.questOrderIn = [0 0 1 2 3 3 3 3];