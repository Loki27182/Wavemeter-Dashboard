clear
clc

% run = 0;
% reps = 0:99;

% run = 1;
% reps = 0:99;

% run = 19;
% reps = 0:99;

% run = 30;
% reps = 0:99;

% run = 31;
% reps = 0:99;
% tt0 = 0.16;
% tts = 0.02;

% run = 32;
% reps = 0:99;
% tt0 = 0.155;
% tts = 0.03;

% run = 33;
% reps = 0:99;
% tt0 = 0.155;
% tts = 0.03;

run = 34;
reps = 0:99;
tt0 = 0.155;
tts = 0.03;

% runs = [43,44,45,46];
% exp0 = [100,50,20,1];

for ii = length(reps):-1:1
name_ii = ['run_' num2str(run,'%d') '/run_' num2str(run,'%d') '_rep_' num2str(reps(ii),'%d')];
loc = 'northwest';
t_toggle{ii} = readmatrix([name_ii '.csv'],'Range','A6:B7');
end

dt_toggle_1 = cellfun(@(x) x(2,1),t_toggle);
dt_toggle_2 = cellfun(@(x) x(2,2),t_toggle);

if all(dt_toggle_1>0)%t_toggle(1,1) + t_toggle(2,1) > 0
    plot(tt0+tts*(0:length(dt_toggle_1)-1)/length(dt_toggle_1),dt_toggle_1*1000,'.')
    xlabel('Delay before switch (s)')
    ylabel('Switching time (ms)','FontSize',14)
    % ylabel('Count','FontSize',14)
    title('Fiber switching delay','FontSize',18)
    print(['run_' num2str(run) '_fs_delays.png'],'-dpng')
end
if all(dt_toggle_2>0)%t_toggle(1,2) + t_toggle(2,2) > 0
    histogram(dt_toggle_2*1000)
    xlabel('Switching time (ms)','FontSize',14)
    ylabel('Count','FontSize',14)
    title('Exposure setting delay','FontSize',18)
    print(['run_' num2str(run) '_exp_delays.png'],'-dpng')
end