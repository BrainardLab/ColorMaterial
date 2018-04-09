function ColorMaterialLocalHook
% ColorMaterialLocalHook
%
% Configure things for working on the ColorMaterialLocalHook project.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by default,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUseProject('ColorMaterial') to set up for
% this project.  You then edit your local copy to match your configuration.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Define project
projectName = 'ColorMaterial';

%% Say hello
fprintf('Running %s local hook\n',projectName);

%% Clear out old preferences
if (ispref(projectName))
    rmpref(projectName);
end

%% Specify project location
projectBaseDir = tbLocateProject(projectName);

% If we ever needed some user/machine specific preferences, this is one way
% we could do that.
sysInfo = GetComputerInfo();
switch (sysInfo.localHostName)
    case 'eagleray'
        % DHB's desktop
        baseDir = fullfile(filesep,'Volumes','Users1','Dropbox (Aguirre-Brainard Lab)');
 
    otherwise
        % Some unspecified machine, try user specific customization
        switch(sysInfo.userShortName)
            % Could put user specific things in, but at the moment generic
            % is good enough.
            otherwise
                baseDir = fullfile('/Users/',sysInfo.userShortName,'Dropbox (Aguirre-Brainard Lab)');
        end
end

%% Set preferences for project output
%
% This will need to be locally configured.
setpref('ColorMaterial','simulatedDataDir',fullfile(projectBaseDir,'SimulatedData'));
setpref('ColorMaterial','mainExpDir',projectBaseDir);
setpref('ColorMaterial','analysisDir',fullfile(baseDir,'CNST_analysis','ColorMaterial'));
setpref('ColorMaterial','stimulusFolder',fullfile(baseDir,'CNST_materials','ColorMaterial','E3'));
setpref('ColorMaterial','dataFolder',fullfile(baseDir,'CNST_data','ColorMaterial'));
setpref('ColorMaterial','demoDataDir',fullfile(baseDir,'CNST_analysis','ColorMaterial','DemoData'));
setpref('ColorMaterial','mainCodeDir',fullfile('/Users/', sysInfo.userShortName, 'Documents/MATLAB/projects/Experiments/ColorMaterial/'));
setpref('ColorMaterial','calFileName','ColorMaterialCalibration');

setpref('BrainardLabToolbox','CalDataFolder',fullfile(baseDir,'CNST_materials','ColorMaterial','CalibrationData'));
