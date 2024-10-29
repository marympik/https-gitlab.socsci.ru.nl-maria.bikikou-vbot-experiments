% Load the data
wl = load("test.mat");



% 
% plot_single_trial_trajectory(wl,4);
% function plot_single_trial_trajectory(wl, trial_number)
%     % Check if trial_number is valid
%     if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
%         error('Invalid trial number'); 
%     end
% 
%     % Extract X and Y positions of the robot during the trial
%     x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
%     y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));
% 
%     % Get start and target positions from the wl.WL.cfg structure
%     start_pos = wl.WL.cfg.HomePosition(1:2);  % Extracting the (x, y) home position
%     target_pos = wl.WL.cfg.TargetPosition(1:2);  % Extracting the (x, y) target position
%     jump_distance = wl.TrialData.JumpDistance(trial_number);
% 
%     % Create a new figure for the plot
%     figure;
% 
%     % Plot the trajectory
%     plot(x, y, 'LineWidth', 2, 'DisplayName', 'Trajectory');
%     hold on;
% 
%     % Plot the starting position (Home)
%     plot(start_pos(1), start_pos(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Start Position');
% 
%     % Plot the target position
%     plot(target_pos(1), target_pos(2), 'gx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Target Position');
% 
%     % Set the axis limits based on the configuration
%     xlim([-10 10]);  % You can adjust this as needed
%     ylim([-10 25]);  % Adjust this to suit your experiment's target distance
% 
%     % Add axis labels with units
%     xlabel('X Position (cm)');
%     ylabel('Y Position (cm)');
% 
%     % Add a legend to the plot
%     legend('Location', 'Best');
% 
%     % Set title to indicate which trial is being plotted
%     title(['Trajectory for Trial ', num2str(trial_number), ' - Jump Distance: ', num2str(jump_distance), ' cm']);
% 
%     % Grid for better visualization
%     grid on;
% 
%     hold off;
% end


trial_number = 4; % Specify the trial number
% Check if trial_number is valid
if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
    error('Invalid trial number');
end

% Extract X and Y positions of the robot during the trial
x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));

% Plotting trajectory for hand and cursor
figure;
plot(x, y, 'b', 'LineWidth', 1.5, 'DisplayName', 'Hand Trajectory');
hold on;
xlabel('X Position (cm)');
ylabel('Y Position (cm)');
title(['Trajectory for Trial ', num2str(trial_number), ' - Jump Distance: ', num2str(wl.TrialData.JumpDistance(trial_number)), ' cm']);

% Mark start position
start_pos = wl.WL.cfg.HomePosition(1:2);  % Extracting the (x, y) home position
plot(start_pos(1), start_pos(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Start Position');

% Mark target position
target_pos = wl.WL.cfg.TargetPosition(1:2);  % Extracting the (x, y) target position
plot(target_pos(1), target_pos(2), 'gx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Target Position');

% Plot cursor jump as a step function
jumpTimeIdx = find(wl.State(trial_number, :) == wl.WL.State.CURSORJUMP, 1, 'first');
if ~isempty(jumpTimeIdx)
    cursorPositionX = [x(1:jumpTimeIdx); x(jumpTimeIdx); x(jumpTimeIdx:end) + wl.TrialData.JumpDistance(trial_number)];
    cursorPositionY = [y(1:jumpTimeIdx); y(jumpTimeIdx); y(jumpTimeIdx:end)];
    stairs(cursorPositionX, cursorPositionY, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Cursor Trajectory (Step Function)');
end

legend('Hand Trajectory', 'Start Position', 'Target Position', 'Cursor Trajectory (Step Function)');
grid on;
hold off;


% %Define the trial number (ensure it's available for subsequent use)
% trial_number = 147;  % Specify the trial number
% 
% if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
%     error('Invalid trial number');
% end
% 
% % Extract X and Y positions of the robot during the trial
% x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
% y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));
% 
% % Plotting trajectory for hand and cursor
% figure;
% plot(x, y, 'b', 'LineWidth', 1.5, 'DisplayName', 'Hand Trajectory');
% hold on;
% xlabel('X Position (cm)');
% ylabel('Y Position (cm)');
% title(['Trajectory for Trial ', num2str(trial_number), ' - Jump Distance: ', num2str(wl.TrialData.JumpDistance(trial_number)), ' cm']);
% 
% % Mark start position
% start_pos = wl.WL.cfg.HomePosition(1:2);  % Extracting the (x, y) home position
% plot(start_pos(1), start_pos(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Start Position');
% 
% % Mark target position
% target_pos = wl.WL.cfg.TargetPosition(1:2);  % Extracting the (x, y) target position
% plot(target_pos(1), target_pos(2), 'gx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Target Position');
% 
% % Plot cursor jump as a step function
% jumpTimeIdx = find(strcmp(wl.State(trial_number, :), 'CURSORJUMP'), 1, 'first');
% if ~isempty(jumpTimeIdx)
%     cursorPositionX = [x(1:jumpTimeIdx); x(jumpTimeIdx); x(jumpTimeIdx:end) + wl.TrialData.JumpDistance(trial_number)];
%     cursorPositionY = [y(1:jumpTimeIdx); y(jumpTimeIdx); y(jumpTimeIdx:end)];
%     stairs(cursorPositionX, cursorPositionY, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Cursor Trajectory (Step Function)');
% 
%     % Add markers for step points to indicate stages of movement
%     plot(cursorPositionX(jumpTimeIdx), cursorPositionY(jumpTimeIdx), 'ms', 'MarkerSize', 8, 'DisplayName', 'Step 1');
%     plot(cursorPositionX(jumpTimeIdx + 1), cursorPositionY(jumpTimeIdx + 1), 'cs', 'MarkerSize', 8, 'DisplayName', 'Step 2');
% 
%     % Calculate correction magnitude relative to the target
%     correctedHandPos = [x(end), y(end)];  % Final corrected hand position
%     correctionMagnitudeToTarget = norm(correctedHandPos - target_pos);  % Euclidean distance between corrected hand position and target position
%     disp(['Correction Magnitude to Target: ', num2str(correctionMagnitudeToTarget), ' cm']);
% end
% %CORRECTION MAGNITUDE!!!
% trial_number = 17;
% 
% % Extract timestamps for the trial
% timeStamps = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));
% 
% % Extract X and Y positions of the robot during the trial
% x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
% y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));
% 
% % Extract target position from TrialData
% target_pos = wl.WL.TrialData.TargetPosition(trial_number, 1:2);  % Extracting the (x, y) target position
% 
% % Calculate correction magnitude relative to the target
% % Correction should be based on the difference between the final hand position and the target position
% finalHandPos = [x(end), y(end)];  % Final hand position
% 
% % Correction magnitude is calculated as the Euclidean distance between the final hand position and the target position
% correctionMagnitudeToTarget = norm(finalHandPos - target_pos);  % Euclidean distance between final hand position and target position
% disp(['Correction Magnitude to Target: ', num2str(correctionMagnitudeToTarget), ' cm']);
% 
% % Calculate correction magnitude for all trials
% num_trials = size(wl.TimeStamp, 1);
% correctionMagnitudes = NaN(1, num_trials);
% jumpDistances = NaN(1, num_trials);
% %correction magnitude for all the trials
% for trial = 1:num_trials
%     % Extract timestamps for the trial
%     timeStamps = wl.TimeStamp(trial, 1:wl.Samples(trial));
% 
%     % Extract X and Y positions of the robot during the trial
%     x = squeeze(wl.RobotPosition(trial, 1, 1:wl.Samples(trial)));
%     y = squeeze(wl.RobotPosition(trial, 2, 1:wl.Samples(trial)));
% 
%     % Extract target position from TrialData
%     target_pos = wl.WL.TrialData.TargetPosition(trial, 1:2);  % Extracting the (x, y) target position
% 
%     % Calculate correction magnitude relative to the target
%     finalHandPos = [x(end), y(end)];  % Final hand position
%     correctionMagnitudes(trial) = norm(finalHandPos - target_pos);  % Euclidean distance between final hand position and target position
% 
%     % Extract jump distance for the trial
%     jumpDistances(trial) = wl.TrialData.JumpDistance(trial);
% end
% 
% % Display correction magnitude and jump distance for each trial
% for trial = 1:num_trials
%     disp(['Trial ', num2str(trial), ': Jump Distance = ', num2str(jumpDistances(trial)), ' cm, Correction Magnitude = ', num2str(correctionMagnitudes(trial)), ' cm']);
% end
%correctionmagnitude overall
% Loop through all trials to calculate correction magnitudes for fast and slow trials
% num_trials = size(wl.RobotPosition, 1);
% correctionMagnitudesFast = [];
% correctionMagnitudesSlow = [];
% 
% for trial_number = 1:num_trials
%     % Extract the speed cue for the current trial
%     speedCue = wl.TrialData.SpeedCue{trial_number};
% 
%     % Extract X and Y positions of the robot during the trial
%     x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
%     y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));
% 
%     % Extract target position
%     target_pos = wl.WL.cfg.TargetPosition(1:2);  % Extracting the (x, y) target position
% 
%     % Use the last recorded position of the robot and add the jump distance to calculate correction
%     finalHandPos = [x(end) + wl.TrialData.JumpDistance(trial_number), y(end)];
% 
%     % Calculate correction magnitude relative to the target using Euclidean distance
%     correctionMagnitudeToTarget = sqrt((finalHandPos(1) - target_pos(1))^2 + (finalHandPos(2) - target_pos(2))^2);
% 
%     % Store the correction magnitude based on the speed cue
%     if strcmpi(speedCue, 'fast')
%         correctionMagnitudesFast(end+1) = correctionMagnitudeToTarget;
%     elseif strcmpi(speedCue, 'slow')
%         correctionMagnitudesSlow(end+1) = correctionMagnitudeToTarget;
%     end
% end
% 
% % Display average correction magnitudes for fast and slow trials
% if ~isempty(correctionMagnitudesFast)
%     avgCorrectionFast = mean(correctionMagnitudesFast);
%     disp(['Average Correction Magnitude for Fast Trials: ', num2str(avgCorrectionFast), ' cm']);
% end
% 
% if ~isempty(correctionMagnitudesSlow)
%     avgCorrectionSlow = mean(correctionMagnitudesSlow);
%     disp(['Average Correction Magnitude for Slow Trials: ', num2str(avgCorrectionSlow), ' cm']);
% end
% 
% % Plot the correction magnitudes for fast and slow trials
% figure;
% hold on;
% 
% % Plot fast trials
% if ~isempty(correctionMagnitudesFast)
%     plot(1:length(correctionMagnitudesFast), correctionMagnitudesFast, 'r', 'LineWidth', 1.5, 'DisplayName', 'Fast Trials');
% end
% 
% % Plot slow trials
% if ~isempty(correctionMagnitudesSlow)
%     plot(1:length(correctionMagnitudesSlow), correctionMagnitudesSlow, 'b', 'LineWidth', 1.5, 'DisplayName', 'Slow Trials');
% end
% 
% % Add labels, title, and legend
% xlabel('Trial Number');
% ylabel('Correction Magnitude (cm)');
% title('Correction Magnitudes for Fast and Slow Trials');
% legend('show');
% grid on;
% hold off;
% plot_velocity_over_time(wl, 1);
% 
% function plot_velocity_over_time(wl, trial_number)
% 
%     % Get the X and Y positions for the trial
%     x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
%     y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));
% 
%     % Calculate differences in position between samples
%     dx = diff(squeeze(x));  % Difference in X positions
%     dy = diff(squeeze(y));  % Difference in Y positions
% 
%     dt = diff(nonzeros(wl.TimeStamp(trial_number,:)));
% 
%     % Calculate velocity magnitude
%     velocity = sqrt((dx./dt).^2 + (dy./dt).^2);  % Calculate velocity 
% 
%     % Get the movement duration for this trial
%     movement_duration = wl.WL.TrialData.MovementDurationTime(trial_number);  % Movement duration in seconds
% 
%     time = nonzeros(wl.TimeStamp(trial_number,:));
% 
%     time= time(2:end); %calculate velocity from the 2nd point 
    % % Number of samples for this trial
    % num_samples = length(velocity);  % One less than the number of positions due to diff
    % 
    % % Calculate time per sample
    % time_per_sample = movement_duration / num_samples;
    % 
    % % Create a time vector for plotting
    % time = (1:num_samples) * time_per_sample;

    % Plot velocity over time
    % figure;
    % plot(time, velocity, 'r.');
    % xlabel('Time (seconds)');
    % ylabel('Velocity (m/s)');
    % title(['Velocity over time for Trial ', num2str(trial_number)]);
    % grid on;






%  plot_correction_vs_jump_size(wl);
% function plot_correction_vs_jump_size(wl)
%     % Extract trials and jump sizes
%     trials = wl.WL.TrialData;  % Access the trial data
%     fast_trials = find(strcmp(trials.SpeedCue, 'fast'));
%     slow_trials = find(strcmp(trials.SpeedCue, 'slow'));
% 
%     % Initialize storage for corrections and jump sizes
%     fast_jump_sizes = [];
%     fast_corrections = [];
%     slow_jump_sizes = [];
%     slow_corrections = [];
% 
%     % Compute corrective responses for fast trials
%     for trial_number = fast_trials'
%         [lateral_deviation, jump_size] = calculate_correction_by_jump_size(wl, trial_number);
%         fast_jump_sizes = [fast_jump_sizes, jump_size];  % Collect jump sizes
%         fast_corrections = [fast_corrections, lateral_deviation];  % Collect corrections
%     end
% 
%     % Compute corrective responses for slow trials
%     for trial_number = slow_trials'
%         [lateral_deviation, jump_size] = calculate_correction_by_jump_size(wl, trial_number);
%         slow_jump_sizes = [slow_jump_sizes, jump_size];  % Collect jump sizes
%         slow_corrections = [slow_corrections, lateral_deviation];  % Collect corrections
%     end
% 
%     % Plot the results
%     figure;
%     scatter(fast_jump_sizes, fast_corrections, 'b', 'DisplayName', 'Fast Condition');
%     hold on;
%     scatter(slow_jump_sizes, slow_corrections, 'r', 'DisplayName', 'Slow Condition');
%     xlabel('Jump Size (cm)');
%     ylabel('Correction Magnitude (cm)');
%     title('Corrective Responses vs Jump Sizes');
%     legend('show');
%     grid on;
%     hold off;
% end
% 

 %code for all the movements


% %Initialize an array to store the movement durations for the whole experiment
% wholeMovementDurations = nan(height(WL.TrialData), 1);
% 
% % Loop through the trials
% for trial = 1:height(wl.WL.TrialData)
%     % Extract the non-zero time stamps for this trial directly from wl
%     timeData = nonzeros(wl.TimeStamp(trial, :));  % Valid time stamps for the trial
% 
%     % Ensure that there are valid time data
%     if ~isempty(timeData)
%         % Calculate the total movement duration from the first valid time sample to the last
%         movementDuration = timeData(end) - timeData(1);  % Total duration for this trial
%         wholeMovementDurations(trial) = movementDuration;  % Store the result
%     end
% end

% Plot the whole movement duration
% figure;
% plot(1:length(wholeMovementDurations), wholeMovementDurations, 'o-', 'LineWidth', 1.5);
% xlabel('Trial Number');
% ylabel('Whole Movement Duration (seconds)');
% title('Whole Movement Duration for Each Trial');
% grid on;


%Movementduration finally

trial_number = 9;

% Extract timestamps for the trial
timeStamps = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));

% Extract X and Y components of the robot velocity during the trial
vx = squeeze(wl.RobotVelocity(trial_number, 1, 1:wl.Samples(trial_number)));
vy = squeeze(wl.RobotVelocity(trial_number, 2, 1:wl.Samples(trial_number)));

% Calculate the velocity magnitude (speed)
speed = sqrt(vx.^2 + vy.^2);

% Smooth speed to remove noise
speed = movmean(speed, 10);

% Adjust speed to ensure it starts at zero if there's an initial offset
speed = speed - min(speed);

% Define velocity thresholds to determine movement start and end
velocityOnsetThreshold = 2;  % Threshold for movement start
velocityOffsetThreshold = 2; % Threshold for movement end

% Find movement start index (first time velocity exceeds onset threshold)
movementStartIdx = find(speed > velocityOnsetThreshold, 1, 'first');

% Find peak velocity index after movement start
if ~isempty(movementStartIdx)
    [peakVelocity, peakVelocityIdx] = max(speed(movementStartIdx:end));
    peakVelocityIdx = peakVelocityIdx + movementStartIdx - 1;
else
    peakVelocityIdx = [];
end

% Find movement end index (first time velocity falls below offset threshold after peak velocity)
if ~isempty(peakVelocityIdx)
    movementEndIdx = find(speed < velocityOffsetThreshold & (1:length(timeStamps))' > peakVelocityIdx, 1, 'first');
    % Ensure movementEndIdx does not exceed array bounds
    if isempty(movementEndIdx) || movementEndIdx > length(timeStamps)
        movementEndIdx = length(timeStamps);
    end
else
    movementEndIdx = [];
end

% Plot the velocity (speed) over time
figure;
plot(timeStamps, speed, 'b', 'LineWidth', 1.5);
hold on;
xlabel('Time (seconds)');
ylabel('Velocity Magnitude (cm/s)');
title('Velocity Magnitude over Time');

% Mark the start and end of movement
if ~isempty(movementStartIdx)
    xline(timeStamps(movementStartIdx), 'g--', 'LineWidth', 2, 'DisplayName', 'Movement Start');
end
if ~isempty(movementEndIdx)
    xline(timeStamps(movementEndIdx), 'r--', 'LineWidth', 2, 'DisplayName', 'Movement End');
end

% Legend and grid for visualization
legend('Velocity Magnitude', 'Movement Start', 'Movement End');
grid on;
hold off;

% Display movement duration
if ~isempty(movementStartIdx) && ~isempty(movementEndIdx)
    movementDuration = timeStamps(movementEndIdx) - timeStamps(movementStartIdx);
    disp(['Total Movement Duration: ', num2str(movementDuration), ' seconds']);
end
% Specify the current trial number
trial_number = 9; % Update trial number as needed

% Check if trial_number is valid
if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
    error('Invalid trial number');
end

% Extract current trial data (X and Y positions of the robot)
x_current = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
y_current = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));

% Check if there is a previous trial to compare with
if trial_number > 1
    % Extract previous trial data (X and Y positions of the robot)
    x_previous = squeeze(wl.RobotPosition(trial_number - 1, 1, 1:wl.Samples(trial_number - 1)));
    y_previous = squeeze(wl.RobotPosition(trial_number - 1, 2, 1:wl.Samples(trial_number - 1)));
else
    error('No previous trial available for comparison');
end

% Plotting trajectories for current and previous trials
figure;
plot(x_current, y_current, 'b', 'LineWidth', 1.5, 'DisplayName', 'Current Trial Hand Trajectory');
hold on;
plot(x_previous, y_previous, 'k', 'LineWidth', 1.5, 'DisplayName', 'Previous Trial Hand Trajectory');
xlabel('X Position (cm)');
ylabel('Y Position (cm)');
title(['Current vs Previous Trajectory - Trial ', num2str(trial_number), ' - Jump Distance: ', num2str(wl.TrialData.JumpDistance(trial_number)), ' cm']);

% Mark start position
start_pos = wl.WL.cfg.HomePosition(1:2); % Extracting the (x, y) home position
plot(start_pos(1), start_pos(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Start Position');

% Mark target position
target_pos = wl.WL.cfg.TargetPosition(1:2); % Extracting the (x, y) target position
plot(target_pos(1), target_pos(2), 'gx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Target Position');

% Plot cursor jump for the current trial as a step function
jumpTimeIdx_current = find(wl.State(trial_number, :) == wl.WL.State.CURSORJUMP, 1, 'first');
if ~isempty(jumpTimeIdx_current)
    cursorPositionX = [x_current(1:jumpTimeIdx_current); x_current(jumpTimeIdx_current); x_current(jumpTimeIdx_current:end) + wl.TrialData.JumpDistance(trial_number)];
    cursorPositionY = [y_current(1:jumpTimeIdx_current); y_current(jumpTimeIdx_current); y_current(jumpTimeIdx_current:end)];
    stairs(cursorPositionX, cursorPositionY, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Current Cursor Trajectory (Step Function)');
end


legend('Current Trial Hand Trajectory', 'Previous Trial Hand Trajectory', 'Start Position', 'Target Position', 'Current Cursor Trajectory (Step Function)');
grid on;
hold off;

