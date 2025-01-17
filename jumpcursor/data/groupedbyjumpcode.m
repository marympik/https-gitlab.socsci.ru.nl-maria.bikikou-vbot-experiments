% Load the data
wl = load('pp01.mat');

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

% Plot for Fast Trials
plotTrajectoriesWithStartEnd(fastJumpDistances, fastHandTrajectories, 'Fast', 'b', wl);

% Plot for Slow Trials
plotTrajectoriesWithStartEnd(slowJumpDistances, slowHandTrajectories, 'Slow', 'r', wl);

%% Function Definitions
function [startIdx, endIdx] = getMovementIndices(velocity, thresholdStart, thresholdEnd)
    % Identify movement start and end indices based on velocity thresholds
    startIdx = find(velocity > thresholdStart, 1, 'first');
    if ~isempty(startIdx)
        endIdx = find(velocity(startIdx:end) < thresholdEnd, 1, 'first');
        if ~isempty(endIdx)
            endIdx = startIdx + endIdx - 1; % Adjust endIdx to match full array indexing
        else
            endIdx = length(velocity); % If no end is found, assume movement ends at the last sample
        end
    else
        startIdx = []; % No valid start
        endIdx = [];
    end
end

function plotTrajectoriesWithStartEnd(jumpDistances, handTrajectories, titlePrefix, color, wl)
    % Define velocity thresholds
    velocityOnsetThreshold = 2;  % Threshold for movement start (cm/s)
    velocityOffsetThreshold = 2; % Threshold for movement end (cm/s)

    uniqueJumpDistances = unique(jumpDistances);
    num_jumps = length(uniqueJumpDistances);
    rows = ceil(sqrt(num_jumps)); % Rows for subplots
    cols = ceil(num_jumps / rows); % Columns for subplots

    figure;
    for i = 1:num_jumps
        jumpDistance = uniqueJumpDistances(i);
        idx = (jumpDistances == jumpDistance);

        subplot(rows, cols, i);
        hold on;
        for trialIdx = find(idx)'
            % Extract X and Y positions of the hand
            x = squeeze(handTrajectories(trialIdx, 1, :));
            y = squeeze(handTrajectories(trialIdx, 2, :));

            % Calculate velocity magnitude
            vx = squeeze(wl.RobotVelocity(trialIdx, 1, :));
            vy = squeeze(wl.RobotVelocity(trialIdx, 2, :));
            speed = sqrt(vx.^2 + vy.^2);

            % Get movement start and end indices
            [movementStartIdx, movementEndIdx] = getMovementIndices(speed, velocityOnsetThreshold, velocityOffsetThreshold);

            % Plot the trajectory only within the movement duration
            if ~isempty(movementStartIdx) && ~isempty(movementEndIdx)
                plot(x(movementStartIdx:movementEndIdx), y(movementStartIdx:movementEndIdx), color); % Plot in specified color
            end
        end
        hold off;
        title([titlePrefix, ' - Jump Distance: ', num2str(jumpDistance), ' cm']);
        xlabel('X Position (cm)');
        ylabel('Y Position (cm)');
        grid on;
    end
    sgtitle(['Hand Trajectories for ', titlePrefix, ' Trials']);
end
