% Load the data
wl = load('pp02.mat');

% Total number of trials in TrialData and RobotPosition
num_trialdata_trials = size(wl.WL.TrialData.TargetPosition, 1);
num_robot_trials = size(wl.RobotPosition, 1);

% Ensure the smaller size is used to prevent mismatches
num_trials = min(num_trialdata_trials, num_robot_trials);

% Step 1: Identify target-shifted trials
shiftedTargets = ismember(wl.WL.TrialData.TargetPosition(1:num_trials, :), [-5, 10, 0], 'rows') | ...
                 ismember(wl.WL.TrialData.TargetPosition(1:num_trials, :), [5, 10, 0], 'rows');

% Step 2: Identify practice trials
practiceTrials = contains(wl.WL.TrialData.block_name(1:num_trials), {'Sprac', 'Fprac'}, 'IgnoreCase', true);

% Step 3: Identify full visual feedback trials
fullVisualTrials = contains(wl.WL.TrialData.block_name(1:num_trials), {'Svis', 'Fvis'}, 'IgnoreCase', true);

% Step 4: Combine indices to filter experimental trials
actualExperimentTrials = ~(shiftedTargets | practiceTrials | fullVisualTrials);

% Filter data
filteredJumpDistances = wl.WL.TrialData.JumpDistance(actualExperimentTrials);
filteredHandTrajectories = wl.RobotPosition(actualExperimentTrials, :, :);

% Step 5: Unique jump distances for plotting
uniqueJumpDistances = unique(filteredJumpDistances);

% Plot: Hand trajectories for each jump distance
figure;
num_jumps = length(uniqueJumpDistances);
rows = ceil(sqrt(num_jumps)); % Rows for subplots
cols = ceil(num_jumps / rows); % Columns for subplots

for i = 1:num_jumps
    jumpDistance = uniqueJumpDistances(i);
    idx = (filteredJumpDistances == jumpDistance);

    subplot(rows, cols, i);
    hold on;
    for trialIdx = find(idx)'
        % Extract X and Y positions of the hand
        x = squeeze(filteredHandTrajectories(trialIdx, 1, :));
        y = squeeze(filteredHandTrajectories(trialIdx, 2, :));
        plot(x, y, 'b'); % Plot trajectory in blue
    end
    hold off;
    title(['Jump Distance: ', num2str(jumpDistance), ' cm']);
    xlabel('X Position (cm)');
    ylabel('Y Position (cm)');
    grid on;
end
sgtitle('Hand Trajectories for Each Jump Distance');

%fast versus slow  condition
% Load the data


% Total number of trials in TrialData and RobotPosition
num_trialdata_trials = size(wl.WL.TrialData.TargetPosition, 1);
num_robot_trials = size(wl.RobotPosition, 1);

% Ensure the smaller size is used to prevent mismatches
num_trials = min(num_trialdata_trials, num_robot_trials);

% Step 1: Identify target-shifted trials
shiftedTargets = ismember(wl.WL.TrialData.TargetPosition(1:num_trials, :), [-5, 10, 0], 'rows') | ...
                 ismember(wl.WL.TrialData.TargetPosition(1:num_trials, :), [5, 10, 0], 'rows');

% Step 2: Identify practice trials
practiceTrials = contains(wl.WL.TrialData.block_name(1:num_trials), {'Sprac', 'Fprac'}, 'IgnoreCase', true);

% Step 3: Identify full visual feedback trials
fullVisualTrials = contains(wl.WL.TrialData.block_name(1:num_trials), {'Svis', 'Fvis'}, 'IgnoreCase', true);

% Step 4: Combine indices to filter experimental trials
actualExperimentTrials = ~(shiftedTargets | practiceTrials | fullVisualTrials);

% Filter data for actual experimental trials
filteredJumpDistances = wl.WL.TrialData.JumpDistance(actualExperimentTrials);
filteredHandTrajectories = wl.RobotPosition(actualExperimentTrials, :, :);

% Determine fast and slow trials
isFastTrial = strcmp(wl.WL.TrialData.SpeedCue(actualExperimentTrials), 'fast');
isSlowTrial = strcmp(wl.WL.TrialData.SpeedCue(actualExperimentTrials), 'slow');

% Separate fast and slow trials
fastJumpDistances = filteredJumpDistances(isFastTrial);
slowJumpDistances = filteredJumpDistances(isSlowTrial);

fastHandTrajectories = filteredHandTrajectories(isFastTrial, :, :);
slowHandTrajectories = filteredHandTrajectories(isSlowTrial, :, :);

% Step 5: Unique jump distances for plotting
uniqueFastJumpDistances = unique(fastJumpDistances);
uniqueSlowJumpDistances = unique(slowJumpDistances);

% Plot for Fast Trials
figure;
num_jumps_fast = length(uniqueFastJumpDistances);
rows_fast = ceil(sqrt(num_jumps_fast)); % Rows for subplots
cols_fast = ceil(num_jumps_fast / rows_fast); % Columns for subplots

for i = 1:num_jumps_fast
    jumpDistance = uniqueFastJumpDistances(i);
    idx = (fastJumpDistances == jumpDistance);

    subplot(rows_fast, cols_fast, i);
    hold on;
    for trialIdx = find(idx)'
        % Extract X and Y positions of the hand
        x = squeeze(fastHandTrajectories(trialIdx, 1, :));
        y = squeeze(fastHandTrajectories(trialIdx, 2, :));
        plot(x, y, 'b'); % Plot trajectory in blue
    end
    hold off;
    title(['Fast - Jump Distance: ', num2str(jumpDistance), ' cm']);
    xlabel('X Position (cm)');
    ylabel('Y Position (cm)');
    grid on;
end
sgtitle('Hand Trajectories for Fast Trials');

% Plot for Slow Trials
figure;
num_jumps_slow = length(uniqueSlowJumpDistances);
rows_slow = ceil(sqrt(num_jumps_slow)); % Rows for subplots
cols_slow = ceil(num_jumps_slow / rows_slow); % Columns for subplots

for i = 1:num_jumps_slow
    jumpDistance = uniqueSlowJumpDistances(i);
    idx = (slowJumpDistances == jumpDistance);

    subplot(rows_slow, cols_slow, i);
    hold on;
    for trialIdx = find(idx)'
        % Extract X and Y positions of the hand
        x = squeeze(slowHandTrajectories(trialIdx, 1, :));
        y = squeeze(slowHandTrajectories(trialIdx, 2, :));
        plot(x, y, 'r'); % Plot trajectory in red
    end
    hold off;
    title(['Slow - Jump Distance: ', num2str(jumpDistance), ' cm']);
    xlabel('X Position (cm)');
    ylabel('Y Position (cm)');
    grid on;
end
sgtitle('Hand Trajectories for Slow Trials');


