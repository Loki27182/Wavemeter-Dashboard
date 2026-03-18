clear
clc

runs = 43:46;
reps = 0:99;
exp_set = [100,50,20,1];
titles = arrayfun(@(x) string(['$t_\mathrm{exp} = ' num2str(x,'%d') '$ ms']),exp_set);

for ii = length(runs):-1:1%length(runs)
    run = runs(ii);
    for jj = length(reps):-1:1%length(reps)
        rep = reps(jj);
        fn = ['run_' num2str(run,'%d') '\run_' num2str(run,'%d') '_rep_' num2str(rep,'%d') '.csv'];
        if exist(fn,'file')
            tog_ii = cumsum(readmatrix(fn,'Range','A6:B7'),1);
            data_ii = readmatrix(fn,'NumHeaderLines',9);

            t_on(ii,jj) = data_ii(find(data_ii(:,2)>data_ii(:,2)*0.9,1),1);
            tog(ii,jj,:,:) = tog_ii;
            data{ii,jj} = data_ii;
            exp_setting_delay(ii,jj) = t_on(ii,jj) - tog_ii(1,2);
        end
    end
    ii
end
%%
co = colororder;
alpha = 1.85;
beta = 2;
histogram(exp_setting_delay(1,:)*1e3,linspace(0,220,40))
hold on
histogram(exp_setting_delay(2,:)*1e3,linspace(0,220,40))
histogram(exp_setting_delay(3,:)*1e3,linspace(0,220,40))
histogram(exp_setting_delay(4,:)*1e3,linspace(0,220,40))
hold off
xline(mean(exp_setting_delay(1,:)*1e3),':','Color',co(1,:),'LineWidth',2)
xline(exp_set(1)*alpha,'--','Color',co(1,:),'LineWidth',2)
xline(exp_set(1)*beta,'--','Color',co(1,:),'LineWidth',2)
xline(mean(exp_setting_delay(2,:)*1e3),':','Color',co(2,:),'LineWidth',2)
xline(exp_set(2)*alpha,'--','Color',co(2,:),'LineWidth',2)
xline(exp_set(2)*beta,'--','Color',co(2,:),'LineWidth',2)
xline(mean(exp_setting_delay(3,:)*1e3),':','Color',co(3,:),'LineWidth',2)
xline(exp_set(3)*alpha,'--','Color',co(3,:),'LineWidth',2)
xline(exp_set(3)*beta,'--','Color',co(3,:),'LineWidth',2)
xline(mean(exp_setting_delay(4,:)*1e3),':','Color',co(4,:),'LineWidth',2)
xline(exp_set(4)*alpha,'--','Color',co(4,:),'LineWidth',2)
xline(exp_set(4)*beta,'--','Color',co(4,:),'LineWidth',2)
xlabel('Delay (ms)','FontSize',14)
ylabel('Counts','FontSize',14)
legend('100 ms (over)exposure','50 ms (over)exposure','20 ms (over)exposure','1 ms (under)exposure',...
    '100 ms $\times$ 2 $\times \{0.9,1.0\}$','',...
    '50 ms $\times$ 2 $\times \{0.9,1.0\}$','',...
    '20 ms $\times$ 2 $\times \{0.9,1.0\}$','',...
    '1 ms $\times$ 2 $\times \{0.9,1.0\}$','',...
    'location','northeast','FontSize',10)
title({'Delay from wavemeter exposure change','to end of over/under-exposure'},'FontSize',16)
ylim([0,100])
% print('runs_43_to_46_composite_histogram.emf','-dmeta')

%%
data_ii = data{end-1,1};
t = data_ii(:,1);
f = data_ii(:,2);
f(f<0) = f(f<0)*20e6;
t_on = t(find(f>4e8,1));
tog_ii = squeeze(tog(1,1,:,:));
t_log = min(t(t>=max(tog_ii(:))));
plot(t,f/1e6,'.','LineWidth',1.5)
xline(tog_ii(3),'--k','LineWidth',1.5)
xline(tog_ii(4),':k','LineWidth',1.5)
xline(t_log,':r','LineWidth',1.5)
xline(t_on,'--r','LineWidth',1.5)
xlim([.655,.725])
xlabel('Time (s)','FontSize',14)
ylabel('Frequency (MHz)','FontSize',14)
legend('Data','Wavelength change command','Command finishes','Wavemeter resumes responding to requests','Readings at the new exposure time start','FontSize',12,'location','east')
% print('run_45_close_up.emf','-dmeta')
%%
for ii = size(data,1):-1:1
    for jj = size(data,2):-1:1
        data_ii = data{ii,jj};
        t = data_ii(:,1);
        f = data_ii(:,2);
        f(f<0) = f(f<0)*20e6;
        t_on(ii,jj) = t(find(f>4e8,1));
        tog_ii = squeeze(tog(1,1,:,:));
        t_log(ii,jj) = min(t(t>=max(tog_ii(:))));
    end
end
%%
co = colororder;
alpha = 1.85;
beta = 2;

subplot(2,2,1)
histogram(t_log(1,:)*1e3 - tog(1,:,1,2)*1e3,linspace(0,12,40))
ylim([0,60])
xlabel('Delay (ms)')
ylabel('Counts')
title('100 ms exposure')
subplot(2,2,2)
histogram(t_log(2,:)*1e3 - tog(2,:,1,2)*1e3,linspace(0,12,40))
ylim([0,60])
xlabel('Delay (ms)')
ylabel('Counts')
title('50 ms exposure')
subplot(2,2,3)
histogram(t_log(3,:)*1e3 - tog(3,:,1,2)*1e3,linspace(0,12,40))
ylim([0,60])
xlabel('Delay (ms)')
ylabel('Counts')
title('20 ms exposure')
subplot(2,2,4)
histogram(t_log(4,:)*1e3 - tog(4,:,1,2)*1e3,linspace(0,12,40))
ylim([0,60])
xlabel('Delay (ms)')
ylabel('Counts')
title('1 ms exposure')
% print('runs_43_to_46_command_delay.emf','-dmeta')
% hold off