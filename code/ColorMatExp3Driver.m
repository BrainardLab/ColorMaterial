function params = ColorMatExp3Driver(exp)
% Program that executes the experiment based on the parameters that are
% passed.

% 12/08/17   ar Adapted it from the ColorMatExp2Driver.
% 04/10/18   ar Read through and corrections before the experiment start
try
    % Convert all the configfile parameters into simple struct values.
    cfgFile = ConfigFile(exp.configFileName);
    params = convertToStruct(cfgFile);  
    
    % Load the calibration file and check the calibration age
    [cal, ~] = setCheckCalibration('ColorMaterialCalibration', exp.subject);
    
    % Get the stimulus color matrix for all trials
    load('Exp3ImageList.mat');
    
    % Target is fixed across trials and predefined in the config file.
    target = load([params.targetName '-RGB.mat']);
    
    % Load the lookup table.
    theLookupTable = load(['/Users/colorlab/Documents/MATLAB/toolboxes/BrainardLabToolbox/ColorMaterialModel/colorMaterialInterpolateFun' params.interpCode params.distance]);
    
    % Define psychometric function in terms of lookup table
    qpPFFun = @(stimParams,psiParams) qpPFColorMaterialCubicModel(stimParams,psiParams,theLookupTable.colorMaterialInterpolatorFunction);
    
    % Create, open and draw window object and keep it on the screen for a
    % defined isi
    win = GLWindow('FullScreen', true, 'BackgroundColor', [0 0 0], 'SceneDimensions', params.screenDimensions);
    win.open;
    win.draw;
    
    % Wait for some time before starting the experiment second
    if strcmp(exp.subject, 'test')
        mglWaitSecs(params.isi);
    else
        mglWaitSecs(params.isiExpStart);
    end
    
    % Initialize three QUEST+ structures
    qPExpParams = getQuestParamsExp3;
    nQuests = length(qPExpParams.stimUpperEnds);
    if (qPExpParams.DO_INITIALIZE)
        nQuests = length(qPExpParams.stimUpperEnds);
        for qq = 1:nQuests
            fprintf('Initializing quest structure %d\n',qq)
            questData{qq} = qpInitialize( ...
                'qpPF',qpPFFun, ...
                'stimParamsDomainList',{-qPExpParams.stimUpperEnds(qq):qPExpParams.stimUpperEnds(qq), -qPExpParams.stimUpperEnds(qq):qPExpParams.stimUpperEnds(qq), ...
                -qPExpParams.stimUpperEnds(qq):qPExpParams.stimUpperEnds(qq), -qPExpParams.stimUpperEnds(qq):qPExpParams.stimUpperEnds(qq)}, ...
                'psiParamsDomainList',{qPExpParams.Lin qPExpParams.Quad qPExpParams.Cubic ...
                qPExpParams.Lin qPExpParams.Quad qPExpParams.Cubic ...
                qPExpParams.weights} ,...
                'filterPsiParamsDomainFun',@(psiParams) qpQuestPlusColorMaterialCubicModelParamsCheck(psiParams,qPExpParams.maxStimValue,qPExpParams.maxPosition,qPExpParams.minSpacing));
        end
        %% Save out initialized quests
        save(fullfile(qPExpParams.initDir,['initalizedQuestsExp3-', date]),'questData');
    else
        load(fullfile(qPExpParams.initDir,params.initFilename));
    end
    
    % Define a questStructure that has all the stimuli
    % We use this as a simple way to account for every
    % stimulus in the analysis at the end.
    questDataAllTrials = questData{end};
    
    % Force questDataAllTrials not to update entropy.  If you want to see
    % the plot of entropies versus trials at the end, set this to false.
    % But it will slow down the simulation by about 0.5 secs/trial.
    questDataAllTrials.noentropy = true;
    
    % Start the experimental trial loop
    indexTrial = 0;
    for tt = 1:qPExpParams.nTrialsPerQuest
        
        % Set the order for the specified quests and random
        questOrder = randperm(length(qPExpParams.questOrderIn));
        for qq = 1:length(questOrder)
            
            % index the trial
            indexTrial = indexTrial+1;
            theQuest = qPExpParams.questOrderIn(questOrder(qq));
            
            % Get stimulus for this trial, either from one of the quests or at random.
            if (theQuest > 0)
                stim = qpQuery(questData{theQuest});
            else
                nStimuli = size(questDataAllTrials.stimParamsDomain,1);
                stim = questDataAllTrials.stimParamsDomain(randi(nStimuli),:);
            end
            
            % Clear out the mgl character queue.
            mglGetKeyEvent;
            
            % Get stimulus images for this trial
            stimulusOneIndex = intersect(find((imageList.stimulusListColor == stim(1))), find((imageList.stimulusListMaterial == stim(3))));
            sOne = load([imageList.imageName{stimulusOneIndex} '-RGB.mat']);
            if ~(strcmp(cal.describe.date, sOne.calData.date) && strcmp(sOne.calData.calFileName, getpref('ColorMaterial','calFileName')))
                error('Image file. Calibration files do not match.');
            end
            
            stimulusTwoIndex = intersect(find((imageList.stimulusListColor == stim(2))), find((imageList.stimulusListMaterial == stim(4))));
            sTwo = load([imageList.imageName{stimulusTwoIndex} '-RGB.mat']);
            if ~(strcmp(cal.describe.date, sTwo.calData.date) && strcmp(sTwo.calData.calFileName, getpref('ColorMaterial','calFileName')))
                error('Image file. Calibration files do not match.');
            end
            fprintf('\n')
            
            % Determine the positions of each competitor (left/right)
            positionOne = randi(2);
            
            % Add the stimulus
            win.addImage(params.targetImagePosition, params.imageSize, flip(target.sensorImageRGB,1),'Name','Target', 'Enabled', true);
            if positionOne == 1
                win.addImage(params.firstTestPosition, params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
                win.addImage(params.secondTestPosition,params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'STwo', 'Enabled', true);
            elseif positionOne == 2
                win.addImage(params.firstTestPosition, params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
                win.addImage(params.secondTestPosition,params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'STwo', 'Enabled', true);
            end
            
            % Start timing once the stimulus is drawn.
            trialStart(indexTrial) = win.draw;
            mglWaitSecs(params.waitTime);
            
            % Simulated observer models an observer where perception
            % positions match nominal positions and color-material weight i
            % as given;
            SIMULATE = false;
            if (SIMULATE)
%                 targetC = normrnd(0,1);
%                 targetM = normrnd(0,1);
%                 weight = 0.2; 
%                 if positionOne
%                     d1 = sqrt( weight*(3*stim(1) + normrnd(0,1) - targetC)^2 + (1-weight)*(2*stim(3) + normrnd(0,1) - targetM)^2 );
%                     d2 = sqrt( weight*(3*stim(2) + normrnd(0,1) - targetC)^2 + (1-weight)*(2*stim(4) + normrnd(0,1) - targetM)^2 );
%                 else
%                     d2 = sqrt( weight*(3*stim(1) + normrnd(0,1) - targetC)^2 + (1-weight)*(2*stim(3) + normrnd(0,1) - targetM)^2 );
%                     d1 = sqrt( weight*(3*stim(2) + normrnd(0,1) - targetC)^2 + (1-weight)*(2*stim(4) + normrnd(0,1) - targetM)^2 );
%                 end
%                 if (d1 < d2)
%                     outcome = 1;
%                 else
%                     outcome = 2;
%                 end
            else
                % Flush any key presses from the previous trial and get key
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
                                    outcome = 1;
                                    responseReceived(indexTrial) = mglGetSecs;
                                elseif (positionOne == 2)
                                    outcome = 2;
                                    responseReceived(indexTrial) = mglGetSecs;
                                end
                                beep;
                                win.addOval([params.positionLeft(1) params.positionLeft(2)], [params.checkSize(1), params.checkSize(2)], [0 0 0], 'Name', 'Check','Enabled', true);
                                win.draw;
                                pause(params.isi)
                                keepDrawing = false;
                            case 'd'  % right
                                if (positionOne == 1)
                                    outcome = 2;
                                elseif (positionOne == 2)
                                    outcome = 1;
                                end
                                beep;
                                win.addOval([params.positionRight(1) params.positionRight(2)], [params.checkSize(1), params.checkSize(2)], [0 0 0], 'Name', 'Check','Enabled', true);
                                win.draw;
                                pause(params.isi)
                                keepDrawing = false;
                            case 'q'
                                error('Abort program');
                        end
                    end
                    win.draw;
                end
            end
            win.disableAllObjects;
            trialEnd(indexTrial) = win.draw;
            
            mglWaitSecs(params.isi);
            
            % Update quest data structure, if not a randomly inserted trial
            if (theQuest > 0)
                questData{theQuest} = qpUpdate(questData{theQuest},stim,outcome);
            end
            
            % This data structure tracks all of the trials run in the
            % experiment.  We never query it to decide what to do, but we
            % will use it to fit the data at the end.
            questDataAllTrials = qpUpdate(questDataAllTrials,stim,outcome);
            
            if rem(indexTrial,qPExpParams.nTrialsPerQuest)==0
                done = (indexTrial)/qPExpParams.nTrialsPerQuest;
                left = length(questOrder)-done;
                if left > 0
                    % Flush any key presses from the previous trial.
                    key = -1;
                    while (~isempty(key))
                        key = mglGetKeyEvent(0);
                    end
                    % Report the progress
                    Speak(['Set ' num2str(done) 'done']);
                    if left == 1
                        Speak([num2str(left) 'more set to go']);
                    else
                        Speak([num2str(left) 'more sets to go']);
                    end
                    Speak('Take a break or press a button to continue.');
                    
                    % Pause until button press
                    pauseExp = true;
                    while pauseExp
                        key = mglGetKeyEvent(Inf);
                        if ~isempty(key)
                            if key.charCode == 'k'
                                pauseExp = false;
                            end
                        end
                    end
                end
            end
        end
    end
    win.close;
    ListenChar(0);
    params.data = questDataAllTrials;
    params.quest = questData;
    params.trialStart = trialStart;
    params.trialEnd = trialEnd;
    if ~SIMULATE
    	params.responseReceived = responseReceived;
    end
    % Toss the error back to Matlab's default error handler.
catch e
    if exist('win', 'var') && ~isempty(win)
        win.close;
    end
    ListenChar(0);
    rethrow(e);
end