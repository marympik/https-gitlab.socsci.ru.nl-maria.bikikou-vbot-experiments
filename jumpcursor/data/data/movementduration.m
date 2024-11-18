% Filter trials for the actual experiment
actualExperimentTrials = ~strcmp(wl.TrialData.block_short, 'Sprac') & ...
                          ~strcmp(wl.TrialData.block_short, 'Fprac') & ...
                          ~strcmp(wl.TrialData.block_short, 'Svis') & ...
                          ~strcmp(wl.TrialData.block_short, 'Fvis');

experimentJumpDistances = wl.TrialData.JumpDistance(actualExperimentTrials);

% Initialize movement duration array
movementDurations = zeros(sum(actualExperimentTrials), 1);

% Define velocity thresholds
velocityOnsetThreshold = 2;  % Threshold for movement start
velocityOffsetThreshold = 2; % Threshold for movement end

% Loop through trials
trialIdx = 1;
for trialNumber = find(actualExperimentTrials)'
    % Extract timestamps, velocities, and calculate speed
    timeStamps = wl.TimeStamp(trialNumber, 1:wl.Samples(trialNumber));
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed); % Adjust speed to remove offset

    % Find movement start and end indices
    movementStartIdx = find(speed > velocityOnsetThreshold, 1, 'first');
    if ~isempty(movementStartIdx)
        [~, peakVelocityIdx] = max(speed(movementStartIdx:end));
        peakVelocityIdx = peakVelocityIdx + movementStartIdx - 1;
        movementEndIdx = find(speed < velocityOffsetThreshold & (1:length(timeStamps))' > peakVelocityIdx, 1, 'first');
        if isempty(movementEndIdx) || movementEndIdx > length(timeStamps)
            movementEndIdx = length(timeStamps);
        end

        % Calculate movement duration
        if ~isempty(movementStartIdx) && ~isempty(movementEndIdx)
            movementDurations(trialIdx) = timeStamps(movementEndIdx) - timeStamps(movementStartIdx);
        end
    end
    trialIdx = trialIdx + 1;
end

% Calculate average movement duration for each jump distance
uniqueJumps = unique(experimentJumpDistances);
averageDurations = arrayfun(@(jump) mean(movementDurations(experimentJumpDistances == jump)), uniqueJumps);

% Plot Movement Duration vs. Jump Distance
figure;
plot(uniqueJumps, averageDurations, '-o');
xlabel('Jump Distance (cm)');
ylabel('Average Movement Duration (s)');
title('Movement Duration vs. Jump Distance');
grid on;

%peak velocity vs jumpdistance
% Initialize peak speed array
peakSpeeds = zeros(sum(actualExperimentTrials), 1);

% Loop through trials
trialIdx = 1;
for trialNumber = find(actualExperimentTrials)'
    % Extract timestamps, velocities, and calculate speed
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed); % Adjust speed to remove offset

    % Calculate peak speed
    peakSpeeds(trialIdx) = max(speed);
    trialIdx = trialIdx + 1;
end

% Calculate average peak speed for each jump distance
averageSpeeds = arrayfun(@(jump) mean(peakSpeeds(experimentJumpDistances == jump)), uniqueJumps);

% Plot Peak Speed vs. Jump Distance
figure;
plot(uniqueJumps, averageSpeeds, '-o');
xlabel('Jump Distance (cm)');
ylabel('Average Peak Speed (cm/s)');
title('Peak Speed vs. Jump Distance');
grid on;

%movementduration fast vs slow 
% Filter trials for the actual experiment
actualExperimentTrials = ~strcmp(wl.TrialData.block_short, 'Sprac') & ...
                          ~strcmp(wl.TrialData.block_short, 'Fprac') & ...
                          ~strcmp(wl.TrialData.block_short, 'Svis') & ...
                          ~strcmp(wl.TrialData.block_short, 'Fvis');

experimentJumpDistances = wl.TrialData.JumpDistance(actualExperimentTrials);

% Initialize movement duration array
movementDurations = zeros(sum(actualExperimentTrials), 1);

% Define velocity thresholds
velocityOnsetThreshold = 2;  % Threshold for movement start
velocityOffsetThreshold = 2; % Threshold for movement end

% Loop through trials
trialIdx = 1;
for trialNumber = find(actualExperimentTrials)'
    % Extract timestamps, velocities, and calculate speed
    timeStamps = wl.TimeStamp(trialNumber, 1:wl.Samples(trialNumber));
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed); % Adjust speed to remove offset

    % Find movement start and end indices
    movementStartIdx = find(speed > velocityOnsetThreshold, 1, 'first');
    if ~isempty(movementStartIdx)
        [~, peakVelocityIdx] = max(speed(movementStartIdx:end));
        peakVelocityIdx = peakVelocityIdx + movementStartIdx - 1;
        movementEndIdx = find(speed < velocityOffsetThreshold & (1:length(timeStamps))' > peakVelocityIdx, 1, 'first');
        if isempty(movementEndIdx) || movementEndIdx > length(timeStamps)
            movementEndIdx = length(timeStamps);
        end

        % Calculate movement duration
        if ~isempty(movementStartIdx) && ~isempty(movementEndIdx)
            movementDurations(trialIdx) = timeStamps(movementEndIdx) - timeStamps(movementStartIdx);
        end
    end
    trialIdx = trialIdx + 1;
end

% Calculate average movement duration for each jump distance
uniqueJumps = unique(experimentJumpDistances);
averageDurations = arrayfun(@(jump) mean(movementDurations(experimentJumpDistances == jump)), uniqueJumps);

% Plot Movement Duration vs. Jump Distance
figure;
plot(uniqueJumps, averageDurations, '-o');
xlabel('Jump Distance (cm)');
ylabel('Average Movement Duration (s)');
title('Movement Duration vs. Jump Distance');
grid on;

% Initialize peak speed array
peakSpeeds = zeros(sum(actualExperimentTrials), 1);

% Loop through trials
trialIdx = 1;
for trialNumber = find(actualExperimentTrials)'
    % Extract timestamps, velocities, and calculate speed
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed); % Adjust speed to remove offset

    % Calculate peak speed
    peakSpeeds(trialIdx) = max(speed);
    trialIdx = trialIdx + 1;
end

% Calculate average peak speed for each jump distance
averageSpeeds = arrayfun(@(jump) mean(peakSpeeds(experimentJumpDistances == jump)), uniqueJumps);

% Plot Peak Speed vs. Jump Distance
figure;
plot(uniqueJumps, averageSpeeds, '-o');
xlabel('Jump Distance (cm)');
ylabel('Average Peak Speed (cm/s)');
title('Peak Speed vs. Jump Distance');
grid on;

% Filter trials for fast and slow conditions
fastTrials = strcmp(wl.TrialData.block_short, 'F');
slowTrials = strcmp(wl.TrialData.block_short, 'S');

% Initialize movement duration arrays for fast and slow
movementDurationsFast = zeros(sum(fastTrials), 1);
movementDurationsSlow = zeros(sum(slowTrials), 1);

% Define velocity thresholds
velocityOnsetThreshold = 2;  % Threshold for movement start
velocityOffsetThreshold = 2; % Threshold for movement end

% Calculate movement durations for fast trials
trialIdx = 1;
for trialNumber = find(fastTrials)'
    timeStamps = wl.TimeStamp(trialNumber, 1:wl.Samples(trialNumber));
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed);

    movementStartIdx = find(speed > velocityOnsetThreshold, 1, 'first');
    if ~isempty(movementStartIdx)
        [~, peakVelocityIdx] = max(speed(movementStartIdx:end));
        peakVelocityIdx = peakVelocityIdx + movementStartIdx - 1;
        movementEndIdx = find(speed < velocityOffsetThreshold & (1:length(timeStamps))' > peakVelocityIdx, 1, 'first');
        if isempty(movementEndIdx) || movementEndIdx > length(timeStamps)
            movementEndIdx = length(timeStamps);
        end

        if ~isempty(movementStartIdx) && ~isempty(movementEndIdx)
            movementDurationsFast(trialIdx) = timeStamps(movementEndIdx) - timeStamps(movementStartIdx);
        end
    end
    trialIdx = trialIdx + 1;
end

% Calculate movement durations for slow trials
trialIdx = 1;
for trialNumber = find(slowTrials)'
    timeStamps = wl.TimeStamp(trialNumber, 1:wl.Samples(trialNumber));
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed);

    movementStartIdx = find(speed > velocityOnsetThreshold, 1, 'first');
    if ~isempty(movementStartIdx)
        [~, peakVelocityIdx] = max(speed(movementStartIdx:end));
        peakVelocityIdx = peakVelocityIdx + movementStartIdx - 1;
        movementEndIdx = find(speed < velocityOffsetThreshold & (1:length(timeStamps))' > peakVelocityIdx, 1, 'first');
        if isempty(movementEndIdx) || movementEndIdx > length(timeStamps)
            movementEndIdx = length(timeStamps);
        end

        if ~isempty(movementStartIdx) && ~isempty(movementEndIdx)
            movementDurationsSlow(trialIdx) = timeStamps(movementEndIdx) - timeStamps(movementStartIdx);
        end
    end
    trialIdx = trialIdx + 1;
end

% Calculate average durations
jumpDistancesFast = wl.TrialData.JumpDistance(fastTrials);
uniqueJumpsFast = unique(jumpDistancesFast);
averageDurationsFast = arrayfun(@(jump) mean(movementDurationsFast(jumpDistancesFast == jump)), uniqueJumpsFast);

jumpDistancesSlow = wl.TrialData.JumpDistance(slowTrials);
uniqueJumpsSlow = unique(jumpDistancesSlow);
averageDurationsSlow = arrayfun(@(jump) mean(movementDurationsSlow(jumpDistancesSlow == jump)), uniqueJumpsSlow);

% Plot Movement Duration
figure;
plot(uniqueJumpsFast, averageDurationsFast, '-o', 'DisplayName', 'Fast Trials');
hold on;
plot(uniqueJumpsSlow, averageDurationsSlow, '-o', 'DisplayName', 'Slow Trials');
xlabel('Jump Distance (cm)');
ylabel('Average Movement Duration (s)');
title('Movement Duration vs. Jump Distance (Fast vs. Slow)');
legend;
grid on;
hold off;

%peak velocity and jumpdistance fast vs slow
% Initialize peak speed arrays for fast and slow
peakSpeedsFast = zeros(sum(fastTrials), 1);
peakSpeedsSlow = zeros(sum(slowTrials), 1);

% Calculate peak speeds for fast trials
trialIdx = 1;
for trialNumber = find(fastTrials)'
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed);

    peakSpeedsFast(trialIdx) = max(speed);
    trialIdx = trialIdx + 1;
end

% Calculate peak speeds for slow trials
trialIdx = 1;
for trialNumber = find(slowTrials)'
    vx = squeeze(wl.RobotVelocity(trialNumber, 1, 1:wl.Samples(trialNumber)));
    vy = squeeze(wl.RobotVelocity(trialNumber, 2, 1:wl.Samples(trialNumber)));
    speed = sqrt(vx.^2 + vy.^2);
    speed = movmean(speed, 10);
    speed = speed - min(speed);

    peakSpeedsSlow(trialIdx) = max(speed);
    trialIdx = trialIdx + 1;
end

% Calculate average peak speeds
averageSpeedsFast = arrayfun(@(jump) mean(peakSpeedsFast(jumpDistancesFast == jump)), uniqueJumpsFast);
averageSpeedsSlow = arrayfun(@(jump) mean(peakSpeedsSlow(jumpDistancesSlow == jump)), uniqueJumpsSlow);

% Plot Peak Speed
figure;
plot(uniqueJumpsFast, averageSpeedsFast, '-o', 'DisplayName', 'Fast Trials');
hold on;
plot(uniqueJumpsSlow, averageSpeedsSlow, '-o', 'DisplayName', 'Slow Trials');
xlabel('Jump Distance (cm)');
ylabel('Average Peak Speed (cm/s)');
title('Peak Speed vs. Jump Distance (Fast vs. Slow)');
legend;
grid on;
hold off;
