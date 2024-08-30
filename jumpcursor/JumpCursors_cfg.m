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

% WL.cfg.RobotForceMax = 40;
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

%WL.cfg.rnum = 7;
%rng(WL.cfg.rnum);

% Load beeps for speed cues
WL.cfg.fastBeep = WL.load_beeps(1000, 0.1);  % Higher pitch for fast trials
WL.cfg.slowBeep = WL.load_beeps(250, 0.1);   % Lower pitch for slow trials

% Set target times for fast and slow trials
WL.cfg.FastTargetTime = 1.0;  % 1 second for fast trials
WL.cfg.SlowTargetTime = 3.0;  % 3 seconds for slow trials

WL.cfg.highbeep  = WL.load_beeps(500,0.05);
WL.cfg.lowbeep   = WL.load_beeps([250 150],[0.5 0.5]);
WL.cfg.threebeep = WL.load_beeps([600 0 700 0 800 0 800],[0.05 0.95 0.05 0.95 0.05 0.05 0.05 ]);
WL.cfg.explosion = WL.load_audio('Correct.wav');


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

% Viscous curl field
Fields{2}.FieldType = 1;
Fields{2}.FieldName = 'Curl';
Fields{2}.FieldConstants	= [0.2 0];
Fields{2}.FieldAngle	= 90.0;
Fields{2}.FieldMartrix = eye(3);

% Channel trial
Fields{3}.FieldType = 2;
Fields{3}.FieldName = 'Channel';
Fields{3}.FieldConstants	= [-30.000  -0.05];
Fields{3}.FieldAngle	= 0.0;
Fields{3}.FieldMartrix =	eye(3);

% This assigns to cfg to make easy in experiment
for k=1:length(Fields)
    WL.cfg.Field.(Fields{k}.FieldName) = Fields{k}.FieldType ;
end


TargetAngle = {pi/2.0};

WL.cfg.Fields = Fields;
WL.cfg.TargetAngle = TargetAngle;
%%
% create blocks based on the indices above
% P sub-structure are variables that can change with each trial
% I sub-structure are variables that do not change withim a block

PreExposure.Trial.Index.Fields = [ 1 1 3 ];
PreExposure.Trial.Index.TargetAngle = [ 1 1 1 ];
PreExposure.Permute = false; %whether to permute within block

Exposure = PreExposure;
Exposure.Trial.Index.Fields = [ 2 2 3 ];

PostExposure = PreExposure; %whether to permute within block
%%
A = WL.parse_trials(PreExposure);
B = WL.parse_trials(Exposure);
C = WL.parse_trials(PostExposure);

T = parse_tree((3*A)+(10*B)+(3*C));

z = zeros(rows(T),1);

%create more table parameters
R = [cos(T.TargetAngle) sin(T.TargetAngle) z];
T.TargetPosition = bsxfun(@plus, bsxfun(@times,WL.cfg.TargetDistance,R), WL.cfg.HomePosition');

T.MovementReactionTime = z;
T.MovementDurationTime = z;

%add passive return movements
T = WL.movement_return(T,WL.cfg.HomePosition');

WL.TrialData = T;
% Add speed cues to WL.TrialData
T.SpeedCue = repmat({'fast'}, height(T), 1);  % Default to 'fast' for all trials
T.SpeedCue(1:2:end) = {'slow'};  % Assign 'slow' to every other trial