 %Plot all trajectories, color-coded by the previous trial's jump direction
figure;
hold on;

% Loop through all trials, starting from trial 2 since we need trial t-1 for previous jump info
for trial_number = 2(wl.RobotPosition, 1)
% Check if trial data is valid
if isnan(wl.TrialData.JumpDistance(trial_number - 1))
continue;
end
% Get the previous trial's jump size
prev_jump = wl.TrialData.JumpDistance(trial_number - 1);

% Extract the current trial's hand trajectory
x = squeeze(wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number)));
y = squeeze(wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number)));

% Color-code based on the direction of the previous jump
if prev_jump > 0
    plot(x, y, 'b', 'LineWidth', 1.5); % Blue for positive previous jump
elseif prev_jump < 0
    plot(x, y, 'r', 'LineWidth', 1.5); % Red for negative previous jump
end

% Plot formatting
xlabel('X Position (cm)');
ylabel('Y Position (cm)');
title('All Trajectories Overlayed - Color Coded by Previous Jump Direction');
legend('Positive Previous Jump', 'Negative Previous Jump', 'Location', 'Best');
grid on;
hold off;