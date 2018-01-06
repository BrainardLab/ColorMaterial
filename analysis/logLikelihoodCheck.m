clear; 
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/ana/Dropbox (Aguirre-Brainard Lab)/';
dataDir = [mainDir 'CNST_data/ColorMaterial/E3'];
analysisDir = [mainDir 'CNST_analysis/ColorMaterial/E3']; 

params = getqPlusPilotExpParams;

% Set up initial modeling paramters (add on)
params = getqPlusPilotModelingParams(params);


cd(analysisDir)
load('dhbSummarizedqPlusData.mat')
sub = thisSubject.condition{1}; 
theResponsesRaw = sub.rawTrialData(:,end)==1; 
nTrialsRaw = ones(size(theResponsesRaw)); 

theResponsesCnt = sub.firstChosen; 
nTrialsCnt = sub.newNTrials; 

% uniqueStimuli = unique(sub.rawTrialData(:,1:4),'rows');
% nStimuli = size(sub.rawTrialData,1);
% nUniqueStimuli = size(uniqueStimuli,1);
% concatData = zeros(nUniqueStimuli,6);
% for rr = 1:nUniqueStimuli
%     concatData(rr,1:4) = uniqueStimuli(rr,:);
%     for jj = 1:nStimuli
%         if (all(sub.rawTrialData(jj,1:4) == uniqueStimuli(rr,:)))
%             if (sub.rawTrialData(jj,5) == 1)
%                 concatData(rr,5) = concatData(rr,5) + 1;
%             end
%             concatData(rr,6) = concatData(rr,6) + 1;
%         end
%     end
% end
% 
% % compute log likelihood for the full set. 
% [logLikely1, predictedProbabilities1] = ColorMaterialModelComputeLogLikelihood(sub.rawTrialData(:,1), sub.rawTrialData(:,3),...
%     sub.rawTrialData(:,2), sub.rawTrialData(:,4),...
%      theResponsesRaw, nTrialsRaw, params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
%  
% [logLikely2, predictedProbabilities1] = ColorMaterialModelComputeLogLikelihood(...
%     sub.rawTrialData(:,2), sub.rawTrialData(:,4),...
%         sub.rawTrialData(:,1), sub.rawTrialData(:,3),...
%      [ones(size(theResponsesRaw))-theResponsesRaw], nTrialsRaw, params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
%  
% 
%  % compute log likelihood for the concatenated set. 
% [logLikely2, predictedProbabilities] = ColorMaterialModelComputeLogLikelihood(sub.pairColorMatchColorCoords, sub.pairMaterialMatchColorCoords,...
%     sub.pairColorMatchMaterialCoords, sub.pairMaterialMatchMaterialCoords,...
%      theResponsesCnt, nTrialsCnt,params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
% %  [logLikely2, predictedProbabilities] = ColorMaterialModelComputeLogLikelihood(concatData(:,1), concatData(:,3),...
% %     concatData(:,2), concatData(:,4),...
% %      concatData(:,5), concatData(:,6),params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
%
%
nTrials = 1;
% do better check
load('/Users/ana/Documents/MATLAB/projects/Experiments/ColorMaterial/analysis/tempPairs.mat')

a.theLookupTable = load('colorMaterialInterpolateFunLinearcityblock.mat');
params.F1 = a.theLookupTable.colorMaterialInterpolatorFunction; 

b.theLookupTable = load('colorMaterialInterpolateFunCubiccityblock.mat');
params.F2 = b.theLookupTable.colorMaterialInterpolatorFunction; 

% compute log likelihood for the full set.
[logLikely11, probs] = ColorMaterialModelComputeLogLikelihood(kk(:,1), kk(:,3),...
    kk(:,2), kk(:,4),...
    kk(:,5), kk(:,6), ...
    params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F1, 'whichMethod', params.whichMethod);
%
[logLikely11, probs2] = ColorMaterialModelComputeLogLikelihood(kk(:,1), kk(:,3),...
    kk(:,2), kk(:,4),...
    kk(:,5), kk(:,6), ...
    params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F2, 'whichMethod', params.whichMethod);

figure; plot(probs, probs2, 'o')
axis([0 1 0 1])