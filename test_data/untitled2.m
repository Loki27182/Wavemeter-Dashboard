figure(4)
co = colororder;
for ii = 1:size(data,1)
    for jj = 1:size(data,2)
        plot(data{ii,jj}(:,1),data{ii,jj}(:,2)/1e6,'Color',co(ii,:))
        if ii==1 && jj==1
            hold on
        end        
        if ii==size(data,1) && jj==size(data,2)
            hold off
        end
    end
end
xlim([.655,.9])
xlabel('Time (s)','FontSize',14)
ylabel('Frequency (THz)','FontSize',14)
print('runs_43_to_46_all_raw_data.emf','-dmeta')