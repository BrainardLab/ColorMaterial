a = 100*[  -0.199000000000000
  -0.148603903938609
  -0.003345586295623
  -0.000000000000000
   0.002500000000000
   0.024976984413210
   0.199000000000000
  -0.048323426519989
  -0.005000000149012
  -0.002500000000000
                   0
   0.002500000000000
   0.021904662097496
   0.150115415876348
   0.005000000000000
   0.010000000000000];


 %  ll = 4.583919567731283
 b = ...
 100.*[-0.199000000000000
  -0.148603903938609
  -0.003345586295623
  -0.000000000000000
   0.002500000000000
   0.024976984413210
   0.199000000000000
  -0.048323426519989
  -0.005000000149012
  -0.002500000000000
                   0
   0.002500000000000
   0.021904662097496
   0.150115415876348
   0.005000000000000
   0.010000000000000];
%ll2 =    4.583919567731281

FitColorMaterialModelMLDSFun(b,...
    pairColorMatchColorCoords,pairMaterialMatchColorCoords,...
    pairColorMatchMaterialCoords,pairMaterialMatchMaterialCoords,...
    subject{1}.firstChosenAcrossTrials,nTrials,params)