% Load the data
wl = load('pilot02.mat');




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


% 
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



% % Call the function to plot a single trajectory
% plot_correction_magnitude(wl, 17);
% 
% function plot_correction_magnitude(wl, trial_number)
%     % Initialize the ideal trajectory (from start to target)
%     start_pos = wl.RobotPosition(trial_number, 1:2, 1);  % Starting position (x, y)
%     target_pos = wl.WL.TrialData.TargetPosition(trial_number, 1:2);  % Target position (x, y)
% 
%     % Compute the direction of the ideal path (straight line from start to target)
%     ideal_vector = target_pos - start_pos;
% 
%     % Normalize the ideal vector to get the unit vector
%     ideal_unit_vector = ideal_vector / norm(ideal_vector);
% 
%     % Initialize correction magnitude (if needed)
%     correctionMagnitude = 0;
% 
%     % Store lateral deviations (for plotting)
%     lateral_deviation = [];
% 
%     % Loop through all the samples (time points) of the trial
%     for i = 1:wl.Samples(trial_number)
%         % Current position of the robot/cursor
%         current_pos = wl.RobotPosition(trial_number, 1:2, i);
% 
%         % Vector from start to the current position
%         current_vector = current_pos - start_pos;
% 
%         % Project current vector onto the ideal unit vector
%         projection_length = dot(current_vector, ideal_unit_vector);
%         projection_point = start_pos + projection_length * ideal_unit_vector;
% 
%         % Calculate lateral deviation (distance from current position to the ideal line)
%         deviation = norm(current_pos - projection_point);
% 
%         % Add the deviation to the total correction magnitude
%         correctionMagnitude = correctionMagnitude + deviation;
% 
%         % Store the deviation for plotting
%         lateral_deviation(end+1) = deviation;
%     end
% 
%     % Plot the lateral deviation over time
%     figure;
%     plot(lateral_deviation, 'LineWidth', 2);
%     xlabel('Time (time)');
%     ylabel('Lateral Deviation (correction magnitude)');
%     title(['Correction Magnitude for Trial ', num2str(trial_number)]);
%     grid on;
% end

% plot_lateral_deviation_by_condition(wl);
% 
% % Function to plot lateral deviation for both fast and slow conditions
% function plot_lateral_deviation_by_condition(wl)
%     % Define the sampling rate (adjust based on your experiment)
%     sampling_rate = 1000;  % For example, 1000 Hz = 1 sample per millisecond
% 
%     % Extract trials for fast and slow conditions based on SpeedCue
%     fast_trials = find(strcmp(wl.WL.TrialData.SpeedCue, 'fast'));
%     slow_trials = find(strcmp(wl.WL.TrialData.SpeedCue, 'slow'));
% 
%     % Initialize storage for lateral deviations
%     max_samples = 0;
%     fast_deviations = [];
%     slow_deviations = [];
% 
%     % Loop through fast trials and pad deviations to match the longest trial
%     for trial_number = fast_trials'
%         lateral_deviation = calculate_lateral_deviation(wl, trial_number);
%         max_samples = max(max_samples, length(lateral_deviation));
%         fast_deviations = [fast_deviations; padarray(lateral_deviation, [0, max_samples - length(lateral_deviation)], NaN, 'post')];
%     end
% 
%     % Loop through slow trials and pad deviations to match the longest trial
%     for trial_number = slow_trials'
%         lateral_deviation = calculate_lateral_deviation(wl, trial_number);
%         max_samples = max(max_samples, length(lateral_deviation));
%         slow_deviations = [slow_deviations; padarray(lateral_deviation, [0, max_samples - length(lateral_deviation)], NaN, 'post')];
%     end
% 
%     % Convert samples to time (seconds)
%     time_in_seconds = (1:max_samples) / sampling_rate;
% 
%     % Plot average lateral deviation for fast and slow conditions
%     figure;
%     plot(time_in_seconds, nanmean(fast_deviations, 1), 'LineWidth', 2, 'DisplayName', 'Fast Condition');
%     hold on;
%     plot(time_in_seconds, nanmean(slow_deviations, 1), 'LineWidth', 2, 'DisplayName', 'Slow Condition', 'LineStyle', '--');
% 
%     % Customize plot
%     xlabel('Time (seconds)');
%     ylabel('Lateral Deviation (cm)');
%     title('Average Lateral Deviation: Fast vs Slow Conditions');
%     legend('show');
%     grid on;
%     hold off;
% end
% 
% % Function to calculate lateral deviation for a single trial
% function lateral_deviation = calculate_lateral_deviation(wl, trial_number)
%     % Initialize the ideal trajectory (from start to target)
%     start_pos = wl.RobotPosition(trial_number, 1:2, 1);  % Starting position (x, y)
%     target_pos = wl.WL.TrialData.TargetPosition(trial_number, 1:2);  % Target position (x, y)
% 
%     % Compute the direction of the ideal path (straight line from start to target)
%     ideal_vector = target_pos - start_pos;
% 
%     % Normalize the ideal vector to get the unit vector
%     ideal_unit_vector = ideal_vector / norm(ideal_vector);
% 
%     % Initialize lateral deviation array
%     lateral_deviation = [];
% 
%     % Loop through all the samples (time points) of the trial
%     for i = 1:wl.Samples(trial_number)
%         % Current position of the robot/cursor
%         current_pos = wl.RobotPosition(trial_number, 1:2, i);
% 
%         % Vector from start to the current position
%         current_vector = current_pos - start_pos;
% 
%         % Project current vector onto the ideal unit vector
%         projection_length = dot(current_vector, ideal_unit_vector);
%         projection_point = start_pos + projection_length * ideal_unit_vector;
% 
%         % Calculate lateral deviation (distance from current position to the ideal line)
%         deviation = norm(current_pos - projection_point);
% 
%         % Store the deviation for plotting
%         lateral_deviation(end+1) = deviation;
%     end
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
plot_velocity_with_movement_start_end(wl, 1);
function plot_velocity_with_movement_start_end(wl, trial_number)
    % Check if trial_number is valid
    if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
        error('Invalid trial number');
    end

    % Extract X and Y velocities of the robot during the trial
    vx = squeeze(wl.RobotVelocity(trial_number, 1, 1:wl.Samples(trial_number)));
    vy = squeeze(wl.RobotVelocity(trial_number, 2, 1:wl.Samples(trial_number)));

    % Calculate the velocity magnitude (speed)
    speed = sqrt(vx.^2 + vy.^2);

    % Extract the time stamps corresponding to the trial in seconds
    time = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));

    % Step 1: Use pre-existing data to determine the start of movement directly
    % Assuming movement_start_time is available in wl.WL.TrialData
    movement_start_time = wl.WL.TrialData.MovementStartTime(trial_number);  % Get the actual start of movement time
    movement_start_idx = find(time >= movement_start_time, 1, 'first');  % Find the index for the start of movement

    % Step 2: Use the pre-existing movement duration to find the end of movement
    movement_end_time = wl.WL.TrialData.MovementDurationTime(trial_number);  % Movement duration in seconds
    movement_end_idx = find(time >= movement_end_time, 1, 'first');  % Find the index for end of movement

    % Plot the velocity (speed) over time
    figure;
    plot(time, speed, 'LineWidth', 2, 'DisplayName', 'Speed');
    hold on;

    % Mark the start of movement based on actual start time
    xline(time(movement_start_idx), 'r--', 'LineWidth', 2, 'DisplayName', 'Start of Movement');
    
    % Mark the end of movement based on pre-existing movement duration
    xline(time(movement_end_idx), 'g--', 'LineWidth', 2, 'DisplayName', 'End of Movement');

    % Add labels, title, and legend
    xlabel('Time (s)');
    ylabel('Speed (cm/s)');
    title(['Velocity Profile with Movement Start and End for Trial ', num2str(trial_number)]);
    legend('show');
    grid on;
    hold off;
end




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
% % Function to calculate lateral deviation and jump size for a single trial
% function [lateral_deviation, jump_size] = calculate_correction_by_jump_size(wl, trial_number)
%     % Get the starting and target positions
%     start_pos = wl.RobotPosition(trial_number, 1:2, 1);
%     target_pos = wl.WL.TrialData.TargetPosition(trial_number, 1:2);  % Correct reference to TargetPosition
% 
%     % Compute the ideal vector
%     ideal_vector = target_pos - start_pos;
%     ideal_unit_vector = ideal_vector / norm(ideal_vector);
% 
%     % Get jump size from trial data
%     jump_size = wl.WL.TrialData.JumpDistance(trial_number);  % Correct reference to JumpDistance
% 
%     % Initialize lateral deviation
%     lateral_deviation = 0;
% 
%     % Loop through all the samples (time points)
%     for i = 1:wl.Samples(trial_number)
%         current_pos = wl.RobotPosition(trial_number, 1:2, i);
%         current_vector = current_pos - start_pos;
%         projection_length = dot(current_vector, ideal_unit_vector);
%         projection_point = start_pos + projection_length * ideal_unit_vector;
%         deviation = norm(current_pos - projection_point);
%         lateral_deviation = lateral_deviation + deviation;
%     end
% 
%     % Normalize lateral deviation by the number of samples
%     lateral_deviation = lateral_deviation / wl.Samples(trial_number);
% end
% plot_correction_over_time(wl);
% function plot_correction_over_time(wl)
%     % Extract trials and their correction magnitudes
%     trials = wl.WL.TrialData;
% 
%     % Initialize storage for correction magnitudes over time
%     trial_numbers = 1:height(trials);  % Assuming trials are ordered sequentially
%     correction_magnitudes = nan(1, height(trials));  % Pre-allocate array
% 
%     % Collect correction magnitudes for each trial
%     for trial_number = 1:height(trials)
%         correction_magnitudes(trial_number) = calculate_correction_magnitude(wl, trial_number);
%     end
% 
%     % Plot the correction magnitudes over time
%     figure;
%     plot(trial_numbers, correction_magnitudes, '-o');
%     xlabel('Trial Number');
%     ylabel('Correction Magnitude (cm)');
%     title('Correction Magnitude Over Time');
%     grid on;
% end
% 
% % Function to calculate correction magnitude for a single trial
% function correction_magnitude = calculate_correction_magnitude(wl, trial_number)
%     % Get the starting and target positions
%     start_pos = wl.RobotPosition(trial_number, 1:2, 1);
%     target_pos = wl.WL.TrialData.TargetPosition(trial_number, 1:2);  % Correct reference to TargetPosition
% 
%     % Compute the ideal vector
%     ideal_vector = target_pos - start_pos;
%     ideal_unit_vector = ideal_vector / norm(ideal_vector);
% 
%     % Initialize correction magnitude
%     correction_magnitude = 0;
% 
%     % Loop through all the samples (time points) and compute deviations
%     for i = 1:wl.Samples(trial_number)
%         current_pos = wl.RobotPosition(trial_number, 1:2, i);
%         current_vector = current_pos - start_pos;
%         projection_length = dot(current_vector, ideal_unit_vector);
%         projection_point = start_pos + projection_length * ideal_unit_vector;
%         deviation = norm(current_pos - projection_point);
%         correction_magnitude = correction_magnitude + deviation;
%     end
% 
%     % Normalize correction magnitude by the number of samples
%     correction_magnitude = correction_magnitude / wl.Samples(trial_number);
% end
% function compare_correction_before_after(wl)
%     trials = wl.WL.TrialData;  % Access the trial data
% 
%     before_perturbation_corrections = [];
%     after_perturbation_corrections = [];
% 
%     for trial_number = 1:height(trials)
%         % Calculate the correction magnitude before perturbation
%         before_correction = calculate_correction_before(wl, trial_number);
%         before_perturbation_corrections = [before_perturbation_corrections, before_correction];
% 
%         % Calculate the correction magnitude after perturbation
%         after_correction = calculate_correction_after(wl, trial_number);
%         after_perturbation_corrections = [after_perturbation_corrections, after_correction];
%     end
% 
%     % Plot the comparison
%     figure;
%     hold on;
%     scatter(1:length(before_perturbation_corrections), before_perturbation_corrections, 'b', 'DisplayName', 'Before Perturbation');
%     scatter(1:length(after_perturbation_corrections), after_perturbation_corrections, 'r', 'DisplayName', 'After Perturbation');
%     xlabel('Trial Number');
%     ylabel('Correction Magnitude (cm)');
%     title('Correction Before vs After Perturbation');
%     legend('show');
%     grid on;
%     hold off;
% end
%  compare_avg_correction_before_after(wl);
%  calculate_correction_before_after(wl, trial_number);
% calculate_correction(wl, trial_number, start_sample, end_sample);
% function compare_avg_correction_before_after(wl)
%     trials = wl.WL.TrialData;  % Access the trial data
% 
%     % Initialize storage for corrections before and after perturbation
%     corrections_before = [];
%     corrections_after = [];
% 
%     % Loop through all trials and calculate corrections before and after perturbation
%     for trial_number = 1:height(trials)
%         [correction_before, correction_after] = calculate_correction_before_after(wl, trial_number);
%         corrections_before = [corrections_before, correction_before];  % Collect corrections before
%         corrections_after = [corrections_after, correction_after];  % Collect corrections after
%     end
% 
%     % Calculate average corrections
%     avg_correction_before = mean(corrections_before);
%     avg_correction_after = mean(corrections_after);
% 
%     % Create a bar plot
%     figure;
%     bar([avg_correction_before, avg_correction_after]);
%     set(gca, 'XTickLabel', {'Before Perturbation', 'After Perturbation'});
%     ylabel('Average Correction Magnitude (cm)');
%     title('Comparison of Average Correction Magnitudes Before and After Perturbation');
%     grid on;
% end
% 
% % Function to calculate corrections before and after perturbation for a single trial
% function [correction_before, correction_after] = calculate_correction_before_after(wl, trial_number)
%     % Example: Assuming the perturbation happens at sample 30, you can modify this logic
%     perturbation_sample = 30;  % This is an example, you can adjust based on your data
%     total_samples = wl.Samples(trial_number);  % Total number of samples for the trial
% 
%     % Compute correction magnitude before perturbation (from start to sample 30)
%     correction_before = calculate_correction(wl, trial_number, 1, perturbation_sample);
% 
%     % Compute correction magnitude after perturbation (from sample 30 to the end)
%     correction_after = calculate_correction(wl, trial_number, perturbation_sample+1, total_samples);
% end
% 
% % Function to calculate correction magnitude for a specific range of samples
% function correction_magnitude = calculate_correction(wl, trial_number, start_sample, end_sample)
%     start_pos = wl.RobotPosition(trial_number, 1:2, 1);
%     target_pos = wl.WL.TrialData.TargetPosition(trial_number, 1:2);
% 
%     % Compute the ideal vector and unit vector
%     ideal_vector = target_pos - start_pos;
%     ideal_unit_vector = ideal_vector / norm(ideal_vector);
% 
%     % Initialize correction magnitude
%     correction_magnitude = 0;
% 
%     % Loop through the specified range of samples
%     for i = start_sample:end_sample
%         current_pos = wl.RobotPosition(trial_number, 1:2, i);
%         current_vector = current_pos - start_pos;
%         projection_length = dot(current_vector, ideal_unit_vector);
%         projection_point = start_pos + projection_length * ideal_unit_vector;
%         deviation = norm(current_pos - projection_point);
%         correction_magnitude = correction_magnitude + deviation;
%     end
% 
%     % Normalize by the number of samples in the range
%     correction_magnitude = correction_magnitude / (end_sample - start_sample + 1);
% end
% % Get the trial durations for fast and slow trials
% fast_durations = wl.WL.TrialData.MovementDurationTime(fast_trials);
% slow_durations = wl.WL.TrialData.MovementDurationTime(slow_trials);
% 
% % Create a time vector for fast and slow trials
% time_fast = 1:length(fast_durations);
% time_slow = 1:length(slow_durations);
% 
% % Plot line for fast and slow durations
% figure;
% plot(time_fast, fast_durations, '-o', 'DisplayName', 'Fast Trials');
% hold on;
% plot(time_slow, slow_durations, '-x', 'DisplayName', 'Slow Trials');
% hold off;
% 
% % Add labels and title
% xlabel('Trial Number');
% ylabel('Duration (s)');
% title('Trial Durations Over Time for Fast and Slow Conditions');
% legend('show');
% grid on;
 
