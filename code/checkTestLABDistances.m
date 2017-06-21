
S = [400, 10, 31];
load T_xyzCIEPhys2
T_sensorXYZ = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);


tempL = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/CM6700.spd');
splineLight = SplineSpd(WlsToS(tempL(:,1)), tempL(:,2), S)*1000; 

whitePoint = T_sensorXYZ*splineLight; 
for i = 1:7
    temp = load(['Exp2NCCompetitorBlobRef' num2str(i) '.spd']);
    ref(:,i) = temp(:,2);clear temp
    spectra(:,i) = ref(:,i).*splineLight;
    XYZ(:,i) = T_sensorXYZ*spectra(:,i);
    Lab(:,i) = XYZToLab(XYZ(:,i),whitePoint); 
end
for t = 1:6
    distNewY(t) = pdist([Lab(:,t)'; Lab(:,t+1)'], 'euclidean');
end