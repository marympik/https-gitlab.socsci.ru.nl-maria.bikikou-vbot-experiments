% Load the data
wl = load("pilot02.mat");



% plot_single_trial_trajectory(wl, 25);  % Change 2 to any valid trial number
% 
% %Function to plot a single trial's trajectory
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
% 
%     % Grid for better visualization
%     grid on;
% 
%     hold off;
% end
 
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
%     % % Number of samples for this trial
%     % num_samples = length(velocity);  % One less than the number of positions due to diff
%     % 
%     % % Calculate time per sample
%     % time_per_sample = movement_duration / num_samples;
%     % 
%     % % Create a time vector for plotting
%     % time = (1:num_samples) * time_per_sample;
% 
%     % Plot velocity over time
%     figure;
%     plot(time, velocity, 'r.');
%     xlabel('Time (seconds)');
%     ylabel('Velocity (m/s)');
%     title(['Velocity over time for Trial ', num2str(trial_number)]);
%     grid on;
% 
% end




% analyze_corrections_by_jump_size(wl);
% 
% function analyze_corrections_by_jump_size(wl)
%     jump_sizes = unique(wl.WL.TrialData.JumpDistance);  % Get unique jump sizes
%     correction_magnitudes = wl.WL.TrialData.CorrectionMagnitude;  % Get correction magnitudes
% 
%     mean_corrections = zeros(size(jump_sizes));
%     std_corrections = zeros(size(jump_sizes));
% 
%     % Calculate mean and standard deviation for each jump size
%     for i = 1:length(jump_sizes)
%         trials_for_jump = correction_magnitudes(wl.WL.TrialData.JumpDistance == jump_sizes(i));
%         mean_corrections(i) = mean(trials_for_jump);
%         std_corrections(i) = std(trials_for_jump);  % Optional: To show variability
%     end
% 
%     % Plot mean correction magnitudes per jump size
%     figure;
%     errorbar(jump_sizes, mean_corrections, std_corrections, 'o-', 'LineWidth', 2);
%     xlabel('Jump Size');
%     ylabel('Mean Correction Magnitude');
%     title('Correction Magnitude vs Jump Size');
%     grid on;
% end

% % Select a trial number (e.g., trial 1)
% trial_number = 1;2;3;5;
% 
% % Extract the X and Y positions for the selected trial
% x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
% y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));
% 
% % Display the X and Y positions
% disp('X Position:');
% disp(x);
% 
% disp('Y Position:');
% disp(y);
% 
% % Plot the trajectory for the selected trial
% figure;
% plot(x, y);
% xlabel('X Position');
% ylabel('Y Position');
% title(['Trajectory for Trial ', num2str(trial_number)]);
% grid on;

% Example plotting code with start, target positions, and units
% figure;
% hold on;


% 
% plot_robot_velocity_magnitude(wl, 1);  % Change 80 to any valid trial number


% % Function to plot the velocity magnitude (speed) for a single trial
% function plot_robot_velocity_magnitude(wl, trial_number)
%     % Check if trial_number is valid
%     if trial_number < 1 || trial_number > size(wl.RobotVelocity, 1)
%         error('Invalid trial number');
%     end
% 
%     % Extract X and Y components of the robot velocity during the trial
%     vx = squeeze(wl.RobotVelocity(trial_number, 1, 1:wl.Samples(trial_number)));
%     vy = squeeze(wl.RobotVelocity(trial_number, 2, 1:wl.Samples(trial_number)));
% 
%     % Calculate the velocity magnitude (speed)
%     speed = sqrt(vx.^2 + vy.^2);
% 
% 
%     % Extract the time stamps corresponding to the trial
%     time = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));
% 
%     % Plot the velocity magnitude (speed) over time
%     figure;
%     plot(time, speed, 'LineWidth', 3);
%     xlabel('Time (ms)');
%     ylabel('Speed (cm/s)');
%     title(['Robot Velocity Magnitude (Speed) for Trial ', num2str(trial_number)]);
%     grid on;
% end
% plot_velocity_with_movement_start_end(wl, 1);
% function plot_velocity_with_movement_start_end(wl, trial_number)
%     % Check if trial_number is valid
%     if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
%         error('Invalid trial number');
%     end
% 
%     % Extract X and Y velocities of the robot during the trial
%     vx = squeeze(wl.RobotVelocity(trial_number, 1, 1:wl.Samples(trial_number)));
%     vy = squeeze(wl.RobotVelocity(trial_number, 2, 1:wl.Samples(trial_number)));
% 
%     % Calculate the velocity magnitude (speed)
%     speed = sqrt(vx.^2 + vy.^2);
% 
%     % Extract the time stamps corresponding to the trial in seconds
%     time = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));
% 
%     % Step 1: Use pre-existing data to determine the start of movement directly
%     % Assuming movement_start_time is available in wl.WL.TrialData
%     movement_start_time = wl.WL.TrialData.MovementStartTime(trial_number);  % Get the actual start of movement time
%     movement_start_idx = find(time >= movement_start_time, 1, 'first');  % Find the index for the start of movement
% 
%     % Step 2: Use the pre-existing movement duration to find the end of movement
%     movement_end_time = wl.WL.TrialData.MovementDurationTime(trial_number);  % Movement duration in seconds
%     movement_end_idx = find(time >= movement_end_time, 1, 'first');  % Find the index for end of movement
% 
%     % Plot the velocity (speed) over time
%     figure;
%     plot(time, speed, 'LineWidth', 2, 'DisplayName', 'Speed');
%     hold on;
% 
%     % Mark the start of movement based on actual start time
%     xline(time(movement_start_idx), 'r--', 'LineWidth', 2, 'DisplayName', 'Start of Movement');
% 
%     % Mark the end of movement based on pre-existing movement duration
%     xline(time(movement_end_idx), 'g--', 'LineWidth', 2, 'DisplayName', 'End of Movement');
% 
%     % Add labels, title, and legend
%     xlabel('Time (s)');
%     ylabel('Speed (cm/s)');
%     title(['Velocity Profile with Movement Start and End for Trial ', num2str(trial_number)]);
%     legend('show');
%     grid on;
%     hold off;
% end
% 
% 


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


%Initialize an array to store the movement durations for the whole experiment
% wholeMovementDurations = nan(height(WL.TrialData), 1);
% 
% % Loop through the trials
% for trial = 1:height(WL.TrialData)
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
% 
% % Plot the whole movement duration
% figure;
% plot(1:length(wholeMovementDurations), wholeMovementDurations, 'o-', 'LineWidth', 1.5);
% xlabel('Trial Number');
% ylabel('Whole Movement Duration (seconds)');
% title('Whole Movement Duration for Each Trial');
% grid on;


% plot_velocity_and_movement_duration_for_trial(wl, 2);
% function plot_velocity_and_movement_duration_for_trial(wl, trial_number)
%     % Function to plot velocity, movement duration for a specific trial,
%     % and mark the start and target positions on the plot.
% 
%     % Ensure the trial number is within range
%     if trial_number > size(wl.TimeStamp, 1)
%         error('Trial number exceeds the number of trials in TimeStamp data.');
%     end
% 
%     % Extract the non-zero time stamps for the specified trial
%     timeData = nonzeros(wl.TimeStamp(trial_number, :));  % Valid time stamps for the trial
% 
%     % Ensure that there are valid time data
%     if ~isempty(timeData)
%         % Calculate the total movement duration from the first valid time sample to the last
%         movementDuration = timeData(end) - timeData(1);  % Total duration for the specified trial
%         time = timeData - timeData(1);  % Time from the start of the trial
%     else
%         disp(['No valid time data for trial ', num2str(trial_number)]);
%         movementDuration = NaN;
%         return;  % Exit the function if there's no valid data
%     end
% 
%     % Extract the velocity data
%     x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
%     y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));
% 
%     % Calculate differences in position between samples
%     dx = diff(squeeze(x));  % Difference in X positions
%     dy = diff(squeeze(y));  % Difference in Y positions
% 
%     dt = diff(nonzeros(wl.TimeStamp(trial_number,:)));  % Time intervals
% 
%     % Calculate velocity magnitude
%     velocity = sqrt((dx ./ dt).^2 + (dy ./ dt).^2);  % Calculate velocity 
% 
%     % Adjust time to match the size of velocity (one less point due to diff)
%     time = time(2:end);
% 
%     % Plot the velocity over time
%     figure;
%     plot(time, velocity, 'b-', 'LineWidth', 1.5);
%     xlabel('Time (seconds)');
%     ylabel('Velocity (units/s)');
%     title(['Velocity Profile and Movement Duration for Trial ', num2str(trial_number)]);
%     hold on;
% 
%     % Add markers for the start position and target position
%     ylimits = ylim;  % Get current y-axis limits to properly place markers
%     plot([time(1) time(1)], ylimits, 'g--', 'LineWidth', 2);  % Start position marker (green dashed line)
%     plot([time(end) time(end)], ylimits, 'r--', 'LineWidth', 2);  % Target position marker (red dashed line)
% 
%     % Annotate the plot
%     text(time(1), ylimits(2), ' Start Position', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'green');
%     text(time(end), ylimits(2), ' Target Position', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'red');
% 
%     % Plot the movement duration as a horizontal line
%     plot([time(1) time(end)], [movementDuration movementDuration], 'k--', 'LineWidth', 1.5);
%     text(time(end), movementDuration, [' Movement Duration: ', num2str(movementDuration), ' s'], 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'black');
% 
%     grid on;
%     hold off;
% end

 
% plot_robot_position_with_duration(wl, 1);
% function plot_robot_position_with_duration(wl, trial_number)
%     % Function to plot robot position with movement duration for a specific trial
%     % Inputs:
%     %   wl: structure containing the data
%     %   trial_number: the trial number to analyze
% 
%     % Define the states for movement start and end
%     HomeState = 4;  % INITIALIZE state (movement start)
%     MovementEndState = 11;  % FINISH state (movement end)
% 
%     % Extract the state data for the trial
%     stateData = wl.State(trial_number, :);
% 
%     % Find the first occurrence of HomeState and MovementEndState
%     timeStartIndex = find(stateData == HomeState, 1, 'first');
%     timeEndIndex = find(stateData == MovementEndState, 1, 'first');
% 
%     % Extract the corresponding time stamps
%     timeStart = wl.TimeStamp(trial_number, timeStartIndex);
%     timeEnd = wl.TimeStamp(trial_number, timeEndIndex);
% 
%     % Calculate the movement duration
%     movementDuration = timeEnd - timeStart;
% 
%     % Extract the robot position data for the trial
%     robotPositionX = wl.RobotPosition(trial_number, 1, timeStartIndex:timeEndIndex);
%     robotPositionY = wl.RobotPosition(trial_number, 2, timeStartIndex:timeEndIndex);
% 
%     % Extract the corresponding time stamps and subtract the movement start time
%     timeData = wl.TimeStamp(trial_number, timeStartIndex:timeEndIndex) - timeStart;
% 
%     % Plot robot position X and Y against the adjusted time
%     figure;
%     subplot(2, 1, 1);
%     plot(timeData, squeeze(robotPositionX), 'b-', 'LineWidth', 1.5);
%     xlabel('Time (seconds)');
%     ylabel('Robot Position X (units)');
%     title(['Robot Position X over Time for Trial ', num2str(trial_number)]);
%     grid on;
% 
%     subplot(2, 1, 2);
%     plot(timeData, squeeze(robotPositionY), 'r-', 'LineWidth', 1.5);
%     xlabel('Time (seconds)');
%     ylabel('Robot Position Y (units)');
%     title(['Robot Position Y over Time for Trial ', num2str(trial_number)]);
%     grid on;
% 
%     % Print the movement duration
%     fprintf('Movement Duration for Trial %d: %.4f seconds\n', trial_number, movementDuration);
% end

plot_robot_position_over_time(wl, 1);
function plot_robot_position_over_time(wl, trial_number)


    robotPositionX = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
    robotPositionY = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));

    % Extract the corresponding time stamps for the trial
    timeData = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));

    figure;
    plot(timeData, robotPositionX, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(timeData, robotPositionY, 'r-', 'LineWidth', 1.5);

    % Customize the plot
    xlabel('Time (seconds)');
    ylabel('Robot Position (units)');
    title(['Robot Position over Time for Trial ', num2str(trial_number)]);
    legend('Position X', 'Position Y');
    grid on;
    hold off;
end
% plot_robot_position_with_movement_time(wl, 1);
% function plot_robot_position_with_movement_time(wl, trial_number)
% 
%     % Define the states for movement start (Initialize) and end (Finish)
%     InitializeState = 4; 
%     FinishState = 11;    
% 
%     % Extract the state data for the trial
%     stateData = wl.State(trial_number, :);
% 
%     % Find the first occurrence of 'Initialize' and 'Finish'
%     timeStartIndex = find(stateData == InitializeState, 1, 'first');
%     timeEndIndex = find(stateData == FinishState, 1, 'first');
% 
%     % Extract the corresponding time stamps for start and end
%     timeStart = wl.TimeStamp(trial_number, timeStartIndex);
%     timeEnd = wl.TimeStamp(trial_number, timeEndIndex);
% 
%     movementDuration = timeEnd - timeStart;
% 
%     % Extract the robot position data (X and Y) for the trial
%     robotPositionX = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
%     robotPositionY = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));
% 
%     % Extract the corresponding time stamps for the trial
%     timeData = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));
% 
%     % Plot robot position X and Y against the time
%     figure;
%     plot(timeData, robotPositionX, 'b-', 'LineWidth', 1.5);
%     hold on;
%     plot(timeData, robotPositionY, 'r-', 'LineWidth', 1.5);
%     plot([timeStart timeStart], ylim, 'g--', 'LineWidth', 2);  % Start position marker (green dashed line)
%     plot([timeEnd timeEnd], ylim, 'r--', 'LineWidth', 2);      % End position marker (red dashed line)
% 
%     % Customize the plot
%     xlabel('Time (seconds)');
%     ylabel('Robot Position (units)');
%     title(['Robot Position over Time for Trial ', num2str(trial_number)]);
%     legend('Position X', 'Position Y', 'Movement Start', 'Movement End');
%     grid on;
%     hold off;
% 
%     % Print the movement duration
%     fprintf('Movement Duration for Trial %d: %.4f seconds\n', trial_number, movementDuration);
% end
% 
