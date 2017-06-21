% MakeE1P1StimulusList

clear; close all; 
mCode  =  4; 
cCode = 3; 
nPerCond = [5, 7, 7]; 
conditionCode = {'NC', 'CY', 'CB'}; 
nConditions = length(conditionCode); 


% hardcode permutations

nPairs{1} = [ 1     2
     1     3
     1     4
     1     5
     2     3
     2     4
     2     5
     3     4
     3     5
     4     5];
 
nPairs{2} =     [     1     2
     1     3
     1     4
     1     5
     1     6
     1     7
     2     3
     2     4
     2     5
     2     6
     2     7
     3     4
     3     5
     3     6
     3     7
     4     5
     4     6
     4     7
     5     6
     5     7
     6     7]; 
 
 nPairs{3} = nPairs{2};
 
 competitorPairs.nPairsNC = nPairs{1};
 competitorPairs.nPairsCY = nPairs{2};
 competitorPairs.nPairsCB = competitorPairs.nPairsCY;
 
 
 imageList = [];
 imageListMat = []; 
 for c = 1:nConditions
     for p = 1:size(nPairs{c},1)
         imageList = [imageList, {['E1P1-' conditionCode{c} 'C' num2str(nPairs{c}(p,1)) 'M' num2str(mCode) '-' conditionCode{c} 'C' num2str(nPairs{c}(p,2)) 'M' num2str(mCode)]}];
     end
     
 end
 
 stimulusList = [imageList];
 save('E1P1stimulusList', 'stimulusList')
 save('blobCompetitors', 'competitorPairs');