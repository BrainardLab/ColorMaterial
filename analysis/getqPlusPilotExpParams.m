function params = getqPlusPilotExpParams
% these are all hardcoded parametes 

params.targetIndex = 4;
params.competitorsRangePositive = [1 3];
params.competitorsRangeNegative = [-3 -1];
params.targetMaterialCoord = 0;
params.targetColorCoord = 0;
params.sigma = 1;
params.sigmaFactor = 4;

params.targetPosition = 0;
params.targetIndexColor =  11; % target position on the color dimension in the set of all paramters.
params.targetIndexMaterial = 4; % target position on the material dimension in the set of all paramters.

params.materialMatchColorCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.colorMatchMaterialCoords  =  params.competitorsRangeNegative(1):1:params.competitorsRangePositive(end);
params.numberOfMaterialCompetitors = length(params.colorMatchMaterialCoords);
params.numberOfColorCompetitors = length(params.materialMatchColorCoords);
params.numberOfCompetitorsPositive = length(params.competitorsRangePositive(1):params.competitorsRangePositive(end));
params.numberOfCompetitorsNegative = length(params.competitorsRangeNegative(1):params.competitorsRangeNegative(end));
