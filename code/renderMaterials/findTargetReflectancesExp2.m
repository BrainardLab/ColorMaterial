% findTargetReflectancesForConstancy
% find reflectances for the constancy condition of color material

% 03/18/2016 find target reflectances. 
% 07/04/2016 edited for the new stimulus set

% Initialize
clear; close all; 

% set params
writeDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/';
writeSpectralFiles = 1;
moreChecks = 1; 
nConditions = 3;
nTargets = 7;

% load color matching functions
S = [400, 10, 31];
load T_xyzCIEPhys2
T_sensorXYZ = 683*SplineCmf(S_xyzCIEPhys2,T_xyzCIEPhys2,S);
nCompetitors = 7; 

% load rendering illuminants - these are extracted from the test cube
% (matte under the test illuminant). 
tempD67 = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/spdWhite.spd');
tempYellow = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/spdYellow.spd');
tempBlue = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/spdBlue.spd');
wls = tempD67(:,1);
D67 = tempD67(:,2);
Yellow = tempYellow(:,2);
Blue = tempBlue(:,2);
whitePoint = T_sensorXYZ*D67;

% load target ref (under no change).
% this is the identical target as the one we used in the previous
% experiment. 
tmp = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/R1_NeutralDay_BlueGreen_0.60.spd');
targetRef = tmp(:,2); clear tmp;

% calculate what would the test object color values be under the chaged
% illumination.
for i = 1:nConditions
    if i == 1
        targetXYZ = T_sensorXYZ*(targetRef.*D67);
        targetLAB = XYZToLab(targetXYZ, whitePoint);
        targetxyY = XYZToxyY(targetXYZ);
    elseif i == 2
        targetXYZYellow = T_sensorXYZ*(targetRef.*Yellow);
        targetLABYellow = XYZToLab(targetXYZYellow, whitePoint);
        targetxyYYellow = XYZToxyY(targetXYZYellow);
    elseif i == 3
        targetXYZBlue = T_sensorXYZ*(targetRef.*Blue);
        targetLABBlue = XYZToLab(targetXYZBlue, whitePoint);
        targetxyYBlue = XYZToxyY(targetXYZBlue);
    end
end

% find competitors. We will have six competitors between the tristimulus
% match and the reflectance match. plus one overconstancy match. all
% equally spaced. 
for i = 1:size(targetLAB,1) % linspace for each dimension. 
    competitorsBlueLAB(i,:) = linspace(targetLAB(i)', targetLABBlue(i)', 6);
    competitorsYellowLAB(i,:) = linspace(targetLAB(i)', targetLABYellow(i)', 6);
end

% find the last competitor
competitorsBlueLAB(:,7) = competitorsBlueLAB(:,6)+(competitorsBlueLAB(:,6)-competitorsBlueLAB(:,5));
competitorsYellowLAB(:,7) = competitorsYellowLAB(:,6)+(competitorsYellowLAB(:,6)-competitorsYellowLAB(:,5));
competitorsLAB = [competitorsYellowLAB(:,3), competitorsYellowLAB(:,2),competitorsYellowLAB(:,1), competitorsBlueLAB(:,2), competitorsBlueLAB(:,3)];

competitorsBlueXYZ = LabToXYZ(competitorsBlueLAB, whitePoint); 
competitorsYellowXYZ = LabToXYZ(competitorsYellowLAB, whitePoint); 
competitorsXYZ = LabToXYZ(competitorsLAB, whitePoint); 

for c = 1:(size(competitorsBlueLAB,2)-1)
    if c < 5 % only 5 competitors in the no change condition. 
        dist(c) = pdist([competitorsLAB(:,c)'; competitorsLAB(:,c+1)'], 'euclidean');
    end
    distY(c) = pdist([competitorsYellowLAB(:,c)'; competitorsYellowLAB(:,c+1)'], 'euclidean');
    distB(c) = pdist([competitorsBlueLAB(:,c)'; competitorsBlueLAB(:,c+1)'], 'euclidean');
end

competitorReflectance = SensorToSrf('xyzCIEPhys2',competitorsXYZ, D67, S);
competitorReflectanceBlue = SensorToSrf('xyzCIEPhys2',competitorsBlueXYZ, Blue, S);
competitorReflectanceYellow = SensorToSrf('xyzCIEPhys2',competitorsYellowXYZ, Yellow, S);

% find and write target reflectances.
for i = 1:size(competitorsYellowLAB,2)
    if writeSpectralFiles == 1
        cd(writeDir);
        if i < 6
            WriteSpectrumFile(wls, competitorReflectance(:,i), sprintf('NCCompetitorBlobRef%d.spd', i));
        end
        WriteSpectrumFile(wls, competitorReflectanceYellow(:,i), sprintf('CYCompetitorBlobRef%d.spd', i));
        WriteSpectrumFile(wls, competitorReflectanceBlue(:,i), sprintf('CBCompetitorBlobRef%d.spd', i));
        cd('/Users/Shared/Matlab/Experiments/ColorMaterial/code/');
    end
end

% do one more round of checks. 
if moreChecks
    for i = 1:nConditions
        for t = 1:size(competitorReflectanceBlue,2)
            if i == 1
                if t < 6
                 CNewXYZ(:,t) = T_sensorXYZ*(competitorReflectance(:,t).*D67);
                 CNewLab(:,t) = XYZToLab(CNewXYZ(:,t), whitePoint);
                end
            elseif i == 2
                cYellowXYZNew(:,t) = T_sensorXYZ*(competitorReflectanceYellow(:,t).*Yellow);
                cYellowLabNew(:,t) = XYZToLab(cYellowXYZNew(:,t), whitePoint);
            elseif i == 3
                cBlueXYZNew(:,t) = T_sensorXYZ*(competitorReflectanceBlue(:,t).*Blue);
                cBlueLabNew(:,t) = XYZToLab(cBlueXYZNew(:,t), whitePoint);
            end
        end
    end
    for t = 1:(size(competitorReflectanceBlue,2)-1)
        if t < 5
        distNew(t) = pdist([CNewLab(:,t)'; CNewLab(:,t+1)'], 'euclidean');
        end
        distNewY(t) = pdist([cYellowLabNew(:,t)'; cYellowLabNew(:,t+1)'], 'euclidean');
        distNewB(t) = pdist([cBlueLabNew(:,t)'; cBlueLabNew(:,t+1)'], 'euclidean');
    end
end
blobColors.competitorsYellowLAB = competitorsYellowLAB;
blobColors.competitorsBlueLAB = competitorsBlueLAB;
blobColors.competitorsLAB = competitorsLAB;

blobColors.competitorsYellowXYZ = competitorsYellowXYZ;
blobColors.competitorsBlueXYZ = competitorsBlueXYZ;
blobColors.competitorsXYZ = competitorsXYZ;

blobColors.competitorsYellowxyY = XYZToxyY(competitorsYellowXYZ);
blobColors.competitorsBluexyY = XYZToxyY(competitorsBlueXYZ);
blobColors.competitorsxyY = XYZToxyY(competitorsXYZ);

blobColors.targetXYZ  = targetXYZ;
blobColors.targetxyY  = targetxyY;
blobColors.targetLAB  = targetLAB;

blobColors.targetXYZYellow = targetXYZYellow;
blobColors.targetLABYellow = targetLABYellow;
blobColors.targetxyYYellow = targetxyYYellow;

blobColors.targetXYZBlue = targetXYZBlue;
blobColors.targetLABBlue = targetLABBlue;
blobColors.targetxyYBlue = targetxyYBlue;
blobColors.competitorReflectance = competitorReflectance; 
blobColors.competitorReflectanceBlue = competitorReflectanceBlue;
blobColors.competitorReflectanceYellow = competitorReflectanceYellow;

save('blobConstancyExp1', 'blobColors')
fprintf('done3')