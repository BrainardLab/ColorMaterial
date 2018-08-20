function [ cal , T_sensorXYZ] = setCheckCalibration(calName, whichSubject)

% Load the calibration file and check the calibration age
S = [400, 10, 31];
load T_xyz1931
T_sensorXYZ = 683*SplineCmf(S_xyz1931,T_xyz1931,S);
cal = LoadCalFile(calName);
cal = SetGammaMethod(cal, 0);
cal = SetSensorColorSpace(cal, T_sensorXYZ,  S);

% check calibration age. 
calAge = GetCalibrationAge(cal);
calWarningDays = 14;
calErrorDays = 30;
if strcmp(whichSubject, 'test')
    calErrorDays = 180;
end

if (calAge < calWarningDays)
    fprintf('Calibration was last done %d days ago \n',calAge);
elseif (calAge < calErrorDays)
    fprintf('WARNING: Calibration is %d days old, recalibrate soon!\n',calAge);
else
    error('Calibration is %d days old, recalibrate now!\n',calAge);
end

end

