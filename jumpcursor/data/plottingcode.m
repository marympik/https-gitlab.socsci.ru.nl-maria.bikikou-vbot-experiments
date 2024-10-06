% Load the data
wl = load('data\pilot02.mat');


% 
% plot_single_trial_trajectory(wl, 90);  % Change 2 to any valid trial number
% 
% % Function to plot a single trial's trajectory
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
%     title(['Trajectory for Trial ', num2str(trial_number)]);
% 
%     % Grid for better visualization
%     grid on;
% 
%     hold off;
% end

% 
% plot_velocity_over_time(wl, 24);
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
% 
% 

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
% plot_robot_velocity_magnitude(wl, 24);  % Change 80 to any valid trial number
% 
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
%     % Extract the time stamps corresponding to the trial
%     time = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));
% 
%     % Plot the velocity magnitude (speed) over time
%     figure;
%     plot(time, speed, 'LineWidth', 2);
%     xlabel('Time (ms)');
%     ylabel('Speed (cm/s)');
%     title(['Robot Velocity Magnitude (Speed) for Trial ', num2str(trial_number)]);
%     grid on;
% end

calculate_movement_duration(wl,103);

% Function to calculate and optionally plot movement duration
function movement_duration = calculate_movement_duration(wl, trial_number)
    % Check if trial_number is valid
    if trial_number < 1 || trial_number > size(wl.RobotVelocity, 1)
        error('Invalid trial number');
    end

    % Extract X and Y components of the robot velocity during the trial
    vx = squeeze(wl.RobotVelocity(trial_number, 1, 1:wl.Samples(trial_number)));
    vy = squeeze(wl.RobotVelocity(trial_number, 2, 1:wl.Samples(trial_number)));
    
    % Calculate the velocity magnitude (speed)
    speed = sqrt(vx.^2 + vy.^2);
    
    % Extract the time stamps corresponding to the trial
    time = wl.TimeStamp(trial_number, 1:wl.Samples(trial_number));

    % Find when the speed exceeds a small threshold (to avoid noise)
    speed_threshold = 0.1;  % Adjust based on noise level
    movement_start_idx = find(speed > speed_threshold, 1, 'first');
    movement_end_idx = find(speed > speed_threshold, 1, 'last');
    
    % Calculate movement duration
    movement_duration = time(movement_end_idx) - time(movement_start_idx);
    
    % Optionally, print the movement duration
    disp(['Movement duration for Trial ', num2str(trial_number), ': ', num2str(movement_duration), ' ms']);
    
    % Plot the velocity and indicate movement start and end points
    figure;
    plot(time, speed, 'LineWidth', 2);
    hold on;
    xline(time(movement_start_idx), 'r--', 'DisplayName', 'Start of Movement');
    xline(time(movement_end_idx), 'g--', 'DisplayName', 'End of Movement');
    xlabel('Time (ms)');
    ylabel('Speed (cm/s)');
    title(['Robot Velocity Magnitude (Speed) for Trial ', num2str(trial_number)]);
    legend('show');
    grid on;
    hold off;
end


