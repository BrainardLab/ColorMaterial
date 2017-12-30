% function params = ColorMatExp1TrainingDriver(exp)
function params = ColorMatExp1TrainingDriver(exp)
% Program that executes the experiment based on the parameters that are
% passed.

% 02/11/15   ar Adapting it from the Blocks Experiment
% 04/14/16   ar Switched to responding via the controller.

try
    % Convert all the configfile parameters into simple struct values.
    cfgFile = ConfigFile(exp.configFileName);
    params = convertToStruct(cfgFile);
    
    % Load the calibration file and check the calibration age
    [cal, ~] = setCheckCalibration('EyeTrackerLCD', exp.subject);
    
    % Get the stimulus color matrix for all trials
%     list.stimulusList = {'E1P1-NCC1M4-NCC4M4','E1P1-NCC2M4-NCC5M4','E1P1-NCC1M4-NCC4M4','E1P1-NCC2M4-NCC5M4'};
        list.stimulusList = {'Exp2NCC4M1-Exp2NCC4M7', ...
        'Exp2NCC4M2-Exp2NCC4M6', ...
        'Exp2NCC4M3-Exp2NCC4M5', ...
        'Exp2NCC1M4-Exp2NCC7M4', ...
        'Exp2NCC2M4-Exp2NCC6M4', ...
        'Exp2NCC3M4-Exp2NCC5M4'};

    params.nTrials = length(list.stimulusList);
    
    % Target is fixed across trials and predefined in the config file.
    target = load([params.targetName '-RGB.mat']);
   
    % Create, open and draw window object and keep it on the screen for a
    % defined isi
    win = GLWindow('FullScreen', true, 'BackgroundColor', [0 0 0], 'SceneDimensions', params.screenDimensions);
    win.open;
    win.draw;
    % Wait for one second
    mglWaitSecs(params.isi);
    
    % Trial loop starts.
    % The trials are randomized. By assigning the order index randomize
    % the order in which trials are displayed. The trial index is still
    % ordered, so in the analysis we don't have to do sorting first.
    
    % Determine the order of trials.
    params.trialIndices = (1:params.nTrials);
    
    % Clear out the mgl character queue.
    mglGetKeyEvent;
    
    % This is the trial loop
    for i = 1: length(params.trialIndices);
        orderIndex = params.trialIndices(i);
        % Add stimulus images for this trial
        stimulusOneName{1} = [list.stimulusList{orderIndex}(1:11)];
        sOne = load([stimulusOneName{1} 'RGB.mat']);
        stimulusTwoName{1} = [list.stimulusList{orderIndex}(12:end)];
        sTwo = load([stimulusTwoName{1} '-RGB.mat']);
        positionOne = randi(2);
    
        % Save relevant info
        params.trial(orderIndex).stimulusOneName = stimulusOneName;
        params.trial(orderIndex).stimulusTwoName = stimulusTwoName;
        params.trial(orderIndex).positionOne = positionOne;
        
        win.addImage(params.targetImagePosition, params.imageSize, flip(target.sensorImageRGB,1), 'Name', 'Target', 'Enabled', true);
        if positionOne == 1
            win.addImage(params.firstTestPosition, params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
            win.addImage(params.secondTestPosition,params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'STwo','Enabled', true);
        elseif positionOne == 2
            win.addImage(params.firstTestPosition, params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
            win.addImage(params.secondTestPosition,   params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'STwo','Enabled', true);
        end
        % Start timing once the stimulus is drawn. 
        params.trial(orderIndex).stimulusOnset = win.draw ;
        mglWaitSecs(params.waitTime);
        
        % Flush any key presses from the previous trial.
        key = -1;
        while (~isempty(key))
            key = mglGetKeyEvent(0);
        end
        
        % Initialize elements for the loop.
       keepDrawing = true;
        
        while keepDrawing
            % Look to see if a quit key was pressed.
            key = mglGetKeyEvent(Inf);
            if ~isempty(key)
                switch key.charCode
                    case 'a' % left
                        if (positionOne == 1)
                            params.trial(orderIndex).imageChosen = 1;
                        elseif (positionOne == 2)
                            params.trial(orderIndex).imageChosen = 2;
                        end
                        beep;
                        params.trial(orderIndex).RT = key.when - params.trial(orderIndex).stimulusOnset;
                        win.addOval([params.positionLeft(1) params.positionLeft(2)], [params.checkSize(1), params.checkSize(2)], [0 0 0], 'Name', 'Check','Enabled', true);
                        win.draw
                        pause(params.isi)    
                        keepDrawing = false;
                    case 'd'  % right
                        if (positionOne == 1)
                            params.trial(orderIndex).imageChosen = 2;
                        elseif (positionOne == 2)
                            params.trial(orderIndex).imageChosen = 1;
                        end
                        beep;
                        params.trial(orderIndex).RT = key.when - params.trial(orderIndex).stimulusOnset;
                        win.addOval([params.positionRight(1) params.positionRight(2)], [params.checkSize(1), params.checkSize(2)], [0 0 0], 'Name', 'Check','Enabled', true);
                        win.draw
                        pause(params.isi)    
                        keepDrawing = false;
                case 'q'
                        error('Abort program');
                end
            end
            win.draw;
        end
        
        % disp(params.trial(orderIndex).n);
        win.disableAllObjects;
        win.draw;
        %  Speak('Wait for the next trial');
        mglWaitSecs(params.isi);
    end
    win.close;
    ListenChar(0);
    % Toss the error back to Matlab's default error handler.
catch e
    if exist('win', 'var') && ~isempty(win)
        win.close;
    end
    ListenChar(0);
    rethrow(e);
end
end