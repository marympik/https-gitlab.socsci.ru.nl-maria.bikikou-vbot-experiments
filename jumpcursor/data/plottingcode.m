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

% % %%
% % wl = load('data\pilotme.mat');
% wl = load('data\pilot02.mat');
% plot_fast_slow_trajectories(wl);
% 
% function plot_fast_slow_trajectories(wl)
% 
%     figure;
%     hold on;
% 
%     % Define colors for different jump sizes
%     colors = jet(length(wl.WL.cfg.possibleJumpDistances));  % Generate a colormap
% 
%     % Separate fast and slow trials
%     num_trials = size(wl.RobotPosition, 1);  % Total number of trials
% 
%     % Convert SpeedCue from cell array to numeric array if necessary
%     speedCue = cellfun(@(x) strcmp(x, 'fast'), wl.WL.TrialData.SpeedCue);  % 1 for fast, 0 for slow
% 
%     fast_trials = find(speedCue == 1);  % Fast trials
%     slow_trials = find(speedCue == 0);  % Slow trials
% 
%     % Plot fast trials
%     subplot(1, 2, 1);  % Left plot for fast trials
%     title('Fast Trials');
%     xlabel('X Position');
%     ylabel('Y Position');
%     hold on;
%     for i = 1:length(fast_trials)
%         trial_number = fast_trials(i);
%         x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
%         y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));
% 
%         % Get jump size and assign color
%         jump_size = wl.WL.TrialData.JumpDistance(trial_number);
%         color_idx = find(wl.WL.cfg.possibleJumpDistances == jump_size);  % Find the index of jump size
%         plot(squeeze(x), squeeze(y), 'Color', colors(color_idx, :), 'LineWidth', 2);
%     end
%     legend(arrayfun(@(x) sprintf('Jump Size: %d', x), wl.WL.cfg.possibleJumpDistances, 'UniformOutput', false));
%     grid on;
% 
%     % Plot slow trials
%     subplot(1, 2, 2);  % Right plot for slow trials
%     title('Slow Trials');
%     xlabel('X Position');
%     ylabel('Y Position');
%     hold on;
%     for i = 1:length(slow_trials)
%         trial_number = slow_trials(i);
%         x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
%         y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));
% 
%         % Get jump size and assign color
%         jump_size = wl.WL.TrialData.JumpDistance(trial_number);
%         color_idx = find(wl.WL.cfg.possibleJumpDistances == jump_size);  % Find the index of jump size
%         plot(squeeze(x), squeeze(y), 'Color', colors(color_idx, :), 'LineWidth', 2);
%     end
%     legend(arrayfun(@(x) sprintf('Jump Size: %d', x), wl.WL.cfg.possibleJumpDistances, 'UniformOutput', false));
%     grid on;
% 
%     hold off;
% end
% 
% % 
% % plot_trajectory(wl, 99);
% 
% 
% function plot_trajectory(wl, trial_number)
% 
%     x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
%     y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));
% 
%     plot(squeeze(x), squeeze(y));
%     xlim(sort(wl.WL.cfg.graphics_config.Xmin_Xmax));
%     ylim(sort(wl.WL.cfg.graphics_config.Ymin_Ymax));
%     shg;
% 
% end

wl = load('data\pilot02.mat');
plot_fast_slow_trajectories(wl);

function plot_fast_slow_trajectories(wl)

    figure;
    hold on;

    % Define colors for different jump sizes
    colors = jet(length(wl.WL.cfg.possibleJumpDistances));  % Generate a colormap

    % Separate fast and slow trials
    num_trials = size(wl.RobotPosition, 1);  % Total number of trials

    % Convert SpeedCue from cell array to numeric array if necessary
    speedCue = cellfun(@(x) strcmp(x, 'fast'), wl.WL.TrialData.SpeedCue);  % 1 for fast, 0 for slow

    fast_trials = find(speedCue == 1);  % Fast trials
    slow_trials = find(speedCue == 0);  % Slow trials

    % Plot fast trials
    subplot(1, 2, 1);  % Left plot for fast trials
    title('Fast Trials');
    xlabel('X Position');
    ylabel('Y Position');
    hold on;
    for i = 1:length(fast_trials)
        trial_number = fast_trials(i);
        x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
        y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));

        % Get jump size and assign color
        jump_size = wl.WL.TrialData.JumpDistance(trial_number);
        color_idx = find(wl.WL.cfg.possibleJumpDistances == jump_size);  % Find the index of jump size
        plot(squeeze(x), squeeze(y), 'Color', colors(color_idx, :), 'LineWidth', 2);
    end
    legend(arrayfun(@(x) sprintf('Jump Size: %d', x), wl.WL.cfg.possibleJumpDistances, 'UniformOutput', false));
    grid on;

    % Plot slow trials
    subplot(1, 2, 2);  % Right plot for slow trials
    title('Slow Trials');
    xlabel('X Position');
    ylabel('Y Position');
    hold on;
    for i = 1:length(slow_trials)
        trial_number = slow_trials(i);
        x = wl.RobotPosition(trial_number, 1, 1:wl.Samples(trial_number));
        y = wl.RobotPosition(trial_number, 2, 1:wl.Samples(trial_number));

        % Get jump size and assign color
        jump_size = wl.WL.TrialData.JumpDistance(trial_number);
        color_idx = find(wl.WL.cfg.possibleJumpDistances == jump_size);  % Find the index of jump size
        plot(squeeze(x), squeeze(y), 'Color', colors(color_idx, :), 'LineWidth', 2);
    end
    legend(arrayfun(@(x) sprintf('Jump Size: %d', x), wl.WL.cfg.possibleJumpDistances, 'UniformOutput', false));
    grid on;

    % Set the same y-axis limits for both subplots
    subplot(1, 2, 1);  % Focus on fast trials plot
    ylims = ylim();  % Get the y-axis limits from the fast trial plot

    subplot(1, 2, 2);  % Focus on slow trials plot
    ylim(ylims);  % Apply the same y-axis limits to the slow trials plot

    hold off;
end




