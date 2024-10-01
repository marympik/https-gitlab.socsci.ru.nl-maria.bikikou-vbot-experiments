% % Load the data
% wl = load('data\pilot02.mat');
% 
% % Call the function to plot a single trajectory
% plot_single_trial_trajectory(wl, 24);  % Change 99 to any valid trial number
% 
% % Function to plot a single trial's trajectory
% function plot_single_trial_trajectory(wl, trial_number)
%     % Check if trial_number is valid
%     if trial_number < 1 || trial_number > size(wl.RobotPosition, 1)
%         error('Invalid trial number');
%     end
% 
%     % Extract position data for the selected trial
%     x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
%     y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));
% 
%     % Plot trajectory
%     figure;
%     plot(squeeze(x), squeeze(y), 'LineWidth', 2);
%     xlim(sort(wl.WL.cfg.graphics_config.Xmin_Xmax));
%     ylim(sort(wl.WL.cfg.graphics_config.Ymin_Ymax));
%     xlabel('X Position');
%     ylabel('Y Position');
%     title(['Trajectory for Trial ' num2str(trial_number)]);
%     grid on;
%     shg;
% end


plot_velocity_over_time(wl, 24);

function plot_velocity_over_time(wl, trial_number)

    % Get the X and Y positions for the trial
    x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
    y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));

    % Calculate differences in position between samples
    dx = diff(squeeze(x));  % Difference in X positions
    dy = diff(squeeze(y));  % Difference in Y positions

    dt = diff(nonzeros(wl.TimeStamp(trial_number,:)));

    % Calculate velocity magnitude
    velocity = sqrt((dx./dt).^2 + (dy./dt).^2);  % Calculate velocity 

    % Get the movement duration for this trial
    movement_duration = wl.WL.TrialData.MovementDurationTime(trial_number);  % Movement duration in seconds

    time = nonzeros(wl.TimeStamp(trial_number,:));

    time= time(2:end); %calculate velocity from the 2nd point 
    % % Number of samples for this trial
    % num_samples = length(velocity);  % One less than the number of positions due to diff
    % 
    % % Calculate time per sample
    % time_per_sample = movement_duration / num_samples;
    % 
    % % Create a time vector for plotting
    % time = (1:num_samples) * time_per_sample;

    % Plot velocity over time
    figure;
    plot(time, velocity, 'r.');
    xlabel('Time (seconds)');
    ylabel('Velocity (m/s)');
    title(['Velocity over time for Trial ', num2str(trial_number)]);
    grid on;
    
end



