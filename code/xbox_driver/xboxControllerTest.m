function xboxControllerTest
% We need to initiliase the variables for our program, this is much faster
% than making it cleaner by putting everything into hidden places.
global xboxController;
% This will test the controller
initialiseXboxController;

% setup the variables for the loop
brick1.x = 0;
brick1.y = 0;
brick2.x = 0;
brick2.y = 0;
figure; hold on;
axis([-1 1 -1 1]);
while ~xboxController.Button1
    pause(0.03)
    readXboxController;
    brick1.x = xboxController.Axis1(1);
    brick1.y = xboxController.Axis1(2);
    brick2.x = xboxController.Axis2(1);
    brick2.y = xboxController.Axis2(2);
    plot(brick1.x,brick1.y,'o','MarkerSize',20,'MarkerFaceColor','b');
    plot(brick2.x,brick2.y,'o','MarkerSize',20,'MarkerFaceColor','r');
end
close all;

end

