clear all; close all;

 load('Pieter.mat');

pre_samples = 400;
post_samples = 0;

for trial = 1:130
index = find((State(trial,:) == 0) | (State(trial,:)==11), 1,'first'); % this needs to be based on the photodiode
index = index-1;
vx(trial,:) = squeeze(RobotVelocity(trial,1,(index-pre_samples):(index+post_samples)));
vy(trial,:) = squeeze(RobotVelocity(trial,2,(index-pre_samples):(index+post_samples)));
px(trial,:) = squeeze(RobotPosition(trial,1,(index-pre_samples):(index+post_samples)));
py(trial,:) = squeeze(RobotPosition(trial,2,(index-pre_samples):(index+post_samples)));


t(trial,:) = TimeStamp(trial,(index-pre_samples):(index+post_samples))-TimeStamp(trial,index);

end


% here some tricks to split based on the jump magnitude (can also be done
% in a for loop
figure
subplot(2,2,1)
trials = find(TrialData.JumpDistance ==0);
plot(t(trials,:)',vx(trials,:)','color',[0.5 0.5 0.5]);ylabel('v_x');  xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==-8);
plot(t(trials,:)',vx(trials,:)','color','r');ylabel('v_x');  xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==+8);
plot(t(trials,:)',vx(trials,:)','color','b');ylabel('v_x');  xlabel('time relative to jump (s)');


subplot(2,2,2)
trials = find(TrialData.JumpDistance ==0);
plot(t(trials,:)',vy(trials,:)','color',[0.5 0.5 0.5]); ylabel('v_y'); xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==-8);
plot(t(trials,:)',vy(trials,:)','color','r');ylabel('v_y');  xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==+8);
plot(t(trials,:)',vy(trials,:)','color','b');ylabel('v_y');  xlabel('time relative to jump (s)');

subplot(2,2,3)
trials = find(TrialData.JumpDistance ==0);
plot(t(trials,:)',px(trials,:)','color',[0.5 0.5 0.5]);ylabel('p_x');  xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==-8);
plot(t(trials,:)',px(trials,:)','color','r');ylabel('p_x');  xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==+8);
plot(t(trials,:)',px(trials,:)','color','b');ylabel('p_x');  xlabel('time relative to jump (s)');


subplot(2,2,4)
trials = find(TrialData.JumpDistance ==0);
plot(t(trials,:)',py(trials,:)','color',[0.5 0.5 0.5]); ylabel('p_y'); xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==-8);
plot(t(trials,:)',py(trials,:)','color','r');ylabel('p_y');  xlabel('time relative to jump (s)');
hold on;
trials = find(TrialData.JumpDistance ==+8);
plot(t(trials,:)',py(trials,:)','color','b');ylabel('p_y');  xlabel('time relative to jump (s)');

