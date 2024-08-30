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

    % Assign a random jump distance to each trial
    %possibleJumpDistances(randi(length(possibleJumpDistances)));
    for i = 1:height(WL.TrialData)
        % Randomly select a jump distance from the possible distances
        WL.TrialData.JumpDistance(i) = 5;
    end

            for i=1:3
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
            WL.cfg.JumpTimer = 0;
            WL.Timer.CursorVisibilityTimer = wl_timer;
            WL.cfg.CursorVisibilityDuration = 0.1;
            % Initialize the target position relative to the home position
            WL.cfg.targetPosition = WL.cfg.HomePosition;
            WL.cfg.targetPosition(2) = WL.cfg.targetPosition(2) + WL.cfg.TargetDistance;  % Moving 20 units along y-axis



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
    WL.draw_text(txt, [0 0 0]);

    % Always draw the home position
    wl_draw_sphere(WL.cfg.HomePosition + [0 0 -2]', WL.cfg.HomeRadius, [0 1 1], 'Alpha', 0.7);

    %Always draw the target position
     if WL.cfg.explosion1.ExplodeState ~= WL.cfg.explosion1.EXPLODE_POPPING
       wl_draw_sphere(WL.Trial.TargetPosition + [0 0 -2]', WL.cfg.TargetRadius, [1 1 0], 'Alpha', 0.7);
    end
     if WL.cfg.hasJumped % WL.State.MOVEWAIT, WL.State.MOVING, WL.State.CURSORJUMP])
             WL.cfg.CursorPosition(1) = WL.Robot.Position(1) + 5;
            WL.cfg.CursorVisible = true; % Cursor initially not visible            
     end
  
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


    % Draw the cursor during the HOME, MOVEWAIT, MOVING, and CURSORJUMP states
    if any(WL.State.Current == [WL.State.HOME ,  WL.State.GO  ]) %, WL.State.MOVEWAIT, WL.State.MOVING, WL.State.CURSORJUMP])
       % wl_draw_sphere(WL.cfg.CursorPosition, WL.cfg.CursorRadius, [1 0 0]);
    end

    if WL.cfg.CursorVisible
        % red visible
        wl_draw_sphere(WL.cfg.CursorPosition, WL.cfg.CursorRadius, [1 0 0]);
    else
        % gray invisible
        wl_draw_sphere(WL.cfg.CursorPosition, WL.cfg.CursorRadius, 0.3*[1 1 1]);
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
                        WL.trial_setup();
                        WL.state_next(WL.State.HOME);
                    end

                % SETUP -> RETURN -> HOME ...
                % go from SETUP to RETURN (instead of to HOME)
                % RETURN: if Robot at home, start timer, go to HOME
                % HOME: if Robot not at home, go to RETURN
                %       if timer > time, go to START
                    
                case WL.State.HOME % Start trial when robot in home position (and stationary and active).
                    if WL.Robot.Position(2) < 0
                        WL.cfg.CursorVisible = true;
                    end
                    if (WL.robot_stationary() &&  WL.robot_home() && all(WL.Robot.Active)) || WL.Trial.ReturnFlag
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
                    WL.Timer.MovementReactionTimer.Reset();
                    WL.play_sound(WL.cfg.highbeep);
                    WL.Timer.StimulusTime.Reset();
                    WL.state_next(WL.State.MOVEWAIT);
                    
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
            
             if WL.Timer.CursorVisibilityTimer.GetTime() > 0.1
                 WL.cfg.CursorVisible = false;
             end

            if WL.movement_finished()
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
                switch( WL.Trial.FieldType )
                    case WL.cfg.Field.Null
                        ok = WL.Robot.FieldNull();

                    case  WL.cfg.Field.Curl
                        ViscousMatrix = WL.Trial.FieldConstants(1) * [ 0 -1 0; ...
                            1  0 0; ...
                            0  0 0 ];
                        ok = WL.Robot.FieldViscous(ViscousMatrix);

                    case  WL.cfg.Field.Channel
                     %   ok = WL.Robot.FieldChannel(WL.Trial.TargetPosition,WL.Trial.FieldConstants(1),WL.Trial.FieldConstants(2));

                        ok = WL.Robot.FieldUser('RobotHybridChannel',-30,-0.05,0,WL.Robot.Position(:),WL.cfg.TargetPosition(:),100,0.050,0);

                end
            else
                ok = WL.Robot.FieldPMove(WL.Trial.ReturnTargetPosition,0.5,0.2);
                WL.Robot.PMoveFinished = 0;
            end


        %    WL.printf('TrialStart() Trial=%d, Field=%d\n',WL.TrialNumber,WL.Trial.FieldType);
        %    WL.printf('RobotField=%d, Started=%d\n',WL.Trial.FieldType,ok);
            
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
            flag = WL.Robot.Position(2) >= WL.cfg.TargetPosition(2);
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
            fixed_distance = 10;  % 4 units
        
            % Calculate the y-axis distance from the cursor's position to the home position
            current_distance_y = WL.cfg.CursorPosition(2) - WL.cfg.HomePosition(2);
        
            % Check if the cursor has reached or surpassed the fixed distance along the y-axis
            flag = current_distance_y >= fixed_distance;
        
            disp(flag);
            disp(fixed_distance);
            disp(current_distance_y >= fixed_distance);
        end
    
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = plot_results(WL)
            
            TitleFontSize = 10;
            AxisLabelFontSize = 6;
            
            block=WL.TrialData.block_index;
            Trials=max(WL.TrialData.Trial);
            
            set(0,'DefaultFigureWindowStyle','normal')
            set(0,'DefaultLineMarkerSize',6);
            set(0,'defaultlinelinewidth',3);
            % set(0,'defaultAxesFontSize', 24);
            
            % set(gcf,'Position', [1500 500 1200 1000])
            baseline_color = [235, 255, 216] / 255; % rgb(246, 255, 237)
            exposure_color = [255, 229, 229] / 255; % rgb(255, 244, 244)
            post_exposure_color = [229, 238, 255]  / 255; % rgb(244, 248, 255)
            dx=0.05;
            dy=0.05;
            
            kplot(1)=subplot('Position', [dx 0.5+dy 0.2-dx 0.5-2*dy]);
            cla
            H = title('Baseline');
            set(H,'FontSize',TitleFontSize);
            set(gca,'Color',baseline_color);
            
            kplot(2)=subplot('Position', [dx+0.2 0.5+dy 0.2-dx 0.5-2*dy]);
            cla
            H = title('Exposure');
            set(H,'FontSize',TitleFontSize);
            set(gca,'Color',exposure_color);
            
            kplot(3)=subplot('Position', [dx+0.4 0.5+dy 0.2-dx 0.5-2*dy]);
            cla
            H = title('After-effect');
            set(H,'FontSize',TitleFontSize);
            set(gca,'Color',post_exposure_color);
            box on
            
            f1=subplot('Position', [dx  0+dy 0.3-dx 0.5-2*dy]);
            %cla
            hold on
            %plot(WL.cfg.HomePosition(1),WL.cfg.HomePosition(2),'ko','MarkerSize',20)
           % wl_draw_sphere(WL.cfg.HomePosition', WL.cfg.HomeRadius,[ 0 1 1 ]);
            
            %plot( WL.cfg.TargetPosition(1),WL.cfg.TargetPosition(2),'ko','MarkerSize',20)
            %wl_draw_sphere(WL.cfg.TargetPosition, WL.cfg.TargetRadius,[ 1 1 0 ]);
            
            axis([-12 12 WL.cfg.HomePosition(2)-4 WL.cfg.TargetPosition(2)+4]);
            H = title('Perturbing Forces (Robot)');
            set(H,'FontSize',TitleFontSize);
            box on
            set(gca,'XTick',[])
            set(gca,'YTick',[])
            %
            f2=subplot('Position', [dx+0.30 0+dy 0.3-dx 0.5-2*dy]);
            %cla
            hold on
            %plot(WL.cfg.HomePosition(1),WL.cfg.HomePosition(2),'ko','MarkerSize',20)
            %wl_draw_sphere(WL.cfg.HomePosition, WL.cfg.HomeRadius,[ 0 1 1 ]);
            
            %plot( WL.cfg.TargetPosition(1),WL.cfg.TargetPosition(2),'ko','MarkerSize',20)
            %wl_draw_sphere(WL.cfg.TargetPosition, WL.cfg.TargetRadius,[ 1 1 0 ]);
            
            
            axis([-12 12 WL.cfg.HomePosition(2)-4 WL.cfg.TargetPosition(2)+4]);
            H = title('Compensatory Forces (Human)');
            set(H,'FontSize',TitleFontSize);
            box on
            set(gca,'XTick',[])
            set(gca,'YTick',[])
            
            %plot_handles = [ kplot f1 f2 ];
            plot_handles =  kplot ;
            for i=1:length(plot_handles)
                subplot(plot_handles(i));
                light;
                light;
                light;
                light;
            end
            
            %aerr=subplot('Position', [dx+0.6 0+dy 0.4-2*dx 0.5-2*dy]);
            aerr=subplot('Position', [dx+0.6 0.01+dy 0.4-2*dx 0.49-2.0*dy]);
            set(aerr,'FontSize',AxisLabelFontSize);
            set(gcf, 'Renderer', 'OpenGL');
            set(aerr,'YTick',[ 0 50 100 ]);
            
            %kerr=subplot('Position', [dx+0.6 0.5+dy 0.4-2*dx 0.5-2*dy]);
            kerr=subplot('Position', [dx+0.6 0.51+dy 0.4-2*dx 0.49-2*dy]);
            set(kerr,'FontSize',AxisLabelFontSize);
            %set(gcf, 'Renderer', 'zbuffer');
            
            for k=1:3
                subplot(kplot(k))
                hold on
                
                %plot(WL.cfg.HomePosition(1),WL.cfg.HomePosition(2),'ko','MarkerSize',20)
            %wl_draw_sphere(WL.cfg.HomePosition, WL.cfg.HomeRadius,[ 0 1 1 ]);
                
                %plot(WL.cfg.TargetPosition(1),WL.cfg.TargetPosition(2),'ko','MarkerSize',20)
            %wl_draw_sphere(WL.cfg.TargetPosition, WL.cfg.TargetRadius,[ 1 1 0 ]);
                
                box on
                set(gca,'XTick',[])
                set(gca,'YTick',[])
                
            end
            
            for k=1:3
                subplot(kplot(k))
                axis([-8 8 WL.cfg.HomePosition(2)-4 WL.cfg.TargetPosition(2)+4])
            end
            
            subplot(kerr)
            hold on
            
            axis([0.5 Trials+0.5 -0.5 10])
            a=axis;
            t1=WL.TrialData.Trial(find(block==2,1));
            t2=WL.TrialData.Trial(find(block==2,1,'last'));
            patch([ a(1) t1-0.5 t1-0.5 a(1) ],[a(3) a(3) a(4) a(4)],baseline_color,'LineStyle','none')
            patch([t1-0.5 t2+0.5 t2+0.5 t1-0.5],[a(3) a(3) a(4) a(4)],exposure_color,'LineStyle','none')
            patch([ t2+0.5 a(2) a(2) t2+0.5 ],[a(3) a(3) a(4) a(4)],post_exposure_color,'LineStyle','none')
            ylabel('Error(cm)')
            xlabel('Trial')
            H = title('Deviation from target');
            set(H,'FontSize',TitleFontSize);
            
            box off
            axis([0.5 Trials+0.5 -0.5 10]);
            
            subplot(aerr)
            hold on
            axis([0.5 Trials+0.5 -5 120 ])
            a=axis;
            patch([ a(1) t1-0.5 t1-0.5 a(1) ],[a(3) a(3) a(4) a(4)],baseline_color,'LineStyle','none')
            patch([t1-0.5 t2+0.5 t2+0.5 t1-0.5],[a(3) a(3) a(4) a(4)],exposure_color,'LineStyle','none')
            patch([ t2+0.5 a(2) a(2) t2+0.5 ],[a(3) a(3) a(4) a(4)],post_exposure_color,'LineStyle','none')
            xlabel('Trial')
            ylabel('Adaptation (%)')
            H = title('Force Compensation');
            set(H,'FontSize',TitleFontSize);
            box off
            
            axis([0.5 Trials+0.5 -5 120 ])
            
            a = axis;
            
            H = plot([ a(1) a(2) ],[ 0 0 ],'k:');
            set(H,'LineWidth',1.0);
            
            H = plot([ a(1) a(2) ],[ 100 100 ],'k:');
            set(H,'LineWidth',1.0);
            
            
            if WL.TrialNumber == 0
                %plot_handles = [ kplot f1 f2 ];
                plot_handles = [ f1 f2 ];
                for i=1:length(plot_handles)
                    subplot(plot_handles(i));
                    light;
                    light;
                    light;
                    light;
                end               
                
                
                set(fig, 'MenuBar', 'none');
                set(fig, 'ToolBar', 'none');
                set(fig, 'Name', 'Wolpert Lab', 'NumberTitle', 'off')
                display_fig(fig,2,'full');
                pause(0.001);
                shg
                return;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                Data dependant functions                     %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            FieldConstant = -WL.cfg.Fields{2}.FieldConstants(1);
            
            trial=(WL.TrialNumber+1)/2;
            f=WL.var.data.Samples;
            
            if ~WL.cfg.MouseFlag
                x= WL.var.data.RobotPosition(1,1:f)';
                y= WL.var.data.RobotPosition(2,1:f)';
                fx=WL.var.data.RobotForces(1,1:f)';
                fy=WL.var.data.RobotForces(2,1:f)';
                vx=WL.var.data.RobotVelocity(1,1:f)';
                vy=WL.var.data.RobotVelocity(2,1:f)';
            else
                x= WL.var.data.Position(1:f,1);
                y= WL.var.data.Position(1:f,2);
                fx=0*x;
                fy=0*y;
                vx=WL.var.data.Velocity(1:f,1);
                vy=WL.var.data.Velocity(1:f,2);
            end
            
            speed=sqrt(vx.^2+vy.^2);
            dist1=(x-WL.cfg.HomePosition(1)).^2+(y-WL.cfg.HomePosition(2)).^2;
            dist2=(x-WL.cfg.TargetPosition(1)).^2+(y-WL.cfg.TargetPosition(2)).^2;
            
            ind1=find(dist1>1.25^2,1);
            ind2=find(dist2<1.25^2,1);
            
            if( length(ind1) == 0 )
                ind1 = 1;
            end
            
            if( length(ind2) == 0 )
                ind2 = f;
            end
            
            extract_segments= @(x,ind1,ind2) x(ind1:ind2);
            
            xc =  extract_segments(x,ind1,ind2);
            yc =  extract_segments(y,ind1,ind2);
            vxc =  extract_segments(vx,ind1,ind2);
            vyc =  extract_segments(vy,ind1,ind2);
            fxc =  extract_segments(fx,ind1,ind2);
            fyc =  extract_segments(fy,ind1,ind2);
            
            WL.var.xc = xc;
            WL.var.yc = yc;
            WL.var.vxc = vxc;
            WL.var.vyc = vyc;
            WL.var.fxc = fxc;
            WL.var.fyc = fyc;
            
            
            if WL.cfg.MouseFlag
                yc = -yc;
                y = -y;
            end
            
            u=eps:eps:length(yc)*eps;
            
            %path length
            pl=cumsum([0 ;abs(diff(yc))]); % Integrating velocity
            pl=pl./max(pl); %  Normalizing path legnth
            pl=pl+u';  % jitter
            
            %interpolation locations
            yp=linspace(0.01,0.99,100)';
            
            xi=interp1(pl,xc,yp);
            veli=interp1(pl,vyc,yp);
            fxi=interp1(pl,fxc,yp);
            mfx=mean(fxi);
            mvel=mean(veli);
            
            pfx=FieldConstant*veli;
            uadapt=sum(fxi.*pfx)./sum(pfx.*pfx); %slop poly 0
            
            adapt=uadapt; %slop poly 0
            
            %adapt2=(1/FieldConstant)*(mfx./mvel);
            
            
            %mpe=-min(xc);
            mpe = max(abs(xc));
            
            %             [ vmax,vmaxi ] = max(vy);
            %             fmax_predict = FieldConstant * vmax;
            %             fmax_vmax = fx(vmaxi);
            %             adapt = fmax_vmax / fmax_predict;
            adapt = max([ 0 adapt ]);
            
            WL.var.block_index{trial}= WL.Trial.block_index;
            WL.var.X{trial}=x;
            WL.var.Y{trial}=y;
            WL.var.fx=fx;
            WL.var.fy=fy;
            WL.var.mpe(trial)=mpe;
            WL.var.adapt(trial)=100*adapt;
            WL.var.channel(trial)= WL.Trial.FieldType==WL.cfg.Field.Channel;
            
            channel=WL.var.channel;
            T=1:trial;
            
            trial_count = WL.cfg.PhaseTrialCount;
            %for k=(trial-1):-1:1
            for k=1:(trial-1)
                if ~channel(k)
                    
                    bi = WL.var.block_index{k};
                    trial_count(bi) = trial_count(bi) - 1;
                    trial_max = WL.cfg.PhaseTrialCount(bi);
                    
                    subplot(kplot(WL.var.block_index{k}));
                    %plot( WL.cfg.X{k},WL.cfg.Y{k},'Color',[ 0.9 0.9 0.9] * (trial_max-trial_count(bi)) / trial_max);%trial_count(bi) / trial_max);
                    plot( WL.var.X{k},WL.var.Y{k},'Color',[ 0.9 0.9 0.9] * (trial_count(bi) / trial_max));%trial_count(bi) / trial_max);
                    %WL.cfg.cmap(k- (trial-1) + 41,:))
                end
            end
            
            if ~channel(trial)
                subplot(kplot(WL.var.block_index{trial}));
                plot( WL.var.X{trial},WL.var.Y{trial},'r')
            end
            
            
            
            subplot(kerr)
            plot(T(~channel),WL.var.mpe(~channel),'ko-','MarkerFaceColor','k')
            if ~channel(end)
                plot(trial,WL.var.mpe(end),'ro-','MarkerFaceColor','r')
            end
                        
            subplot(aerr)
            plot(T(channel),WL.var.adapt(channel),'ko-','MarkerFaceColor','k')
            
            if channel(end)
                plot(trial,WL.var.adapt(end),'ro-','MarkerFaceColor','r')
            end
                        
            if channel(trial)
                subplot(f2)
                force_sign = -1;
                color = 'g';
            else
                subplot(f1)
                force_sign = 1;
                color = 'b';
            end
            
            plot_path_field(WL,10, color, force_sign);
            
            pause(0.0001);
            shg
            
        end
    end
    
end
