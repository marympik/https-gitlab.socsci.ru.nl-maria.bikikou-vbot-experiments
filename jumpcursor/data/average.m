
% Load the data
wl = load('pp14.mat');

% Ensure variables are consistent in dimensions
num_trialdata_trials = size(wl.WL.TrialData.TargetPosition, 1);
num_robot_trials = size(wl.RobotPosition, 1);
num_trials = min(num_trialdata_trials, num_robot_trials);

% Identify trials for analysis
shiftedTargets = ismember(wl.WL.TrialData.TargetPosition(1:num_trials, :), [-5, 10, 0], 'rows') | ...
                 ismember(wl.WL.TrialData.TargetPosition(1:num_trials, :), [5, 10, 0], 'rows');
practiceTrials = contains(wl.WL.TrialData.block_name(1:num_trials), {'Sprac', 'Fprac'}, 'IgnoreCase', true);
fullVisualTrials = contains(wl.WL.TrialData.block_name(1:num_trials), {'Svis', 'Fvis'}, 'IgnoreCase', true);
actualExperimentTrials = ~(shiftedTargets | practiceTrials | fullVisualTrials);

% Filter data
filteredJumpDistances = wl.WL.TrialData.JumpDistance(actualExperimentTrials);
filteredRobotPositions = wl.RobotPosition(actualExperimentTrials, :, :);
filteredVelocities = wl.RobotVelocity(actualExperimentTrials, :, :);
filteredTimestamps = wl.TimeStamp(actualExperimentTrials, :);

% Initialize arrays for movement duration and peak speed
numFilteredTrials = sum(actualExperimentTrials);
movementDurations = NaN(numFilteredTrials, 1);
peakSpeeds = NaN(numFilteredTrials, 1);

% Ensure filteredJumpDistances is a column vector
filteredJumpDistances = filteredJumpDistances(:);

% Loop through filtered trials
for trialIdx = 1:numFilteredTrials
    % Extract relevant trial data
    velocity = squeeze(filteredVelocities(trialIdx, :, :)); % Velocity (2D array)
    timestamps = filteredTimestamps(trialIdx, 1:size(velocity, 2)); % Timestamps for this trial

    % Compute speed as magnitude of velocity
    speed = sqrt(velocity(1, :).^2 + velocity(2, :).^2)';

    % Smooth speed to reduce noise
    speed = movmean(speed, 10);

    % Find start and end of movement using velocity criteria
    startIdx = find(speed > 2, 1, 'first'); % Start of movement
    if isempty(startIdx), continue; end % Skip trial if no start found

    endIdx = find(speed < 2 & (1:length(speed))' > startIdx, 1, 'first'); % End of movement
    if isempty(endIdx), continue; end % Skip trial if no end found

    % Compute movement duration and peak speed
    movementDurations(trialIdx) = timestamps(endIdx) - timestamps(startIdx); % Movement duration in seconds
    peakSpeeds(trialIdx) = max(speed(startIdx:endIdx)); % Peak speed during the movement
end

% Get unique jump distances for analysis
uniqueJumpDistances = unique(filteredJumpDistances);

% Compute mean values for plotting
meanDurations = arrayfun(@(jd) mean(movementDurations(filteredJumpDistances == jd), 'omitnan'), uniqueJumpDistances);
meanPeakSpeeds = arrayfun(@(jd) mean(peakSpeeds(filteredJumpDistances == jd), 'omitnan'), uniqueJumpDistances);

% Plot movement duration vs. jump distance
figure;
plot(uniqueJumpDistances, meanDurations, '-o', 'LineWidth', 2);
xlabel('Jump Distance (cm)');
ylabel('Movement Duration (s)');
title('Movement Duration vs. Jump Distance');
grid on;

% Plot peak speed vs. jump distance
figure;
plot(uniqueJumpDistances, meanPeakSpeeds, '-o', 'LineWidth', 2);
xlabel('Jump Distance (cm)');
ylabel('Peak Speed (cm/s)');
title('Peak Speed vs. Jump Distance');
grid on;
