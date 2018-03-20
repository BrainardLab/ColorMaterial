function params = getqPlusPilotModelingParams(params)
% Take the experimental paramter structure and add on modeling paramters. 
% Some of these we can overwrite in the code. 


% Initial position spacing values to try.
trySpacingValues = [0.5 1 2 3 4];
params.tryMaterialSpacingValues = trySpacingValues; 
params.tryColorSpacingValues = trySpacingValues; 
params.maxPositionValue = 20; 
params.tryWeightValues = [0.5 0.2 0.8];
params.whichMethod = 'lookup'; % could be also 'simulate' or 'analytic'
params.nSimulate = 1000; % for method 'simulate'
load (['colorMaterialInterpolateFun', params.interpCode, params.whichDistance])
params.F = colorMaterialInterpolatorFunction; % for lookup.

