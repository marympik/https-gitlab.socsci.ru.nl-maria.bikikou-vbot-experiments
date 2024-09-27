% Extract Movement Duration for Fast and Slow Trials
fastDuration = WL.TrialData.MovementDuration(strcmp(WL.TrialData.SpeedCue, 'fast'));
slowDuration = WL.TrialData.MovementDuration(strcmp(WL.TrialData.SpeedCue, 'slow'));

% Plot Movement Duration
figure;
plot(fastDuration, 'r-o', 'LineWidth', 2);
hold on;
plot(slowDuration, 'b-o', 'LineWidth', 2);
xlabel('Trial Number');
ylabel('Movement Duration (s)');
title('Movement Duration for Fast and Slow Trials');
legend('Fast Trials', 'Slow Trials');
grid on;

% Extract Accuracy for Fast and Slow Trials
fastAccuracy = WL.TrialData.Accuracy(strcmp(WL.TrialData.SpeedCue, 'fast'));
slowAccuracy = WL.TrialData.Accuracy(strcmp(WL.TrialData.SpeedCue, 'slow'));

% Plot Accuracy
figure;
plot(fastAccuracy, 'r-o', 'LineWidth', 2);
hold on;
plot(slowAccuracy, 'b-o', 'LineWidth', 2);
xlabel('Trial Number');
ylabel('Accuracy (Distance to Target)');
title('Movement Accuracy for Fast and Slow Trials');
legend('Fast Trials', 'Slow Trials');
grid on;

% Extract Correction Magnitude for Fast and Slow Trials
fastCorrection = WL.TrialData.CorrectionMagnitude(strcmp(WL.TrialData.SpeedCue, 'fast'));
slowCorrection = WL.TrialData.CorrectionMagnitude(strcmp(WL.TrialData.SpeedCue, 'slow'));

% Plot Correction Magnitude
figure;
plot(fastCorrection, 'r-o', 'LineWidth', 2);
hold on;
plot(slowCorrection, 'b-o', 'LineWidth', 2);
xlabel('Trial Number');
ylabel('Correction Magnitude');
title('Correction Magnitude for Fast and Slow Trials');
legend('Fast Trials', 'Slow Trials');
grid on;

% Extract Reaction Time for Fast and Slow Trials
fastReactionTimes = WL.TrialData.ReactionTime(strcmp(WL.TrialData.SpeedCue, 'fast'));
slowReactionTimes = WL.TrialData.ReactionTime(strcmp(WL.TrialData.SpeedCue, 'slow'));

% Plot Reaction Times
figure;
plot(fastReactionTimes, 'r-o', 'LineWidth', 2);
hold on;
plot(slowReactionTimes, 'b-o', 'LineWidth', 2);
xlabel('Trial Number');
ylabel('Reaction Time (s)');
title('Reaction Time for Fast and Slow Trials');
legend('Fast Trials', 'Slow Trials');
grid on;

%%
wl = load('data\pilotme.mat');

plot_trajectory(wl, 99);


function plot_trajectory(wl, trial_number)

    x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
    y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));

    plot(squeeze(x), squeeze(y));
    xlim(sort(wl.WL.cfg.graphics_config.Xmin_Xmax));
    ylim(sort(wl.WL.cfg.graphics_config.Ymin_Ymax));
    shg;

end
