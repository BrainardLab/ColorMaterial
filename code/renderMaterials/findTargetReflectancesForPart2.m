% findTargetReflectancesForPart2
% Loads subjects data. Finds reflectances for reflectances for
% color/material experiment (part 2). 

% 07/26/2016 ar Modified it from findTargetReflectancesConstancy. 

% Initialize
clear; close all; 

% set params
writeDir = '/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/';
writeSpectralFiles = 1;
moreChecks = 1; 
nConditions = 3;
subjectList = {'ifj' , 'krz', 'ueh'}

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
desiredDistance = 2.6; % this is the distance we have set to be the desired distance in LAB (1/2 of what it was in Experiment 1)

% These are 'ends of the line' in each condition (blue and green from which the target was created).
theGreen = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/NeutralDay-Green.spd');
theBlue = load('/Users/Shared/Matlab/Experiments/ColorMaterial/code/renderMaterials/NeutralDay-Blue.spd');

% these are their XYZs and LABs under D67 (no change of illuminaton)
theGreenXYZ = T_sensorXYZ*(theGreen(:,2).*D67);
theGreenLAB = XYZToLab(theGreenXYZ, whitePoint);
theBlueXYZ = T_sensorXYZ*(theBlue(:,2).*D67);
theBlueLAB = XYZToLab(theBlueXYZ, whitePoint);

% ..and under changed illumination (blue)
theGreenUnderBlueXYZ = T_sensorXYZ*(theGreen(:,2).*Blue);
theBlueUnderBlueXYZ = T_sensorXYZ*(theBlue(:,2).*Blue);
theGreenUnderBlueLAB = XYZToLab(theGreenUnderBlueXYZ, whitePoint);
theBlueUnderBlueLAB = XYZToLab(theBlueUnderBlueXYZ, whitePoint);
   
% ..and under yellow illumination
theGreenUnderYellowXYZ = T_sensorXYZ*(theGreen(:,2).*Yellow);
theBlueUnderYellowXYZ = T_sensorXYZ*(theBlue(:,2).*Yellow);
theGreenUnderYellowLAB = XYZToLab(theGreenUnderYellowXYZ, whitePoint);
theBlueUnderYellowLAB = XYZToLab(theBlueUnderYellowXYZ, whitePoint);

% 
for s = 1:length(subjectList)
    fprintf('Subject %s\n', subjectList{s});
    
    % load the data for each subject and get their selection based matches for each condition.
    clear tmp   subjectMatchNC	subjectMatchCB	subjectMatchCY	CCIYellow	CCIBlue
    tmp = load(['/Users/Shared/Matlab/Experiments/ColorMaterial/analysis/E1P1/' subjectList{s} 'E1P1.mat']);
    subjectMatchNC = tmp.thisSubject.LabDerivedNC;
    subjectMatchCB = tmp.thisSubject.LabDerivedCB;
    subjectMatchCY = tmp.thisSubject.LabDerivedCY;
    CCIYellow = tmp.thisSubject.CCIYellow;
    CCIBlue  = tmp.thisSubject.CCIBlue;
    
    for whichCondition = 1:nConditions
        if whichCondition == 1
            subject{s}.newNCLab = findSpacedCompetitorsNC(subjectMatchNC, theGreenLAB, theBlueLAB, desiredDistance);
            subject{s}.newNCXYZ = LabToXYZ(subject{s}.newNCLab, whitePoint);
        elseif whichCondition == 2 % yellow
            subject{s}.newCYLab = findSpacedCompetitorsIllumChange(subjectMatchCY, theGreenUnderYellowLAB, theGreenLAB, theBlueUnderYellowLAB, theBlueLAB, desiredDistance, CCIYellow);
            subject{s}.newCYXYZ = LabToXYZ(subject{s}.newCYLab, whitePoint);
        elseif whichCondition == 3 % blue
            subject{s}.newCBLab = findSpacedCompetitorsIllumChange(subjectMatchCB, theGreenUnderBlueLAB, theGreenLAB, theBlueUnderBlueLAB, theBlueLAB, desiredDistance, CCIBlue);
            subject{s}.newCBXYZ = LabToXYZ(subject{s}.newCBLab, whitePoint);
        end
    end
    
    % Find reflectances
    competitorReflectance = SensorToSrf('xyzCIEPhys2',subject{s}.newNCXYZ, D67, S);
    competitorReflectanceYellow = SensorToSrf('xyzCIEPhys2',subject{s}.newCYXYZ, Yellow, S);
    competitorReflectanceBlue = SensorToSrf('xyzCIEPhys2',subject{s}.newCBXYZ, Blue, S);
    
    % Write reflectances
    if writeSpectralFiles
        cd(writeDir);
        for i = 1:size(competitorReflectance,2)
            WriteSpectrumFile(wls, competitorReflectance(:,i), sprintf('%sPart2NCCompetitorBlobRef%d.spd', subjectList{s},i));
            WriteSpectrumFile(wls, competitorReflectanceYellow(:,i), sprintf('%sPart2CYCompetitorBlobRef%d.spd', subjectList{s},i));
            WriteSpectrumFile(wls, competitorReflectanceBlue(:,i), sprintf('%sPart2CBCompetitorBlobRef%d.spd', subjectList{s},i));
        end
    end
    
    % do a few checks
    % e.g., reconstruct the LABs and XYZ from reflectances
    for i = 1:7
        tmpXYZ(:,i) = T_sensorXYZ*(competitorReflectance(:,i).*D67);
        tmpXYZBlue(:,i) = T_sensorXYZ*(competitorReflectanceBlue(:,i).*Blue);
        tmpXYZYellow(:,i) = T_sensorXYZ*(competitorReflectanceYellow(:,i).*Yellow);
    end
    tmpLAB = XYZToLab(tmpXYZ, whitePoint);
    tmpLABBlue = XYZToLab(tmpXYZBlue, whitePoint);
    tmpLABYellow = XYZToLab(tmpXYZYellow, whitePoint);
    maxdiffLAB{s} = [(subject{s}.newCYLab - tmpLABYellow); (subject{s}.newCBLab - tmpLABBlue); (subject{s}.newNCLab - tmpLAB)];
    maxdiffXYZ{s} = [(subject{s}.newCYXYZ - tmpXYZYellow); (subject{s}.newCBXYZ - tmpXYZBlue); (subject{s}.newNCXYZ - tmpXYZ)];
    if (abs( max(maxdiffXYZ{s}(:))) > 0.01) || (abs( max(maxdiffLAB{s}(:))) > 0.01) 
        error;
    end
    
    % we can check the distances
    for c = 1:6
        dist(s,c) = pdist([tmpLAB(:,c)'; tmpLAB(:,c+1)'], 'euclidean');
        distY(s,c) = pdist([tmpLABYellow(:,c)'; tmpLABYellow(:,c+1)'], 'euclidean');
        distB(s,c) = pdist([tmpLABBlue(:,c)'; tmpLABBlue(:,c+1)'], 'euclidean');
        if (abs((dist(s,c)-desiredDistance)) > 0.01) || (abs((distY(s,c)-desiredDistance)) > 0.01) || (abs((distB(s,c)-desiredDistance)) > 0.01)
            error;
        end
    end
    
    % we can check that the middle competitor matches the target
    a{s}(1,:) = tmpLAB(:,4) - subjectMatchNC;
    a{s}(2,:) = tmpLABYellow(:,4) - subjectMatchCY;
    a{s}(3,:) = tmpLABBlue(:,4) - subjectMatchCB;
    
    clear tmpLAB tmpLABBlue tmpLABYellow tmpXYZ tmpXYZBlue tmpXYZYellow
end