function JumpCursors_cfg(WL, participantNumber)

    assignin('base','MHF_FieldFuncPath','.\')


    WL.cfg.participantNumber = participantNumber;  
    WL.cfg.save_file = fullfile('C:\Wolpert\Shared\matlab\WL_core\v2_1', sprintf('Participant_%d_Data.mat', participantNumber));

    % Participant-specific logic for block order
    if mod(participantNumber, 2) == 1
        % Odd-numbered participants: fast block first
        WL.cfg.BlockOrder = {'fast', 'slow'};
    else
        % Even-numbered participants: slow block first
        WL.cfg.BlockOrder = {'slow', 'fast'};
    end



    WL.cfg.MouseFlag = false;
    WL.cfg.vol = 0.3;

    if ismac
        WL.cfg.MouseFlag = 1;
        WL.cfg.SmallScreen=1;
        WL.cfg.SmallScreenScale=0.3;
        WL.cfg.MonitorView=0;
        WL.cfg.OrthoView=true;
        WL.cfg.Debug =0;
        WL.cfg.vol = 0;
    end
    
    WL.cfg.Debug = 0;
    WL.cfg.CursorRadius = 0.5;
    WL.cfg.HomeRadius = 0.75;
    WL.cfg.TargetRadius = 0.75;
    WL.cfg.StationarySpeed = 5;
    WL.cfg.StationaryTime = 0.1;
    WL.cfg.MovementReactionTimeOut = 10.0;
    WL.cfg.MovementDurationTimeOut = 50.0;
    WL.cfg.InterTrialDelay = 0;
    WL.cfg.RestBreakSeconds = 45;
    WL.cfg.TrialDelay = 0;
    WL.cfg.FinishDelay = 0.1;
    WL.cfg.ErrorWait = 1.5;
    WL.cfg.TargetDistance = 20;
    WL.cfg.HomePosition = [0 -7 0]';
    WL.cfg.TargetPosition = WL.cfg.HomePosition + [0 WL.cfg.TargetDistance 0]';
    WL.cfg.isPracticeTrial = true;

    % Define the possible jump distances in meters
    WL.cfg.possibleJumpDistances = [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6]; 
    WL.cfg.VelocityThreshold = 1;

     WL.cfg.plot_timing = 0;

    WL.overide_cfg_defaults();


if ~isfield(WL.cfg, 'graphics_config')
    % wl_cfg_rig: if ComputerName has no match, hardcoded there
    % wl_start_screen: else read here via MexReadConfig('GRAPHICS')
    % but the latter does not work yet (2024-08) so hardcoding here

    % running in lab: ComputerName has a match but MexReadConfig
    % does not work yet, so hardcoding here

    % running on robot (set according to screen specs)
    if ~WL.cfg.MouseFlag
        % https://www.displayspecifications.com/en/model/446a828
        dispWidth  = 59.7888;
        dispHeight = 33.6312;
        WL.cfg.graphics_config.Xmin_Xmax = [ -1  1 ] * dispWidth /2;
        WL.cfg.graphics_config.Ymin_Ymax = [  1 -1 ] * dispHeight/2;
    else
        % running sim in lab (set same as in wl_cfg_rig)
        WL.cfg.graphics_config.Xmin_Xmax = [ -1  1 ] * 30;
        WL.cfg.graphics_config.Ymin_Ymax = [ -1  1 ] * 15;
    end
end

%%
% Null field.
Fields{1}.FieldType = 0;
Fields{1}.FieldName = 'Null';
Fields{1}.FieldConstants	= [0 0];
Fields{1}.FieldAngle	= 0.0;
Fields{1}.FieldMartrix = eye(3);



% This assigns to cfg to make easy in experiment
for k=1:length(Fields)
    WL.cfg.Field.(Fields{k}.FieldName) = Fields{k}.FieldType ;
end


TargetAngle = {pi/2.0};
% 
WL.cfg.Fields = Fields;
WL.cfg.TargetAngle = TargetAngle;


    % Fast beeps (0.2 seconds interval)
    WL.cfg.highbeep = WL.load_beeps([1000 0 1000 0 1000], [0.05 0.3 0.05 0.3 0.05]);
    WL.cfg.fastfourthbeep = WL.load_beeps(1200, 0.05);  % 4th beep for fast trials

    % Faster slow beeps (0.4 seconds interval instead of 0.5)
    WL.cfg.slowbeep = WL.load_beeps([250 0 250 0 250], [0.2 0.5 0.2 0.5 0.2]);
    WL.cfg.slowfourthbeep = WL.load_beeps(300, 0.2);  % 4th beep for slow trials


    % Create blocks with fast and slow movements
    jumps = WL.cfg.possibleJumpDistances;
    nPerCondition = 20;  % Number of repetitions per condition

    % Slow block
    slowSpeeds = repmat({'slow'}, numel(jumps) * nPerCondition, 1);
    slowJumps = repmat(jumps', nPerCondition, 1);

    % Fast block
    fastSpeeds = repmat({'fast'}, numel(jumps) * nPerCondition, 1);
    fastJumps = repmat(jumps', nPerCondition, 1);

    % Randomize within each block
    slowIdx = randperm(numel(slowJumps));
    fastIdx = randperm(numel(fastJumps));

    slowBlock = table(slowJumps(slowIdx), slowSpeeds(slowIdx), 'VariableNames', {'JumpDistance', 'SpeedCue'});
    fastBlock = table(fastJumps(fastIdx), fastSpeeds(fastIdx), 'VariableNames', {'JumpDistance', 'SpeedCue'});

    % Alternate between participants: odd -> fast first, even -> slow first
    if mod(participantNumber, 2) == 1
        WL.TrialData = [fastBlock; slowBlock];  % Fast block first
    else
        WL.TrialData = [slowBlock; fastBlock];  % Slow block first
    end

    % Add other necessary fields
    WL.TrialData.ReturnFlag = zeros(height(WL.TrialData), 1);  
    WL.TrialData.MovementReactionTime = nan(height(WL.TrialData), 1);
    WL.TrialData.MovementDurationTime = nan(height(WL.TrialData), 1);

    disp(['Total number of trials: ', num2str(height(WL.TrialData))]);
end