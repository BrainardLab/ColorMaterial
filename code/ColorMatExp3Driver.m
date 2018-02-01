function params = ColorMatExp3Driver(exp)
% Program that executes the experiment based on the parameters that are
% passed.

% 12/08/17   ar Adapted it from the ColorMatExp2Driver.

try
    % Convert all the configfile parameters into simple struct values.
    cfgFile = ConfigFile(exp.configFileName);
    params = convertToStruct(cfgFile);
    
    % Load the calibration file and check the calibration age
    [cal, ~] = setCheckCalibration('EyeTrackerLCD', exp.subject);
    
    % Get the stimulus color matrix for all trials
    load('Exp3ImageList.mat');
    
    % Target is fixed across trials and predefined in the config file.
    target = load([params.targetName '-RGB.mat']);
    
    % Load the lookup table.
    theLookupTable = load('/Users/colorlab/Documents/MATLAB/toolboxes/BrainardLabToolbox/ColorMaterialModel/colorMaterialInterpolateFunLineareuclidean');
    
    % Define psychometric function in terms of lookup table
    qpPFFun = @(stimParams,psiParams) qpPFColorMaterialQuadModel(stimParams,psiParams,theLookupTable.colorMaterialInterpolatorFunction);
    
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
    %
    % Each one has a different upper end of stimulus regime
    % The last of these should be the most inclusive, and
    % include stimuli that could come from any of them.
    qPParams = getQuestParamsExp3;
    nQuests = length(qPParams.stimUpperEnds);
    if (qPParams.DO_INITIALIZE)
        nQuests = length(qPParams.stimUpperEnds);
        for qq = 1:nQuests
            fprintf('Initializing quest structure %d\n',qq)
            qTemp = qpParams( ...
                'qpPF',qpPFFun, ...
                'stimParamsDomainList',{-qPParams.stimUpperEnds(qq):qPParams.stimUpperEnds(qq), -qPParams.stimUpperEnds(qq):qPParams.stimUpperEnds(qq), ...
                -qPParams.stimUpperEnds(qq):qPParams.stimUpperEnds(qq), -qPParams.stimUpperEnds(qq):qPParams.stimUpperEnds(qq)}, ...
                'psiParamsDomainList',{[1/qPParams.upperLin 1/(qPParams.upperLin/2) 1 qPParams.upperLin/2 qPParams.upperLin] [-qPParams.upperQuad 0 qPParams.upperQuad] [-qPParams.upperCubic 0 qPParams.upperCubic] ...
                [1/qPParams.upperLin 1 qPParams.upperLin] [-qPParams.upperQuad 0 qPParams.upperQuad] [-qPParams.upperCubic 0 qPParams.upperCubic] ...
                qPParams.weights} ...
                );
            questData{qq} = qpInitialize(qTemp);
        end
        
        %% Define a questStructure that has all the stimuli
        %
        % We use this as a simple way to account for every
        % stimulus in the analysis at the end.  Set noentropy
        % flag so that update is fast, because we don't use this
        % one to select trials.
        questDataAllTrials = questData{end};
        
        %% Save out initialized quests
        save(fullfile(qPParams.initDir,'initalizedQuestsExp3'),'questData','questDataAllTrials');
    else
        load(fullfile(qPParams.initDir,'initalizedQuestsExp3'));
    end
    
    % Force questDataAllTrials not to update entropy.  If you want to see
    % the plot of entropies versus trials at the end, set this to false.
    % But it will slow down the simulation by about 0.5 secs/trial.
    questDataAllTrials.noentropy = true;
    
    % Define a questStructure that has all the stimuli
    % We use this as a simple way to account for every
    % stimulus in the analysis at the end.
    questDataAllTrials = questData{end};
    
    % Run simulated trials, using QUEST+ to tell us what contrast to
    %
    % Define how many of each type of trial selection we'll do each time through.
    % 0 -> choose at random from all trials.
    indexTrial = 0; 
    for tt = 1:qPParams.nTrialsPerQuest
        
        
        % Set the order for the specified quests and random
        questOrder = randperm(length(qPParams.questOrderIn));
        for qq = 1:length(questOrder)
      
            % index the trial
            indexTrial = indexTrial+1; 
            theQuest = qPParams.questOrderIn(questOrder(qq));
            
            % Get stimulus for this trial, either from one of the quests or at random.
            if (theQuest > 0)
                stim = qpQuery(questData{theQuest});
            else
                nStimuli = size(questDataAllTrials.stimParamsDomain,1);
                stim = questDataAllTrials.stimParamsDomain(randi(nStimuli),:);
            end
            % Stimulus display
            % Clear out the mgl character queue.
        
            mglGetKeyEvent;
            
            % Add stimulus images for this trial
            stimulusOneIndex = intersect(find((imageList.stimulusListColor == stim(1))) , find((imageList.stimulusListMaterial == stim(2))));
            sOne = load([imageList.imageName{stimulusOneIndex} '-RGB.mat']);
            stimulusTwoIndex = intersect(find((imageList.stimulusListColor == stim(3))) , find((imageList.stimulusListMaterial == stim(4))));
            sTwo = load([imageList.imageName{stimulusTwoIndex} '-RGB.mat']);
            positionOne = randi(2);
            
            % sanity check from qpModelCode
            % colorMatchColorCoords = colorCoordinateSlope*stimParams(:,1);
            % materialMatchColorCoords = colorCoordinateSlope*stimParams(:,2);
            % colorMatchMaterialCoords = materialCoordinateSlope*stimParams(:,3);
            % materialMatchMaterialCoords = materialCoordinateSlope*stimParams(:,4);
            
            win.addImage(params.targetImagePosition, params.imageSize, flip(target.sensorImageRGB,1), 'Name', 'Target', 'Enabled', true);
            if positionOne == 1
                win.addImage(params.firstTestPosition, params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
                win.addImage(params.secondTestPosition,params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'STwo','Enabled', true);
            elseif positionOne == 2
                win.addImage(params.firstTestPosition, params.imageSize, flip(sTwo.sensorImageRGB,1), 'Name', 'SOne', 'Enabled', true);
                win.addImage(params.secondTestPosition,   params.imageSize, flip(sOne.sensorImageRGB,1), 'Name', 'STwo','Enabled', true);
            end
            % Start timing once the stimulus is drawn.
            trialStart(indexTrial) = win.draw;
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
                                outcome = 1;
                            elseif (positionOne == 2)
                                outcome = 2;
                            end
                            beep;
                            win.addOval([params.positionLeft(1) params.positionLeft(2)], [params.checkSize(1), params.checkSize(2)], [0 0 0], 'Name', 'Check','Enabled', true);
                            win.draw
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
            trialEnd(indexTrial) = win.draw;
            %  Speak('Wait for the next trial');
            mglWaitSecs(params.isi);
            
            % Update quest data structure, if not a randomly inserted trial
            %tic
            if (theQuest > 0)
                questData{theQuest} = qpUpdate(questData{theQuest},stim,outcome);
            end
            
            % This data structure tracks all of the trials run in the
            % experiment.  We never query it to decide what to do, but we
            % will use it to fit the data at the end.
            questDataAllTrials = qpUpdate(questDataAllTrials,stim,outcome);
        end
    end
    win.close;
    ListenChar(0);
    params.data = questDataAllTrials;
    params.quest = questData;
    params.trialStart = trialStart;
    params.trialEnd = trialEnd;
    % Toss the error back to Matlab's default error handler.
catch e
    if exist('win', 'var') && ~isempty(win)
        win.close;
    end
    ListenChar(0);
    rethrow(e);
end
end