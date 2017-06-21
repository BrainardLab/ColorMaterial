% function params = ColorMatPilotDriver(exp)
function params = ColorMatPilotDriver(exp)
% Program that executes the experiment based on the parameters that are
% passed.

% 02/11/15   ar Adapting it from the Blocks Experiment
% print out relevant info for debugging. 

DEMO = 0;
try
    % Convert all the configfile parameters into simple struct values.
    cfgFile = ConfigFile(exp.configFileName);
    params = convertToStruct(cfgFile);
    
    % Load the calibration file and check the calibration age
    [cal, T_sensorXYZ] = setCheckCalibration('EyeTrackerLCD', exp.subject);
    
    % Get the stimulus color matrix for all trials
    list = load('PilotImageList.mat');
    competitorPairs = nchoosek(1:length(list.imageNames),2);
    params.nTrials = length(competitorPairs);
    % Target is fixed across trials and predefined in the config file. 
    target = load([params.targetName '-RGB.mat']);
    % RADIOMETER CODE: Toggle radiometer mode if the subject we're testing is called 'radiometer'.
    if strcmpi(exp.subject, 'radiometer')
        params.radiometerMode = true;
        params.useEyeTracker = 0;
        params.whichMeterType = 5;
        CMCheckInit(params.whichMeterType);
        params.radS = [380 2 201];
    else
        params.radiometerMode = false;
    end
    
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
    
    if (params.radiometerMode == false)
        % Create a Mouse object to help us get mouse position and button
        % state.
        params.mouse = Mouse(win.DisplayInfo);
        
        % Set the mouse to the center of the screen (in pixel coordinates).
        
        % determine the order of trials.
        params.trialIndices = Shuffle(1:params.nTrials);
        
        % Clear out the mgl character queue.
        mglGetKeyEvent;
        
        % This is the trial loop
        for i = 1: length(params.trialIndices);
            
            % set the mouse position on each trial. 
            xMouse = round(win.DisplayInfo(win.WindowID).screenSizePixel(1) / 2);
            yMouse = round(win.DisplayInfo(win.WindowID).screenSizePixel(2) / 2);
        
            orderIndex = params.trialIndices(i);
            
            % If the mouse cursor is visible hide it.
            if mglIsCursorVisible
                mglDisplayCursor(0);
            end
            
            % Add stimulus images for this trial
            stimulusOneName = list.imageNames{competitorPairs(orderIndex,1)};
            sOne = load([stimulusOneName '-RGB.mat']);
            stimulusTwoName = list.imageNames{competitorPairs(orderIndex,2)};
            sTwo = load([stimulusTwoName '-RGB.mat']);
            positionOne = randi(2);
            mouseLeft = round(rand(1));
            
            % save relevant info
            params.trial(orderIndex).stimulusOneName = stimulusOneName; 
            params.trial(orderIndex).stimulusTwoName = stimulusTwoName; 
            params.trial(orderIndex).positionOne = positionOne; 
            params.trial(orderIndex).mouseLeft = mouseLeft; 
            win.addImage(params.targetImagePosition, params.imageSize, flip(target.sensorImageRGB,1), 'Name', 'Target', 'Enabled', true);
            if positionOne == 1
                win.addImage(params.firstTestPosition, params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
                win.addImage(params.secondTestPosition,   params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'STwo','Enabled', true);
            elseif positionOne == 2
                win.addImage(params.firstTestPosition, params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
                win.addImage(params.secondTestPosition,   params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'STwo','Enabled', true);
            end
            
            % Force the mouse to (0,0). Add our mouse cursor.
            win.addOval([0 0], [0.25 0.25], [0 0 0], 'Name', 'cursor', 'Enabled', true);
            win.draw;
            %  win.dumpSceneToTiff(['Scene' num2str(orderIndex)]);
            
            % Move the cursor to either left or right.
            if mouseLeft
                yMouse = yMouse + 180;
                xMouse = xMouse + 0;
            else
                yMouse = yMouse + 180;
                xMouse = xMouse - 0;
            end
            mglSetMousePosition(xMouse,yMouse, win.WindowID);
            
            % Start timing the trial once the cursor appeared.
            params.trial(orderIndex).trialStart=tic;
            
            % Record the mouse position on each loop.
            params.trial(orderIndex).mouseTracing = NaN(40000,2);
            params.trial(orderIndex).mouseLoopDuration = [];
            params.trial(orderIndex).n = 0;
            
            % initialize elements for the loop.
            isImageChosen = false;
            keepLooping = true;
            mousePress = false;
            while keepLooping
                % Look to see if a quit key was pressed.
                key = mglGetKeyEvent;
                if ~isempty(key)
                    if key.charCode == 'q'
                        error('Abort program');
                    end
                end
                
                % Get the current mouse info, i.e. position and button clicks for this loop.
                mouseInfo = params.mouse.MouseStatePx;
                % params.trial(orderIndex).mouseLoopStart = tic;
                
                % Convert the pixel position of the mouse into screen centimeters.
                params.trial(orderIndex).mousePos = params.mouse.px2cm(win.WindowID, params.screenDimensions);
                % record the mouse position and update the cursor positino
                if ~isempty(params.trial(orderIndex).mousePos)
                    params.trial(orderIndex).n = params.trial(orderIndex).n + 1; % keep the number of loops for the mouse.
                    params.trial(orderIndex).mouseTracing(params.trial(orderIndex).n,:) = [params.trial(orderIndex).mousePos.x, params.trial(orderIndex).mousePos.y];
                    %disp([params.trial(orderIndex).mousePos.x, params.trial(orderIndex).mousePos.y]);
                    win.setObjectProperty('cursor', 'Center', [params.trial(orderIndex).mousePos.x params.trial(orderIndex).mousePos.y]);
                end
                
                % Look for a button press.
                if ~mousePress && any(mouseInfo.buttonState) && ~isImageChosen
                    % fprintf('Button clicked!\n X: %g, Y: %g\n', params.trial(orderIndex).mousePos.x, params.trial(orderIndex).mousePos.y);
                    mousePress = true;
                    for j = 1:params.nOptions
                        try
                            if (params.trial(orderIndex).mousePos.x > params.sourceSquareX1(j)) &&  (params.trial(orderIndex).mousePos.x < params.sourceSquareX2(j)) && ...
                                    (params.trial(orderIndex).mousePos.y < params.sourceSquareY1(j)) &&  (params.trial(orderIndex).mousePos.y > params.sourceSquareY2(j))
                                isImageChosen = true;
                                % decode which image is chosen
                                if (positionOne==1) && j == 1
                                     imageChosen = 1;
                                elseif (positionOne==1) && j == 2
                                    imageChosen = 2;
                                elseif (positionOne==2) && j == 1
                                    imageChosen = 2;
                                elseif (positionOne==2) && j == 2
                                    imageChosen = 1; 
                                end
                                %   disp(orderIndex)
                                beep;
                                if DEMO
                                    disp(imageChosen)
                                end
                                mouseClicked = toc(params.trial(orderIndex).trialStart);
                                keepLooping = false;
                            end
                        catch
                            save CRASHDUMP
                            rethrow(lasterr);
                        end
                    end
                elseif mouseInfo.buttonState == 0
                    mousePress = false;
                end
                win.draw;
            end
            
            % record the data
            params.trial(orderIndex).imageChosen = imageChosen;
            params.trial(orderIndex).mouseClicked = mouseClicked;
            % disp(params.trial(orderIndex).n);
            win.disableAllObjects;
            win.draw;
          %  Speak('Wait for the next trial');
            mglWaitSecs(params.isi);
        end
        win.close;
    end
    if (params.radiometerMode)
% THIS NEEDS TO BE REDONE FOR THIS EXPERIMENT        
%         % include the background color among the colors that you want to
%         % measure.
%         load('/Users/Shared/Matlab/Experiments/BlocksTask/code/creatingStimuli/SourceStimulusList.mat')
%         params.nTrials = size(newList,2);
%         %% For the target in the center.
%         params.trialRandom = Shuffle(1:params.nTrials); % note: +1 is for the background color;
%         for j = 1: params.nTrials
%             trialRandomIndex = params.trialRandom(j);
%             % we are only measuring competitors. Competitor is at the
%             % position 2 in the colorInfo matrix (in each trial) so we
%             % use index 2 here.
%             imageName = newList{trialRandomIndex};
%             load([imageName '-RGB.mat'])
%             win.addImage([0, 0], ...            % Center position.
%                 [28 21], ...                                                          % Square width and height.
%                 flipdim(sensorImageRGB,1), ...
%                 'Enabled', true);
%             win.draw
%             if j == 1
%                 FlushEvents;
%                 ListenChar(2);
%                 fprintf('Aim the radiometer at the center of the target you want to measure\n');
%                 fprintf('Hit key when ready. \n');
%                 GetChar;
%                 fprintf('Pausing 5 seconds. \n');
%                 mglWaitSecs(5);
%             end
%             fprintf(' - Measuring trial %d. Take %d', trialRandomIndex);
%             params.trial(trialRandomIndex).colorMeas = MeasSpd(params.radS,params.whichMeterType);
%             fprintf(' Done. \n');
%             win.disableAllObjects;
%         end
%         CMClose(params.whichMeterType);
%         setpref('Internet', 'SMTP_Server', 'smtp-relay.upenn.edu');
%         setpref('Internet', 'E_Mail', 'radonjic@sas.upenn.edu');
%         sendmail('radonjic@sas.upenn.edu', 'Target Measures Complete', 'Done.');
    end
    ListenChar(0);
    win.close;
    % Toss the error back to Matlab's default error handler.
catch e
    if exist('win', 'var') && ~isempty(win)
        win.close;
    end
    ListenChar(0);
    rethrow(e);
end
end


