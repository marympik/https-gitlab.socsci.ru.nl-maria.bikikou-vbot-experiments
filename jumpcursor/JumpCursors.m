classdef JumpCursors < wl_experiment
  methods
    % Main function to run the experiment
    function run(WL, participantNumber, varargin)
      try
        % Initialize GUI
        WL.GUI = wl_gui('test','JumpCursors_cfg','FF',varargin{:});

        % Initialize the experiment (calls initialise_func internally)
        ok = WL.initialise();

        if ~ok
          wl_printf('error', 'Initialisation aborted!\n');
          return;
        end

        %Configure the experiment for the participant
        JumpCursors_cfg(WL, participantNumber);  % Pass participant number to the config function


        % Initialize robot and hardware
        WL.Robot = WL.robot(WL.cfg.RobotName);  % Mouse Flag and Max Force processed automatically

        % Set up S826 analog input and digital output channels.
        WL.Sensoray = wl_sensoray(WL.cfg.SensorayAddress); % Address should be -1 if used with a robot.
        ok = WL.Sensoray.AnalogInputSetup(WL.cfg.SensorayAnalogChannels);
        WL.Hardware = wl_hardware(WL.Robot ,  WL.Sensoray ); % Initialize hardware, WL.Sensoray
        ok = WL.Hardware.Start();




        % Start the main loop if hardware initialized successfully
        if ok
          % Start from the INSTRUCTIONS state
          WL.state_next(WL.State.INSTRUCTIONS);
          WL.main_loop();  % Main experiment loop
        end
        % Stop hardware after the experiment
        WL.Hardware.Stop();

      catch msg
        % Handle any errors and close the experiment
        disp(['Error occurred: ', msg.message]);
        WL.close(msg);
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function  initialise_func(WL, varargin)
      WL.state_init('INSTRUCTIONS', 'INITIALIZE','SETUP','HOME','START','DELAY','GO','MOVEWAIT',...
        'MOVING','CURSORJUMP','POSTJUMP','FINISH','NEXT','INTERTRIAL','EXIT','TIMEOUT','ERROR','REST', 'EXTRATRIALS');
      WL.cfg.count=1;
      WL.cfg.CursorPositionHistory = zeros(50, 3);

      % Randomly assign a jump distance to each trial from the predefined list
      possibleJumpDistances = WL.cfg.possibleJumpDistances;  % Use the possible jump distances from the config
      for i = 1:height(WL.TrialData)
        WL.TrialData.JumpDistance(i) = possibleJumpDistances(randi(length(possibleJumpDistances)));  % Randomly select a distance
      end

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
      WL.cfg.targetDurationFast = 0.8;  % example value in seconds for fast movements
      WL.cfg.targetDurationSlow = 1.4;  % example value in seconds for slow movements
      WL.cfg.tolerance = 0.3;  % tolerance in seconds
      WL.cfg.feedbackMessage = '';  % Initialize as empty
      WL.cfg.feedbackColor = [1 0 0];
      WL.cfg.errorMessage = '';  % Initialize as empty
      WL.cfg.errorColor = [1 0 0];
      WL.Timer.MovementDurationTimer = wl_timer;  % Initialize the movement duration timer
      WL.Timer.FeedbackTimer = wl_timer;          % Initialize the feedback timer
      WL.Timer.MovementReactionTimer = wl_timer;  % Initialize other timers
      WL.Timer.StimulusTime = wl_timer;           % Initialize other timers
      WL.cfg.movementDuration = WL.Timer.MovementDurationTimer.GetTime();
      WL.cfg.errorMessage = '';  % Initialize error message
      WL.cfg.errorColor = [1, 0, 0];
      WL.Timer.ErrorDisplayTimer = wl_timer();
      WL.cfg.isTargetShifted = false;


    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function idle_func(WL)
      % Directly set the cursor position to the robot's current position
      WL.cfg.CursorPosition = WL.Robot.Position;

      % Determine if the target should be displayed based on the current state
      WL.cfg.display_target = (WL.State.Current == WL.State.INITIALIZE) || ...
        ((WL.State.Current >= WL.State.GO) && (WL.State.Current <= WL.State.FINISH));
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function display_func(WL, win)


      Screen('BeginOpenGL', win);
      if WL.State.Current == WL.State.INSTRUCTIONS
        instructionLines = {
          'Welcome to our study!',
          'In this experiment, we ask you to reach with your hand from a start position to a target holding a handle.',
          'You will not be able to see your hand during the experiment.',
          'Your goal is to stop your hand in the target as accurately as possible.',
          'Once you have reached the target, you will hear a sound and the target will disappear.',
          'Then you can move your hand back to the start',
          'The speed of movement is instructed by the pitch of a sound : low pitch corresponds to move slower,',
          'and high-pitch corresponds to move faster. You will practice the speed cues before the experiment',
          'and you will perform the same speed within a block of trials',
          'Good Luck!'
          };

        % Starting vertical position
        yPosition = 12;  % Adjust as needed
        yOffset = -2;    % Vertical offset for each new line

        % Draw each line of instructions
        for i = 1:length(instructionLines)
          WL.draw_text(instructionLines{i}, [0 yPosition 0], 'Scale', 0.5, 'Color', [1 1 1], 'Center', 1);
          yPosition = yPosition + yOffset;
        end
      end


      v = sqrt(sum(WL.Robot.Velocity .^2));
      if  isfield(WL.Trial, 'TargetPosition') && ~isempty(WL.Trial.TargetPosition)
        wl_draw_sphere(WL.Trial.TargetPosition + [0 0 -2]', WL.cfg.TargetRadius, [1 1 0], 'Alpha', 0.7);
      end


      % Ensure cursor visibility for practice trials
      if WL.cfg.isPracticeTrial
        % During practice trials, make the cursor always visible and do not perform jumps
        WL.cfg.CursorVisible = true;
        cursorPos = WL.Robot.Position;  % No jumps during practice trials
        wl_draw_sphere(cursorPos, WL.cfg.CursorRadius, [1 0 0]);  % Draw the cursor in red
      elseif WL.cfg.CursorVisible
        % Regular behavior for actual trials
        cursorPos = WL.Robot.Position + [WL.cfg.hasJumped * WL.Trial.JumpDistance, 0, 0]';
        wl_draw_sphere(cursorPos, WL.cfg.CursorRadius, [1 0 0]);
      end

      if WL.cfg.TargetVisible
        wl_draw_sphere(WL.cfg.TargetPosition + [0 0 -2]', WL.cfg.TargetRadius, [1 1 0], 'Alpha', 0.7);
      end

      % Always draw the home position

      if WL.State.Current == WL.State.INSTRUCTIONS
        wl_draw_sphere(WL.cfg.HomePosition + [0 0 -2]', WL.cfg.HomeRadius, [0 0 0], 'Alpha', 0.7);
      else
        wl_draw_sphere(WL.cfg.HomePosition + [0 0 -2]', WL.cfg.HomeRadius, [0 1 1], 'Alpha', 0.7);
      end

      % Draw feedback message for practice trials if the feedback timer is active
      if  ~isempty(WL.cfg.feedbackMessage) && WL.Timer.FeedbackTimer.GetTime() < 1
        WL.draw_text(WL.cfg.feedbackMessage, [0 10 0], 'Scale', 0.7, 'Color', WL.cfg.feedbackColor);
      end

      % Draw error messages for actual trials
     
      if   ((strcmp(WL.Trial.block_name, 'FastJumps')) || (strcmp(WL.Trial.block_name,'SlowJumps'))) && ~isempty(WL.cfg.errorMessage) && WL.Timer.ErrorDisplayTimer.GetTime() < 0.4
        % Show the error message for 1.5 seconds
        WL.draw_text(WL.cfg.errorMessage, [0 10 0], 'Scale', 0.7, 'Color', WL.cfg.errorColor);
      end

      if WL.State.Current == WL.State.REST
        WL.draw_text('Take a break! Press any key to continue.', [0 10 0], 'Scale', 0.7, 'Color', [1 1 1]);
      end

      %
      
      %if (strcmp(WL.Trial.block_name, 'FastJumps') or (strcmp(WL.Trial.block_name,'SlowJumps')))
      if WL.cfg.hasJumped
        elapsedTime = WL.Timer.CursorVisibilityTimer.GetTime();
        if elapsedTime > WL.cfg.CursorVisibilityDuration
          if WL.cfg.CursorVisible  % Check to ensure the cursor is currently visible
            WL.cfg.CursorVisible = false;  % Make the cursor invisible
          end
        end
      end
     

      %define when to draw to activate the photodiode
      if (WL.cfg.CursorVisible && WL.State.Current == WL.State.POSTJUMP )
        wl_draw_circle(WL.cfg.PhotoDiodePosition', WL.cfg.PhotoDiodeRadius, 0, [1 1 1]);
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
        case WL.State.INSTRUCTIONS

          % Wait for key press to continue
          if KbCheck
            WaitSecs(0.1);  % Debounce delay
            WL.state_next(WL.State.INITIALIZE);  % Move to the initialize state after instructions
          end

        case WL.State.INITIALIZE % Initialization state.
          WL.cfg.CursorPosition = WL.Robot.Position;
          WL.cfg.hasJumped = false;
          WL.Timer.Paradigm.ExperimentTimer.Reset;
          WL.state_next(WL.State.SETUP);


        case WL.State.SETUP % Setup details of next trial, but only when robot stationary and active.
          if all(WL.Robot.Active)
            WL.cfg.CursorPosition = WL.Robot.Position;
            WL.cfg.CursorVisible = true;
            WL.cfg.PositionLog = [];
            WL.cfg.hasPlayedFourthBeep = false;
            WL.trial_setup();
            if ~WL.cfg.isPracticeTrial
              if ismember(WL.TrialNumber, WL.cfg.shiftedTrials)
                % Shift the target randomly to the left or right
                WL = random_target_shift(WL);
                WL.cfg.isTargetShifted = true;
                WL.cfg.CursorVisible = false;
              else
                % Reset target to original position
                WL = reset_target_position(WL);

                % Regular trial behavior
                WL.cfg.CursorVisible = false;
              end
            end
            WL.state_next(WL.State.HOME);
            if WL.Robot.Position(2) < 0
              WL.cfg.CursorVisible = true;
              WL.cfg.TargetVisible = true;
            end
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
          WL.Timer.MovementDurationTimer.Reset();
          WL.cfg.CursorVisible = false;
          WL.trial_start();
          WL.state_next(WL.State.DELAY);

        case WL.State.DELAY           % Delay period before go signal.
          WL.cfg.hasJumped = false;
          if WL.State.Timer.GetTime>WL.cfg.TrialDelay
            % disp(' timer')
            WL.state_next(WL.State.GO);


          elseif  WL.movement_started()
            %  WL.error_state('Moved Too Soon',WL.State.SETUP);
            %WL.trial_abort();
          end

        case WL.State.GO % Go signal to cue movement.
          WL.cfg.hasJumped = false;
          WL.cfg.hasPlayedFourthBeep = false;  % Reset the flag at the start of the trial
          WL.Timer.MovementReactionTimer.Reset();
          currentSpeedCue = WL.TrialData.SpeedCue{WL.TrialNumber};

          if strcmp(currentSpeedCue, 'fast')
            % Three quick high-pitched beeps
            WL.play_sound(WL.cfg.highbeep);
            %disp('Playing first three fast beeps');
          elseif strcmp(currentSpeedCue, 'slow')
            % Three slow low-pitched beeps
            WL.play_sound(WL.cfg.slowbeep);
            %disp('Playing first three slow beeps');
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
            WL.cfg.PositionLog = [WL.cfg.PositionLog; WL.Robot.Position'];  % Log positions over time
          elseif WL.Timer.MovementReactionTimer.GetTime>WL.cfg.MovementReactionTimeOut
            WL.state_next(WL.State.TIMEOUT);
          end
        case WL.State.MOVING
          WL.cfg.CursorPosition = WL.Robot.Position; % Update cursor position continuously
          if WL.cfg.isPracticeTrial
          else
            % Regular behavior for experimental trials
          end
          WL.cfg.hasPlayedFourthBeep = false;
          if (~(strcmp(WL.Trial.block_name, 'FastJumps')) && ~(strcmp(WL.Trial.block_name,'SlowJumps')))
            WL.cfg.CursorVisible = true;
          else
            WL.cfg.CursorVisible = false;

          end

          %%if reaches_jump_point(WL) && ~WL.cfg.hasJumped % Check if it's time to jump
          if  reaches_jump_point(WL) && ~WL.cfg.hasJumped
            %disp('Transitioning to CURSORJUMP');
            WL.state_next(WL.State.CURSORJUMP);
            %elseif WL.movement_finished()
            %  WL.cfg.movementDurationTime = WL.Timer.MovementDurationTimer.GetTime();
            %  WL.state_next(WL.State.FINISH);
          end
        case WL.State.CURSORJUMP
          if ~WL.cfg.hasJumped
            WL.cfg.CursorVisible = true;
            WL.cfg.hasJumped = true;
            WL.Timer.CursorVisibilityTimer.Reset;
            WL.state_next(WL.State.POSTJUMP);
          end

        case WL.State.POSTJUMP
          % Check if 100ms have passed since the jump
          WL.cfg.hasPlayedFourthBeep = false;
          if WL.Timer.CursorVisibilityTimer.GetTime() > 0.1
            if (~(strcmp(WL.Trial.block_name, 'FastJumps')) && ~(strcmp(WL.Trial.block_name,'SlowJumps')))
              WL.cfg.CursorVisible = true;
            else
              WL.cfg.CursorVisible = false;
              currentPosition = WL.Robot.Position;

            end
          end

          if WL.movement_finished()
            WL.cfg.movementDurationTime = WL.Timer.MovementDurationTimer.GetTime();
            if (~(strcmp(WL.Trial.block_name, 'FastJumps')) && ~(strcmp(WL.Trial.block_name,'SlowJumps')))
              WL.generate_feedback();  % This will store feedback message and color
            else
              WL.cfg.CursorVisible = false;

            end
            if ~WL.cfg.isPracticeTrial
              WL.check_speed_error();  % Call the error check function for actual trials
            end
            if ~WL.cfg.hasPlayedFourthBeep
              currentSpeedCue = WL.Trial.SpeedCue;  % Get the current trial's speed

              % Play the 4th beep based on whether the trial is fast or slow
              if strcmp(currentSpeedCue, 'fast')
                WL.play_sound(WL.cfg.fastfourthbeep);  % Play 4th beep for fast trials
                WL.cfg.hasPlayedFourthBeep = true;
              elseif strcmp(currentSpeedCue, 'slow')
                WL.play_sound(WL.cfg.slowfourthbeep);  % Play 4th beep for slow trials
                WL.cfg.hasPlayedFourthBeep = true;
              end
            end
            if ~WL.cfg.isPracticeTrial
              WL.check_speed_error();  % Call the error check function for actual trials
            end
            WL.cfg.TargetVisible = false;
            WL.cfg.CursorVisible = false;
            WL.Trial.MovementDurationTime = WL.Timer.MovementDurationTimer.GetTime;

            WL.state_next(WL.State.FINISH);
          end

        case WL.State.FINISH
          WL.cfg.hasJumped = false;
          ok = WL.Robot.RampDown();
          finalPosition = WL.Robot.Position;  % Get final position
          targetPosition = WL.Trial.TargetPosition;  % Get target position
          movementDuration = WL.Timer.MovementDurationTimer.GetTime();
          WL.Trial.MovementDurationTime = movementDuration;



          if WL.State.FirstFlag
            fprintf(1, 'TrialStop\n');
            WL.trial_stop();
          end

          WL.State.FirstFlag = false;

          if   WL.State.Timer.GetTime > WL.cfg.FinishDelay %&& WL.cfg.explosion1.ExplodeState ~= WL.cfg.explosion1.EXPLODE_POPPING  % Trial has finished so stop trial.
            WL.Timer.Paradigm.InterTrialDelayTimer.Reset;

            if  ~WL.trial_save()
              WL.printf('Cannot save Trial %d.\n',WL.TrialNumber);
              %disp('FINISH to exit');
              WL.state_next(WL.State.EXIT);
            else
              WL.printf('Saved Trial %d.\n',WL.TrialNumber);
              [ok, WL.var.data, names] = WL.Hardware.DataGet(); %get frame data
              WL.var.data=WL.var.data{1};
              WL.var.data.TrialData = WL.TrialData(WL.TrialNumber,:);
              if  rem(WL.TrialNumber,2)==1

              end

              WL.state_next(WL.State.NEXT);

            end
          end
       case WL.State.NEXT
    if WL.Trial.RestFlag == 1
        WL.state_next(WL.State.REST);
    elseif ~WL.trial_next()
        WL.state_next(WL.State.EXIT);
    else
        % Set breaks at specific trial numbers
        
        if WL.TrialNumber == 27 || WL.TrialNumber == 287 || WL.TrialNumber == 410 || WL.TrialNumber == 547
            WL.Trial.RestFlag = 1;
            WL.state_next(WL.State.REST);
        else
            WL.state_next(WL.State.INTERTRIAL);
        end
    end
        case WL.State.REST

          % Wait for key press to continue
          if KbCheck
            WaitSecs(0.1);  % Debounce delay to avoid detecting multiple presses
            WL.Trial.RestFlag = 0;  % Reset the rest flag
            WL.state_next(WL.State.NEXT);  % Move to the next state after the break
          end

        case WL.State.INTERTRIAL % Wait for the intertrial delay to expire.
          if WL. Timer.Paradigm.InterTrialDelayTimer.GetTime > WL.cfg.InterTrialDelay
            %disp('INTERTRIAL TO SETUP');
            WL.state_next(WL.State.SETUP);
          end

        case WL.State.EXIT
          WL.cfg.ExperimentSeconds = WL.Timer.Paradigm.ExperimentTimer.GetTime;
          WL.cfg.ExperimentMinutes = WL.cfg.ExperimentSeconds / 60.0;
          WL.printf('Game Over (%.1f minutes)',WL.cfg.ExperimentMinutes);
          WL.cfg.ExitFlag = true;
          TrialDataList = WL.TrialData;
          save('TrialDataList.mat', 'TrialDataList');

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
            %disp('REST TO NEXT');
            WL.state_next(WL.State.NEXT);
          end
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function trial_start_func(WL)
      WL.Trial.TargetPosition = WL.cfg.TargetPosition;

      ok = WL.Robot.RampUp();

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function miss_trial_func(WL,MissTrialType)
      ok = WL.Robot.RampDown();
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
      flag = WL.Robot.Position(2) >= 9 && ~WL.cfg.hasPlayedFourthBeep && currentVelocity < WL.cfg.VelocityThreshold ;
      % WL.cfg.TargetPosition(2)

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function out = movement_started(WL)
      out = ~WL.robot_home();
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function keyboard_func(WL,keyname)  end
    function flip_func(WL)      end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function generate_feedback(WL)
      
        % Ensure straightforward movement for practice trials
        WL.cfg.CursorVisible = true;     % Make sure cursor is visible
        WL.cfg.hasJumped = false;        % Disable jumps during practice trials
        WL.cfg.isTargetShifted = false;  % No target shift during practice trials

        % Speed Feedback Logic
        currentSpeedCue = WL.TrialData.SpeedCue{WL.TrialNumber};  % Get the current trial's speed cue
        if strcmp(currentSpeedCue, 'fast')
          targetDuration = WL.cfg.targetDurationFast;  % Set target duration for fast trials
        else
          targetDuration = WL.cfg.targetDurationSlow;  % Set target duration for slow trials
        end
        disp(['Target Duration: ', num2str(targetDuration)]);  % Debug statement

        % Compare movement duration against the target duration
        movementDuration = WL.cfg.movementDurationTime;


        % Feedback logic
        if movementDuration < (targetDuration - WL.cfg.tolerance)
          WL.cfg.feedbackMessage = 'Too Fast!';
        elseif movementDuration > (targetDuration + WL.cfg.tolerance)
          WL.cfg.feedbackMessage = 'Too Slow!';
        else
          WL.cfg.feedbackMessage = 'Correct Speed!';
        end

        % Reset the feedback timer
        WL.Timer.FeedbackTimer.Reset();
    end

   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function flag = reaches_jump_point(WL)
      % Define the fixed distance for the jump
      fixed_distance = 4;

      % Calculate the y-axis distance from the cursor's position to the home position
      current_distance_y = WL.cfg.CursorPosition(2) - WL.cfg.HomePosition(2);

      % Check if the cursor has reached or surpassed the fixed distance along the y-axis
      flag = current_distance_y >= fixed_distance;

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function WL = random_target_shift(WL)
      % Randomize left or right target position
      shiftDistance = 5; % cm shift left or right
      if rand < 0.5
        shiftDistance = -shiftDistance; % Shift left if condition is met
      end
      if WL.Robot.Position(2) < 0
        WL.cfg.CursorVisible = true;
        WL.cfg.TargetVisible = true;
      end

      % Update target position with the shift
      WL.cfg.TargetPosition = WL.cfg.HomePosition + [shiftDistance; WL.cfg.TargetDistance; 0];

      % Debug log (optional)
      disp(['Target shifted to new position: ', mat2str(WL.cfg.TargetPosition)]);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function WL = reset_target_position(WL)
      WL.cfg.TargetPosition = WL.cfg.HomePosition + [0; WL.cfg.TargetDistance; 0];
      WL.cfg.isTargetShifted = false;
    end
    % Method to check for speed errors
    function check_speed_error(WL)
      % Speed Feedback Logic for actual trials
      currentSpeedCue = WL.TrialData.SpeedCue{WL.TrialNumber};  % Get the current trial's speed cue
      movementDuration = WL.cfg.movementDurationTime;

      % Define custom error conditions
      if strcmp(currentSpeedCue, 'fast')
        if movementDuration > 1  % Faster threshold for fast movements
          WL.cfg.errorMessage = 'Move Faster!';
        else
          WL.cfg.errorMessage = '';  % Clear error message if conditions are met
        end
      elseif strcmp(currentSpeedCue, 'slow')
        if movementDuration < 1.1  % Slower threshold for slow movements
          WL.cfg.errorMessage = 'Move Slower!';
        else
          WL.cfg.errorMessage = '';  % Clear error message if conditions are met
        end
      end

      % Start the error display timer
      if ~isempty(WL.cfg.errorMessage)
        WL.Timer.ErrorDisplayTimer.Reset();
      end
    end

  end
end
