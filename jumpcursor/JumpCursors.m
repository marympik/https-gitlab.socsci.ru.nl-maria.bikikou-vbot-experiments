classdef JumpCursors <  wl_experiment
  
    methods
        % must implement ALL abstract methods or matlab will complain.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function run(WL,varargin)
            try
                WL.GUI = wl_gui('test','JumpCursors_cfg','FF',varargin{:});

                ok = WL.initialise(); % Also calls initialise_func().
                if( ~ok )
                    wl_printf('error','Initialisation aborted!\n')
                    return;
                end
                WL.Robot = WL.robot(WL.cfg.RobotName); % Mouse Flag and Max Force processed automatically.
                WL.Hardware = wl_hardware(WL.Robot);
                ok = WL.Hardware.Start();
                

                if( ok )
                    WL.main_loop();
                end

                WL.Hardware.Stop();

            catch msg
                WL.close(msg); % Does everything we need to do before exiting.
            end   
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function initialise_func(WL, varargin)
            WL.state_init('INITIALIZE','SETUP','HOME','START','DELAY','GO','MOVEWAIT',...
                'MOVING','CURSORJUMP','POSTJUMP','FINISH','NEXT','INTERTRIAL','EXIT','TIMEOUT','ERROR','REST');
            WL.cfg.count=1;
            WL.cfg.CursorPositionHistory=zeros(50,3);


            % Define possible jump distances in cm (converted to meters if needed)
            %possibleJumpDistances = [0.04, 0.05, 0.06, 0.07, 0.08];  % in meters

            % Check if the JumpDistance field exists, if not, initialize it
            if ~ismember('JumpDistance', WL.TrialData.Properties.VariableNames)
                % Add JumpDistance field and initialize with zeros
                WL.TrialData.JumpDistance = zeros(height(WL.TrialData), 1);
            end

            % Randomly assign a jump distance to each trial from the predefined list
            possibleJumpDistances = WL.cfg.possibleJumpDistances;  % Use the possible jump distances from the config
            for i = 1:height(WL.TrialData)
                WL.TrialData.JumpDistance(i) = possibleJumpDistances(randi(length(possibleJumpDistances)));  % Randomly select a distance
            end

            % Additional initialization logic...
            for i = 1:3
                j = find((WL.TrialData.block_index == i) & ((WL.TrialData.FieldType == 0) | (WL.TrialData.FieldType == 1)));
                WL.cfg.PhaseTrialCount(i) = length(j);
            end


            WL.cfg.explosion1 = wl_draw_explode(WL.cfg.TargetRadius, [1 1 1], 80/100 );

            WL.Trial.TrialNumber = 0;

            WL.cfg.cb=wl_circbuffer(50,3);
            close all
            fig  = figure(1);
            aa= get(0, 'screensize');
            set(gcf,'Position', [aa(3:4)/2-30 aa(3:4)/2-30])
            WL.cfg.hasJumped = false;
            WL.cfg.shown = false;
            WL.cfg.jumpIndex = 1;
            WL.cfg.CursorVisible = false; % Cursor initially not visible
            WL.cfg.TargetVisible = false;
            WL.cfg.JumpTimer = 0;
            WL.Timer.CursorVisibilityTimer = wl_timer;
            WL.cfg.CursorVisibilityDuration = 0.1;
            % Initialize the target position relative to the home position
            WL.cfg.targetPosition = WL.cfg.HomePosition;
            WL.cfg.targetPosition(2) = WL.cfg.targetPosition(2) + WL.cfg.TargetDistance; % Moving 20 units along y-axis
            WL.cfg.hasPlayedFourthBeep = false;
            WL.cfg.hasPlayedThreeBeeps = false;


            WL.Timer.MovementDurationTimer = wl_timer;
            WL.Timer.MovementReactionTimer = wl_timer;
            WL.Timer.StimulusTime = wl_timer;


        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function idle_func(WL)
            R = eye(3);
            WL.cfg.CursorPosition=WL.cfg.HomePosition+R*(WL.Robot.Position-WL.cfg.HomePosition);
            WL.cfg.display_target= (WL.State.Current == WL.State.INITIALIZE) || ((WL.State.Current>=WL.State.GO) && (WL.State.Current<=WL.State.FINISH));
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function display_func(WL, win)

            Screen('BeginOpenGL', win);

            txt = sprintf('State = %s, x=%.1f, y=%.1f, CursorVisible=%d, ', WL.State.Name{WL.State.Current}, WL.Robot.Position(1), WL.Robot.Position(2), int8(WL.cfg.CursorVisible));
            v = sqrt(sum(WL.Robot.Velocity .^2));
            % txt = sprintf('velocity = %.2f', v);
            WL.draw_text(txt, [0 0 0], 'Scale', 0.5);
            
            cursorPos = WL.Robot.Position + [WL.cfg.hasJumped * WL.Trial.JumpDistance, 0, 0]';
            if WL.cfg.CursorVisible
                % red visible
                wl_draw_sphere(cursorPos, WL.cfg.CursorRadius, [1 0 0]);
            else
                % gray invisible
                wl_draw_sphere(cursorPos, WL.cfg.CursorRadius, 0.3*[1 1 1]);
            end

            if WL.cfg.TargetVisible
                wl_draw_sphere(WL.Trial.TargetPosition + [0 0 -2]', WL.cfg.TargetRadius, [1 1 0], 'Alpha', 0.7);
            else
                wl_draw_sphere(WL.Trial.TargetPosition + [0 0 -2]', WL.cfg.TargetRadius, 0.3*[1 1 1], 'Alpha', 0.7);
            end

            % Always draw the home position
            wl_draw_sphere(WL.cfg.HomePosition + [0 0 -2]', WL.cfg.HomeRadius, [0 1 1], 'Alpha', 0.7);

            if WL.cfg.hasJumped
                elapsedTime = WL.Timer.CursorVisibilityTimer.GetTime();
                if elapsedTime > WL.cfg.CursorVisibilityDuration
                    if WL.cfg.CursorVisible  % Check to ensure the cursor is currently visible
                        WL.cfg.CursorVisible = false;  % Make the cursor invisible
                        disp(['Cursor visibility set to false after ', num2str(elapsedTime), ' seconds.']);
                    end
                else
                    disp(['Cursor is visible. Elapsed time: ', num2str(elapsedTime), ' seconds.']);
                end
            end

            Screen('EndOpenGL', win);
            % Display text information
            if all(WL.Robot.Active)
                if WL.State.Current == WL.State.HOME
                    txt = 'Move to Start Position';
                else
                    txt = sprintf('Movement %i of %i', ceil(WL.TrialNumber / 2), ceil(rows(WL.TrialData) / 2));
                end
            else
                txt = 'Handle Switch';
            end
            WL.draw_text(txt, [0 -20 0]);
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function state_process_func(WL)
            if  WL.cfg.TrialRunning && any(~WL.Robot.Active) % If robot is not active, abort current trial.
                WL.trial_abort('Handle Switch',WL.State.SETUP);
            end

            switch WL.State.Current % State processing.

                case WL.State.INITIALIZE % Initialization state.
                    WL.cfg.hasJumped = false;
                    WL.Timer.Paradigm.ExperimentTimer.Reset;
                    WL.state_next(WL.State.SETUP);


                case WL.State.SETUP % Setup details of next trial, but only when robot stationary and active.
                    if all(WL.Robot.Active)
                        WL.cfg.shown = false;
                        WL.cfg.CursorVisible = false;
                        WL.cfg.hasPlayedFourthBeep = false;
                        WL.trial_setup();
                        WL.state_next(WL.State.HOME);
                    end

                case WL.State.HOME % Start trial when robot in home position (and stationary and active).
                    if WL.Robot.Position(2) < 0
                        WL.cfg.CursorVisible = true;
                        WL.cfg.TargetVisible = true;
                    end
                    if (WL.robot_stationary() &&  WL.robot_home() && all(WL.Robot.Active))
                        % WL.cfg.hasJumped = false;
                        WL.state_next(WL.State.START);
                    end

                case WL.State.START % Start trial.
                    WL.cfg.CursorVisible = false;
                    WL.trial_start();
                    % WL.cfg.hasJumped = false;

                    if WL.Trial.ReturnFlag
                        WL.state_next(WL.State.MOVING);
                    else
                        disp('DELAYYYYYYYYYYYYYYYYYYYYYYY');
                        WL.state_next(WL.State.DELAY);

                    end

                case WL.State.DELAY           % Delay period before go signal.
                    WL.cfg.hasJumped = false;
                    if WL.State.Timer.GetTime>WL.cfg.TrialDelay
                        disp(' timer')
                        WL.state_next(WL.State.GO);
                    elseif  WL.movement_started()
                        %  WL.error_state('Moved Too Soon',WL.State.SETUP);
                        %WL.trial_abort();
                    end

                case WL.State.GO % Go signal to cue movement.
                    WL.cfg.hasJumped = false;
                    WL.cfg.hasPlayedFourthBeep = false;  % Reset the flag at the start of the trial
                    WL.Timer.MovementReactionTimer.Reset();
                    % Debug: Check the current SpeedCue
                    disp(['Trial ', num2str(WL.TrialNumber), ': SpeedCue = ', WL.TrialData.SpeedCue{WL.TrialNumber}]);

                    % Get the current trial's speed cue
                    currentSpeedCue = WL.TrialData.SpeedCue{WL.TrialNumber};

                    if strcmp(currentSpeedCue, 'fast')
                        % Three quick high-pitched beeps
                        WL.play_sound(WL.cfg.highbeep);
                        disp('Playing first three fast beeps');
                    elseif strcmp(currentSpeedCue, 'slow')
                        % Three slow low-pitched beeps
                        WL.play_sound(WL.cfg.slowbeep);
                        disp('Playing first three slow beeps');
                    else
                        disp('Error: Unrecognized SpeedCue value');
                    end

                    WL.cfg.hasPlayedThreeBeeps = true;  % Mark that the first three beeps were played
                    WL.Timer.StimulusTime.Reset();
                    WL.state_next(WL.State.MOVEWAIT);  % Move to next state

                case WL.State.MOVEWAIT
                    if  WL.movement_started()
                        WL.cfg.hasJumped = false;
                        WL.Timer.MovementDurationTimer.Reset;
                        WL.Trial.MovementReactionTime = WL.Timer.MovementReactionTimer.GetTime;

                        WL.state_next(WL.State.MOVING)
                    elseif WL.Timer.MovementReactionTimer.GetTime>WL.cfg.MovementReactionTimeOut
                        WL.state_next(WL.State.TIMEOUT);
                    end
                case WL.State.MOVING
                    WL.cfg.CursorPosition = WL.Robot.Position; % Update cursor position continuously
                    WL.cfg.hasPlayedFourthBeep = false;
                    disp('Current State: MOVING');
                    %disp(['Cursor Position (MOVING): ', mat2str(WL.cfg.CursorPosition)]);
                    if reaches_jump_point(WL) && ~WL.cfg.hasJumped % Check if it's time to jump
                        disp('Transitioning to CURSORJUMP');
                        WL.state_next(WL.State.CURSORJUMP);
                    end
                case WL.State.CURSORJUMP
                    if ~WL.cfg.hasJumped
                        %jump_distance = WL.Trial.JumpDistance;
                        WL.cfg.CursorVisible = true;
                        WL.cfg.hasJumped = true;
                        WL.Timer.CursorVisibilityTimer.Reset;
                        WL.state_next(WL.State.POSTJUMP);
                    end

                case WL.State.POSTJUMP
                    % Check if 100ms have passed since the jump
                    WL.cfg.hasPlayedFourthBeep = false;
                    if WL.Timer.CursorVisibilityTimer.GetTime() > 0.1
                        WL.cfg.CursorVisible = false;
                    end

                    if WL.movement_finished()
                        % If movement has finished and the 4th beep hasn't played yet
                        if ~WL.cfg.hasPlayedFourthBeep
                            currentSpeedCue = WL.Trial.SpeedCue;  % Get the current trial's speed
            
                            % Play the 4th beep based on whether the trial is fast or slow
                            if strcmp(currentSpeedCue, 'fast')
                                WL.play_sound(WL.cfg.fastfourthbeep);  % Play 4th beep for fast trials
                                disp('Playing the 4th fast beep at the target');
                                WL.cfg.hasPlayedFourthBeep = true;
                            elseif strcmp(currentSpeedCue, 'slow')
                                WL.play_sound(WL.cfg.slowfourthbeep);  % Play 4th beep for slow trials
                                disp('Playing the 4th slow beep at the target');
                                WL.cfg.hasPlayedFourthBeep = true;
                            end
                        end
                        WL.cfg.TargetVisible = false;
                        WL.Trial.MovementDurationTime = WL.Timer.MovementDurationTimer.GetTime;
                        if ~WL.Trial.ReturnFlag
                            WL.cfg.explosion1.ExplodePop(WL.Trial.TargetPosition);
                        end
                        disp('POSTJUMP TO FINISH');
                        % Example of collecting data after a trial ends
                        WL.state_next(WL.State.FINISH);
                    elseif WL.Timer.MovementDurationTimer.GetTime > WL.cfg.MovementDurationTimeOut && ~WL.Trial.ReturnFlag
                        disp('POSTJUMP TO tiemout');
                        WL.state_next(WL.State.TIMEOUT);
                    end

                case WL.State.FINISH
                    WL.cfg.hasJumped = false;
                    ok = WL.Robot.RampDown();
                    if WL.State.FirstFlag
                        fprintf(1,'TrialStop\n');
                        WL.trial_stop();
                    end
                    if WL.State.Timer.GetTime > WL.cfg.FinishDelay
                        % Increment the trial number
                        WL.TrialNumber = WL.TrialNumber + 1;

                        % Check if there are more trials
                        if WL.TrialNumber <= height(WL.TrialData)
                            WL.state_next(WL.State.SETUP);  % Move to SETUP for the next trial
                        else
                            WL.state_next(WL.State.EXIT);  % If all trials are done, exit
                        end
                    end

                    WL.State.FirstFlag = false;

                    if   WL.State.Timer.GetTime > WL.cfg.FinishDelay && WL.cfg.explosion1.ExplodeState ~= WL.cfg.explosion1.EXPLODE_POPPING  % Trial has finished so stop trial.
                        WL.Timer.Paradigm.InterTrialDelayTimer.Reset;

                        if  ~WL.trial_save()
                            WL.printf('Cannot save Trial %d.\n',WL.TrialNumber);
                            disp('FINISH to exit');
                            WL.state_next(WL.State.EXIT);
                        else
                            [~, WL.var.data, names] = WL.Hardware.DataGet(); %get frame data
                            WL.var.data=WL.var.data{1};
                            WL.var.data.TrialData = WL.TrialData(WL.TrialNumber,:);
                            if  rem(WL.TrialNumber,2)==1
                                %WL.plot_results
                            end

                            WL.state_next(WL.State.SETUP);
                            disp('FINISH to setup');
                        end
                    end

                case WL.State.NEXT

                    if WL.Trial.RestFlag==1
                        disp('NEXT to REST');
                        WL.state_next(WL.State.REST);
                    elseif  ~WL.trial_next()
                        disp('NEXT to EXIT');
                        WL.state_next(WL.State.EXIT);
                    else
                        disp('NEXT to INTERTRIAL');
                        WL.state_next(WL.State.INTERTRIAL);
                    end

                case WL.State.INTERTRIAL % Wait for the intertrial delay to expire.
                    if WL. Timer.Paradigm.InterTrialDelayTimer.GetTime > WL.cfg.InterTrialDelay
                        disp('INTERTRIAL TO SETUP');
                        WL.state_next(WL.State.SETUP);
                    end

                case WL.State.EXIT
                    WL.cfg.ExperimentSeconds = WL.Timer.Paradigm.ExperimentTimer.GetTime;
                    WL.cfg.ExperimentMinutes = WL.cfg.ExperimentSeconds / 60.0;
                    WL.printf('Game Over (%.1f minutes)',WL.cfg.ExperimentMinutes);
                    WL.cfg.ExitFlag = true;
                    save('TrialDataList.mat', 'WL.TrialDataList');

                case WL.State.TIMEOUT

                case WL.State.ERROR
                    if  WL.State.Timer.GetTime > WL.cfg.ErrorWait
                        WL.error_resume();
                    end

                case WL.State.REST
                    RestBreakRemainSeconds = (WL.cfg.RestBreakSeconds -  WL.State.Timer.GetTime);
                    WL.cfg.RestBreakRemainPercent = (RestBreakRemainSeconds / WL.cfg.RestBreakSeconds);

                    if  RestBreakRemainSeconds < 0
                        WL.Trial.RestFlag = 0;
                        disp('REST TO NEXT');
                        WL.state_next(WL.State.NEXT);
                    end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function trial_start_func(WL)


            if ~WL.Trial.ReturnFlag
                % No more force fields here.
                disp('Trial started without force implementation');
            else
                % Keeping the return movement if you need that, otherwise remove this too.
                ok = WL.Robot.FieldPMove(WL.Trial.ReturnTargetPosition,0.5,0.2);
                WL.Robot.PMoveFinished = 0;
            end

            % Remove the force ramp-up call, if not necessary:
            % ok = WL.Robot.RampUp();


            ok = WL.Robot.RampUp();

        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function miss_trial_func(WL,MissTrialType)   
            WL.cfg.MissTrial=1;
            if  ~wl_trial_save(WL)   % Save the data for WL trial.
                fprintf(1,'Cannot save Trial %d.\n',WL.TrialNumber);
            end
            WL.cfg.MissTrial=0;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out=robot_home(WL)
            err = norm(WL.Robot.Position - WL.cfg.HomePosition);
            out = err<WL.cfg.HomeRadius;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function flag = movement_finished(WL)
            currentPosition = WL.Robot.Position;  % Get the current robot position
            currentVelocity = sqrt (sum ( WL.Robot.Velocity .^2)) ;  %  velocity
            % Update previous position for the next frame
            flag = WL.Robot.Position(2) >= WL.cfg.TargetPosition(2) && ~WL.cfg.hasPlayedFourthBeep && currentVelocity < WL.cfg.VelocityThreshold ;
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = movement_started(WL)
            out = ~WL.robot_home();
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function keyboard_func(WL,keyname)  end
        function flip_func(WL)      end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
        function flag = reaches_jump_point(WL)
            % Define the fixed distance for the jump
            fixed_distance = 7;  % 4 units
        
            % Calculate the y-axis distance from the cursor's position to the home position
            current_distance_y = WL.cfg.CursorPosition(2) - WL.cfg.HomePosition(2);
        
            % Check if the cursor has reached or surpassed the fixed distance along the y-axis
            flag = current_distance_y >= fixed_distance;
        
            disp(flag);
            disp(fixed_distance);
            disp(current_distance_y >= fixed_distance);
        end
    end
end
