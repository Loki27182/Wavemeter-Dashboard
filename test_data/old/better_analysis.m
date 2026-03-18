clear
clc

for ii = 0:9
name = ['dt_100us_single_toggle' num2str(ii)];
loc = 'northwest';

if size(readmatrix([name '.csv'],'Range','A6:B8'),1)==2
    t_toggle = readmatrix([name '.csv'],'Range','A6:B7');
    data = readmatrix([name '.csv'],'NumHeaderLines',9);
else
    t_toggle = [0,0;0,0];
    data = readmatrix([name '.csv'],'NumHeaderLines',5);
end

t = data(:,1);
f = data(:,2);
df = [1;diff(f)];
mask = df~=0;
t_update = t(mask);
f_update = f(mask);

figure(1)
subplot(2,1,1)
plot(t,f,'.',t_update,f_update,'d')
xlabel('Time (s)','FontSize',14)
ylabel('Frequency (MHz)','FontSize',14)
legend('All data','Reading update','Location',loc)
xlim([0,max(t)])

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
if all(t_toggle(:,1)==0)
    xlim([min(t),max(t)])
else
    xlim([t_toggle(1,1)-2*t_toggle(2,1),t_toggle(1,1)+3*t_toggle(2,1)])
end
% xlim([1.9,2.2])
ylim([min(f)-(max(f)-min(f))/6,max(f)+(max(f)-min(f))/6])
print([name 'zoom.png'],'-dpng')

sw_delay(ii+1) = t_toggle(2,1);
end
%%
figure(4)
histogram(sw_delay)