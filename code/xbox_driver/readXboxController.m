function readXboxController
% Say we are using the controller that has been initalised
global XboxControllerID;
global xboxController;
% Read the controller
[axes, buttons, povs] = read(XboxControllerID);
% setup the global structure for rational reading
%set(xboxController,'Abutton',buttons(1),'Bbutton',buttons(2),'Xbutton',buttons(3),'Ybutton',buttons(4),'Axis1',axes(1),'Axis2',axes(4),'DPad',povs);
xboxController.Axis1 = [axes(1), axes(2)*-1];
xboxController.Axis2 = [axes(3), axes(4)*-1];
xboxController.Button1 = buttons(1);
xboxController.Button2 = buttons(2);
xboxController.Button3 = buttons(3);
xboxController.Button4 = buttons(4);
xboxController.Button5 = buttons(5);
xboxController.Button6 = buttons(6);
xboxController.Button7 = buttons(7);
xboxController.Button8 = buttons(8);
xboxController.Button9 = buttons(9);
xboxController.Button10 = buttons(10);
xboxController.DirectionPad = povs;
% e.g if (Abutton)
     %    do this
     %end
end