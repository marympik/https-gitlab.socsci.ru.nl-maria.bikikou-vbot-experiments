function JumpCursors_cfg(WL,~)

assignin('base','MHF_FieldFuncPath','.\')

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
    WL.cfg.Debug =0;

WL.cfg.CursorRadius = 0.5;
WL.cfg.HomeRadius = 0.75;
WL.cfg.TargetRadius = 0.75;

WL.cfg.StationarySpeed = 5;
WL.cfg.StationaryTime = 0.1;

WL.cfg.MovementReactionTimeOut = 10.0;
WL.cfg.MovementDurationTimeOut =	50.0;
WL.cfg.InterTrialDelay = 0;
WL.cfg.RestBreakSeconds = 45;
WL.cfg.TrialDelay = 0;
WL.cfg.FinishDelay = 0.1;
WL.cfg.ErrorWait = 1.5;

WL.cfg.TargetDistance = 20;
WL.cfg.HomePosition = [ 0 -7 0 ]';
WL.cfg.TargetPosition = WL.cfg.HomePosition + [ 0 WL.cfg.TargetDistance 0 ]';
% Define the possible jump distances in meters
WL.cfg.possibleJumpDistances = [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6];  % Possible jump distances
% Add this line to your configuration file to make the velocity threshold configurable
WL.cfg.VelocityThreshold = 1;  % Set the velocity threshold to 0.01 m/s




% Fast beeps (0.2 seconds interval)
WL.cfg.highbeep = WL.load_beeps([1000 0 1000 0 1000], [0.05 0.3 0.05 0.3 0.05]);
WL.cfg.fastfourthbeep = WL.load_beeps(1200, 0.05);  % 4th beep for fast trials

% Faster slow beeps (0.4 seconds interval instead of 0.5)
WL.cfg.slowbeep = WL.load_beeps([250 0 250 0 250], [0.2 0.5 0.2 0.5 0.2]);
WL.cfg.slowfourthbeep = WL.load_beeps(300, 0.2);  % 4th beep for slow trials


WL.cfg.plot_timing = 0;

% The over-ride goes here to copy 'GW' variables set by the GUI/defaults to 'cfg'.
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
%%
% Create blocks based on the indices above
% P sub-structure are variables that can change with each trial
% I sub-structure are variables that do not change within a block
%% New Section: Creating Trials with Speeds and Jumps
jumps = WL.cfg.possibleJumpDistances;  % Array of 13 jumps
speeds = {'slow', 'fast'};  % Two possible speeds
nPerCondition = 20;  % Number of repetitions per condition

% Calculate the total number of trials
nTrials = numel(jumps) * numel(speeds) * nPerCondition;

% Generate the pools of jumps and speeds
jumpsPool = repmat(jumps, 1, numel(speeds) * nPerCondition);  % Repeat jumps
speedsPool = repelem(speeds, numel(jumps) * nPerCondition);   % Repeat speeds for each jump

% Randomize the trials
jumpsPermuted = jumpsPool(randperm(nTrials));
speedsPermuted = speedsPool(randperm(nTrials));

% Create the trial table directly
T = table(jumpsPermuted', speedsPermuted', 'VariableNames', {'JumpDistance', 'SpeedCue'});

% Add additional fields like ReturnFlag, etc.
T.ReturnFlag = zeros(nTrials, 1);  % Assuming no return flag is needed (all zeros)
T.MovementReactionTime = nan(nTrials, 1);  % Initialize movement reaction time
T.MovementDurationTime = nan(nTrials, 1);  % Initialize movement duration time

% No need to manually add EOT

% Assign the generated trial data to WL.TrialData
WL.TrialData = T;

% Debug: Display the total number of trials
disp(['Total number of trials: ', num2str(height(WL.TrialData))]);

end