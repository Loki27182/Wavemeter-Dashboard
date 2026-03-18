clear
clc
% 
% name = 'dt_1ms_no_toggle';
% toggle = false;
% loc = 'northeast';
% 
% name = 'dt_1ms_single_toggle';
% toggle = true;
% loc = 'northwest';

% name = 'dt_1ms_single_toggle_2';
% toggle = true;
% loc = 'northwest';

% for ii = 3:12
% name = ['dt_1ms_single_toggle_' num2str(ii)];
% toggle = true;
% loc = 'northwest';

% name = 'dt_1ms_single_toggle_8';
% toggle = true;
% loc = 'northwest';

if ~toggle
    a = readmatrix([name '.csv'],'NumHeaderLines',5);
else
    a = readmatrix([name '.csv'],'NumHeaderLines',9);
    t_toggle = readmatrix([name '.csv'],'NumHeaderLines',5);
    t_toggle = t_toggle(1:2,:);
end

t = a(:,1);
f = a(:,2);


figure(1)
df = [1;diff(f)];
mask = df~=0;
t_update = t(mask);
f_update = f(mask);
subplot(2,1,1)
plot(t,f,'.',t_update,f_update,'d')
xlabel('Time (s)','FontSize',14)
ylabel('Frequency (MHz)','FontSize',14)
legend('All data','Reading update','Location',loc)
xlim([0,3])

dt_update = diff(t_update);
subplot(2,1,2)
histogram(dt_update*1000,50)
xlabel('Update duration (ms)','FontSize',14)
ylabel('Counts','FontSize',14)
set(gcf,'Position',[258,915,500,500])
print([name '.png'],'-dpng')


figure(3)
plot(t,f,'.',t_update,f_update,'d',t_toggle(1,1)*[1,1],[0,max(f)*2],'--k',sum(t_toggle(:,1),1)*[1,1],[0,max(f)*2],'--k','LineWidth',1.5)
xlabel('Time (s)','FontSize',14)
ylabel('Frequency (MHz)','FontSize',14)
legend('All data','Reading update','Location','southeast')
xlim([0,3])
xlim([1.9,2.2])
ylim([min(f)-(max(f)-min(f))/6,max(f)+(max(f)-min(f))/6])
print([name 'zoom.png'],'-dpng')
% end