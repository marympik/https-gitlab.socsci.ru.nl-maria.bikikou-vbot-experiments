% Load data
wl = load('pilot04.mat');
num_trials = size(wl.TimeStamp, 1);

% Initialize arrays to store values
correctionX = NaN(num_trials, 1);  % Store signed correction in the x-direction
jumpDistances = NaN(num_trials, 1);
Speed = cell(num_trials, 1);  % Store speed category ('Fast' or 'Slow')

for trial = 1:num_trials
    % Extract target position from TrialData
    target_pos = wl.WL.TrialData.TargetPosition(trial, 1:2);  % Extracting the (x, y) target position
    
    % Extract final hand position
    x = wl.RobotPosition(trial, 1, wl.Samples(trial));
    y = wl.RobotPosition(trial, 2, wl.Samples(trial));
    finalHandPos = [x, y];  % Final hand position
    
    % Calculate correction relative to the target (in x-direction only)
    correctionX(trial) = finalHandPos(1) - target_pos(1);  % Signed correction along the x-axis
    
    % Extract jump distance for the trial
    jumpDistances(trial) = wl.TrialData.JumpDistance(trial);
    
    % Determine if the trial is a fast trial
    if strcmp(wl.TrialData.SpeedCue(trial), 'fast')
        Speed{trial} = 'Fast';
    else
        Speed{trial} = 'Slow';
    end
end

% Create a table with the data
dataTable = table(jumpDistances, correctionX, Speed, 'VariableNames', {'JumpDistance', 'Correction', 'Speed'});

% Fit the linear mixed-effects model
% Assuming we have only one participant, we won't include Participant as a random effect in this example.
formula = 'Correction ~ JumpDistance * Speed';

% Fit the model
lme = fitlme(dataTable, formula);

% Display the results
disp(lme);
