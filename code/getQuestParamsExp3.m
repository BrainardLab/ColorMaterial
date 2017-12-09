function params = getQuestParamsExp3
% Get experimental parameters for this version of the experiment. 

% Range over which quest+ will look for the best position of the params. 
params.slope1 = [0.25 0.5 1 2 4];
params.slope2 = [0.25 0.5 1 2 4];
params.weights = [0.05:0.15:0.95];

% Details of the experimental design
params.stimUpperEnds = [1 2 3];
params.nTrialsPerQuest = 30;
params.questOrderIn = [0 0 1 2 3 3 3 3];