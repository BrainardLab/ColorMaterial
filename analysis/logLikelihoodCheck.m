clear; 
% Specify basic experiment parameters
whichExperiment = 'E3';
mainDir = '/Users/colorlab/Dropbox (Aguirre-Brainard Lab)/';
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

% compute log likelihood for the full set. 
[logLikely1, predictedProbabilities1] = ColorMaterialModelComputeLogLikelihood(sub.rawTrialData(:,1), sub.rawTrialData(:,3),...
    sub.rawTrialData(:,2), sub.rawTrialData(:,4),...
     theResponsesRaw, nTrialsRaw, params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
 
% compute log likelihood for the concatenated set. 
[logLikely2, predictedProbabilities] = ColorMaterialModelComputeLogLikelihood(sub.pairColorMatchColorCoords, sub.pairMaterialMatchColorCoords,...
    sub.pairColorMatchMaterialCoords, sub.pairMaterialMatchMaterialCoords,...
     theResponsesCnt, nTrialsCnt,params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
%  [logLikely2, predictedProbabilities] = ColorMaterialModelComputeLogLikelihood(concatData(:,1), concatData(:,3),...
%     concatData(:,2), concatData(:,4),...
%      concatData(:,5), concatData(:,6),params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 

 
%  nTrials = 1;
%  % do better check
%  a = repmat([-2 3 1 2],nTrials,1);
%  b = repmat([-2 1 0 -3],nTrials,1);
%  a = [a, round(rand(size(a))) ones(size(a))];
%  b = [b, round(rand(size(b))) ones(size(b))];
%  
%  k = []
%  fullM = [a; b];
%  summM(1,:) = [a(:,1:4), sum(a(:,5)==1), size(a,1)];
%  summM(2,:) = [b(:,1:4), sum(b(:,5)==1), size(b,1)];
% 
% 
% % compute log likelihood for the full set. 
% [logLikely11, ~] = ColorMaterialModelComputeLogLikelihood(fullM(:,1), fullM(:,3),...
%     fullM(:,2), fullM(:,4),...
%      (fullM(:,5)==1), fullM(:,end), ...
%      params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
%  
% % compute log likelihood for the concatenated set. 
% [logLikely12, ~] = ColorMaterialModelComputeLogLikelihood(summM(:,1), summM(:,3),...
%     summM(:,2), summM(:,4),...
%      summM(:,5), summM(:,6), ...
%      params.targetColorCoord,params.targetMaterialCoord,params.tryWeightValues(1), params.sigma, 'Fobj', params.F, 'whichMethod', params.whichMethod); 
%  
% 
% 
