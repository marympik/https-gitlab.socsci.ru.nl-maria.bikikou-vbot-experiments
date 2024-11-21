wl = load('pp16.mat');
num_trials = size(wl.TimeStamp, 1);
correctionX = NaN(1, num_trials);  % Store signed correction in the x-direction
jumpDistances = NaN(1, num_trials);
isFastTrial = false(1, num_trials);  % Boolean array to indicate if a trial is fast

for trial = 27:546
    % Extract timestamps for the trial
    timeStamps = wl.TimeStamp(trial, 1:wl.Samples(trial));

    % Extract X and Y positions of the robot during the trial
    x = squeeze(wl.RobotPosition(trial, 1, 1:wl.Samples(trial)));
    y = squeeze(wl.RobotPosition(trial, 2, 1:wl.Samples(trial)));

    % Extract target position from TrialData
    target_pos = wl.WL.TrialData.TargetPosition(trial, 1:2);  % Extracting the (x, y) target position

    % Calculate correction relative to the target (in x-direction only)
    finalHandPos = [x(end), y(end)];  % Final hand position
    correctionX(trial) = finalHandPos(1) - target_pos(1);  % Signed correction along the x-axis

    % Extract jump distance for the trial
    jumpDistances(trial) = wl.TrialData.JumpDistance(trial);

    % Determine if the trial is a fast trial
    isFastTrial(trial) = strcmp(wl.TrialData.SpeedCue(trial), 'fast');  % Assuming 'SpeedCue' field specifies 'fast' or 'slow'
end

% Display correction and jump distance for each trial
for trial = 1:num_trials
    disp(['Trial ', num2str(trial), ': Jump Distance = ', num2str(jumpDistances(trial)), ' cm, Correction X = ', num2str(correctionX(trial)), ' cm']);
end

% Separate fast and slow trials
fastJumpDistances = jumpDistances(isFastTrial);
fastCorrectionX = correctionX(isFastTrial);
slowJumpDistances = jumpDistances(~isFastTrial);
slowCorrectionX = correctionX(~isFastTrial);

% Plot correction versus jump distance for all trials with fast and slow indicated by color
figure;
scatter(fastJumpDistances, fastCorrectionX, 50, 'r', 'filled');  % Fast trials in red
hold on;
scatter(slowJumpDistances, slowCorrectionX, 50, 'b', 'filled');  % Slow trials in blue
xlabel('Jump Distance (cm)');
ylabel('Correction (cm)');
title(' Correction vs. Jump Distance (Fast vs. Slow Trials)');
legend('Fast Trials', 'Slow Trials');
grid on;



hold off;

% Separate fast and slow trials
fastJumpDistances = jumpDistances(isFastTrial);
fastCorrectionX = correctionX(isFastTrial);
slowJumpDistances = jumpDistances(~isFastTrial);
slowCorrectionX = correctionX(~isFastTrial);

% Verify the sizes of arrays
disp('Fast Trials Corrections:');
disp(fastCorrectionX);
disp('Slow Trials Corrections:');
disp(slowCorrectionX);
% Combine data for all trials
corrections = [fastCorrectionX, slowCorrectionX]';
jumpDistancesCombined = [fastJumpDistances, slowJumpDistances]';

% Define the speed labels for each correction
speedLabels = [repmat({'Fast'}, length(fastCorrectionX), 1); ...
               repmat({'Slow'}, length(slowCorrectionX), 1)];

% Convert speed labels to categorical data type
speedFactor = categorical(speedLabels);

% correction mangitude 
% Load the data
% Load the data


