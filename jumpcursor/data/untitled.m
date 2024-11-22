% Step 0: Define participant files
participantFiles = dir('pp*.mat');  % Adjust directory path if needed

% Initialize empty arrays for storing data
allCorrections = [];
allJumpDistances = [];
allSpeedLabels = [];
allParticipantIDs = [];

% Loop through each participant file
for participantIdx = 1:length(participantFiles)
    % Load participant data
    wl = load(participantFiles(participantIdx).name);

    % Total number of trials in TrialData and RobotPosition
    num_trialdata_trials = size(wl.WL.TrialData.TargetPosition, 1);
    num_robot_trials = size(wl.RobotPosition, 1);

    % Use the smaller size to avoid mismatches
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

    % Extract corrections for the filtered trials
    corrections = extractCorrections(wl, actualExperimentTrials);

    % Extract other relevant data
    jumpDistances = wl.WL.TrialData.JumpDistance(actualExperimentTrials);
    speedLabels = wl.WL.TrialData.SpeedCue(actualExperimentTrials);

    % Append data to the main arrays
    allCorrections = [allCorrections; corrections];
    allJumpDistances = [allJumpDistances; jumpDistances];
    allSpeedLabels = [allSpeedLabels; speedLabels];

    % Append participant ID for each trial
    allParticipantIDs = [allParticipantIDs; repmat(participantIdx, sum(actualExperimentTrials), 1)];
end

% Display participant IDs to ensure proper assignment
disp(unique(allParticipantIDs));

% Function to calculate correction magnitudes
function corrections = extractCorrections(wl, trialFilter)
    % Number of trials
    num_trials = sum(trialFilter);
    corrections = NaN(num_trials, 1);

    % Filtered indices
    filteredIdx = find(trialFilter);

    % Loop through filtered trials
    for i = 1:num_trials
        trial = filteredIdx(i);

        % Extract X and Y positions
        x = squeeze(wl.RobotPosition(trial, 1, 1:wl.Samples(trial)));
        y = squeeze(wl.RobotPosition(trial, 2, 1:wl.Samples(trial)));

        % Final hand position
        finalHandPos = [x(end), y(end)];

        % Target position
        target_pos = wl.WL.TrialData.TargetPosition(trial, 1:2);

        % Correction relative to target (in x-direction)
        corrections(i) = finalHandPos(1) - target_pos(1);
    end
end
