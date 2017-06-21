function initialiseXboxController
% This initialises the xbox controller as a global object, and then sets up
% the basic mapping.
global XboxControllerID;
global xboxController;
XboxControllerID = vrjoystick(1);
xboxController = struct('Button1', 0,'Button2', 0,'Button3', 0,'Button4', 0,'Button5', 0,'Button6', 0,'Button7', 0,'Button8',0,'Button9',0,'Button10', 0,'Axis1',[0 0],'Axis2',[0 0],'DPad',0,'DirectionPad',0);
% Buttons
% A Button          1   
% B Button          2
% X Button          3
% Y Button          4
% Left Axis         1
% Right Axis        4
% Dpad              pov
end

