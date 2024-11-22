function JumpCursors_cfg(WL, participantNumber)

assignin('base','MHF_FieldFuncPath','.\')


WL.cfg.participantNumber = participantNumber;

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

% % settings for the photodiode
WL.cfg.SensorayAddress = -1;
WL.cfg.SensorayAnalogChannels = 0:9; % 0-5 is force transducer, 6 is photodiode
WL.cfg.PhotoDiodePosition = [27.3, 14.3, 0]; % Maria and Luc checked this position and radius, such that it is underneath the photodiode with the Asus screen
WL.cfg.PhotoDiodeRadius = 1;

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
WL.cfg.HomePosition = [0 -10 0]';
WL.cfg.TargetPosition = WL.cfg.HomePosition + [0; WL.cfg.TargetDistance; 0];  % Center target (20 cm above home position)




% During extra trials, the cursor should always be visible, and no target shift occurs
WL.cfg.CursorVisibleExtraTrials = true;  % Set cursor visibility for extra trials
WL.cfg.isTargetShiftedExtraTrials = false;  % No target shifts in extra trials



WL.cfg.isPracticeTrial = false;

% Define the possible jump distances in meters
WL.cfg.possibleJumpDistances = [-6,-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6];
WL.cfg.VelocityThreshold = 2;

WL.cfg.plot_timing = 0;

% Fast beeps (0.2 seconds interval)
WL.cfg.lowbeep   = WL.load_beeps([250 150],[0.5 0.5]);
WL.cfg.highbeep = WL.load_beeps(1000, 0.05);
WL.cfg.fastfourthbeep = WL.load_beeps(1200, 0.05);  % 4th beep for fast trials

% Faster slow beeps (0.4 seconds interval instead of 0.5)
WL.cfg.slowbeep = WL.load_beeps(250, 0.3);
WL.cfg.slowfourthbeep = WL.load_beeps(300, 0.2);  % 4th beep for slow trials

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% JumpDistances.

% JumpDistances.

JumpDistanceCount = 13;
RepetitionCount = 12;
JumpDistance = num2cell([WL.cfg.possibleJumpDistances]); %  Targets evenly spaced around a circle.
MovementSpeed = num2cell([{'slow'},{'fast'}]);
WL.cfg.JumpDistance = JumpDistance;
WL.cfg.SpeedCue = MovementSpeed;


PractiseFast.Trial.Index.JumpDistance = [7*ones(1,JumpDistanceCount)];
PractiseFast.Trial.Index.SpeedCue = [2*ones(1,JumpDistanceCount)];
PractiseFast.Permute = false;

PractiseSlow.Trial.Index.JumpDistance = [7*ones(1,JumpDistanceCount)];
PractiseSlow.Trial.Index.SpeedCue = [ones(1,JumpDistanceCount)];
PractiseSlow.Permute = false;


SlowJumps.Trial.Index.JumpDistance = [ 1:JumpDistanceCount ];
SlowJumps.Trial.Index.SpeedCue = [ones(1,JumpDistanceCount)];
SlowJumps.Permute = true;


FastJumps.Trial.Index.JumpDistance =  1:JumpDistanceCount ;
FastJumps.Trial.Index.SpeedCue = 2*ones(1,JumpDistanceCount);
FastJumps.Permute = true;



SlowFullVis.Trial.Index.JumpDistance = 1:JumpDistanceCount;
SlowFullVis.Trial.Index.SpeedCue = [ones(1,JumpDistanceCount)];
SlowFullVis.permute = true;

FastFullVis.Trial.Index.JumpDistance = 1:JumpDistanceCount;
FastFullVis.Trial.Index.SpeedCue = [2*ones(1,JumpDistanceCount)];
FastFullVis.Permute = true;

Sprac = WL.parse_trials(PractiseSlow);
Fprac = WL.parse_trials(PractiseFast);

S = WL.parse_trials(SlowJumps);
F = WL.parse_trials(FastJumps);

Svis = WL.parse_trials(SlowFullVis);

Fvis = WL.parse_trials(FastFullVis);


if mod(participantNumber, 2) == 1
    T = parse_tree(Sprac + Fprac + RepetitionCount*S + RepetitionCount*F + Svis + Fvis);
else
    T = parse_tree(Fprac + Sprac +RepetitionCount*F + RepetitionCount*S + Fvis + Svis);
end

WL.TrialData = T;

totalTrialCount = height(WL.TrialData);

% Calculate the number of target shifts (10% of trials)
targetShiftCount = round(totalTrialCount * 0.1);

% Split the target shifts evenly between slow and fast trials
targetShiftSlowCount = round(targetShiftCount / 2);
targetShiftFastCount = targetShiftCount - targetShiftSlowCount;

% Identify slow and fast trials
slowTrials = find(strcmp(WL.TrialData.SpeedCue, 'slow'));
fastTrials = find(strcmp(WL.TrialData.SpeedCue, 'fast'));

% Randomly select slow and fast trials to apply target shifts
shiftedSlowTrials = slowTrials(randperm(length(slowTrials), targetShiftSlowCount));
shiftedFastTrials = fastTrials(randperm(length(fastTrials), targetShiftFastCount));

% Combine the indices for the shifted trials
shiftedTrials = [shiftedSlowTrials; shiftedFastTrials];

% Store these indices for later use
WL.Trial.shiftedTrials = shiftedTrials; % Assign the shifted trials to WL.Trial
WL.cfg.shiftedTrials = shiftedTrials;    % Assign the shifted trials to WL.cfg

% Initialize MovementDurationTime for all trials
WL.Trial.MovementDurationTime = nan(totalTrialCount, 1);

disp(['Total number of trials: ', num2str(height(WL.TrialData))]);
end
