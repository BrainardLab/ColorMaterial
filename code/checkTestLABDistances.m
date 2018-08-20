% checkTestLABDistances
% Computes LAB distance for stimuli in Experiment 2/3 (ColorMaterialPaper).

% June 2018 ar Wrote it. 

S = [400, 10, 31];
load T_xyzCIEPhys2
T_sensorXYZ = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);


tempL = load([getpref('ColorMaterial', 'mainCodeDir'), '/renderMaterials/CM6700.spd']);
splineLight = SplineSpd(WlsToS(tempL(:,1)), tempL(:,2), S)*1000; 

whitePoint = T_sensorXYZ*splineLight; 
for i = 1:7
    temp = load([getpref('ColorMaterial', 'mainCodeDir'), '/renderMaterials/Exp2NCCompetitorBlobRef' num2str(i) '.spd']);
    ref(:,i) = temp(:,2);clear temp
    spectra(:,i) = ref(:,i).*splineLight;
    XYZ(:,i) = T_sensorXYZ*spectra(:,i);
    xyy(:,i) = XYZToxyY(XYZ(:,i)); 
    Lab(:,i) = XYZToLab(XYZ(:,i),whitePoint); 
end
for t = 1:6
    distNewY(t) = pdist([Lab(:,t)'; Lab(:,t+1)'], 'euclidean');
end