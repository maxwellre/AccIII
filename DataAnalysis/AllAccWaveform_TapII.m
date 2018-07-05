%% Signal waveform of all accelerometers on hand
% Created on 07/04/2018 based on 'Index100HzSine.m'
%--------------------------------------------------------------------------
Data_Path = 'Data/Tap1to5/';
axis_label = {'X', 'Y', 'Z'};
%--------------------------------------------------------------------------
[acc_data, t, Fs ] = readAccIII([Data_Path,'data.bin'],...
    [Data_Path,'data_rate.txt'], 0);
%--------------------------------------------------------------------------
% DC-filtering
acc_data = bsxfun(@minus, acc_data,mean(acc_data,1));
disp('DC removed')
%--------------------------------------------------------------------------
if ~exist('acc_data','var')
    error('AccIII data required!');
end
%% ------------------------------------------------------------------------
disp_t_start = 1.4; % TapII
disp_t_end = 1.6; % TapII

% Display selected accelerometer signal waveform
disp_acc_i = setdiff(1:46,[10,20,30,40]);
disp_num = length(disp_acc_i);

%--------------------------------------------------------------------------
t_ind = (t >= disp_t_start) & (t <= disp_t_end);

slctChannels = zeros(sum(t_ind),disp_num,3);
proj_waveform = zeros(sum(t_ind),disp_num);
for i = 1:disp_num
    slctChannels(:,i,:) = acc_data(t_ind,disp_acc_i(i),:);

%         amp = slctChannels(:,i,1).^2 + slctChannels(:,i,2).^2 +...
%               slctChannels(:,i,3).^2;
%         [~,max_i] = max(amp);
%         proj_vector = squeeze(slctChannels(max_i,i,:));
%         proj_vector = proj_vector./norm(proj_vector);
%         proj_waveform(:,i) = squeeze(slctChannels(:,i,:))*...
%                     proj_vector;
end

yMax = max(slctChannels(:));
yMin = min(slctChannels(:));

%--------------------------------------------------------------------------
%% Display all accelerometer waveforms
offsetStep = 6.0;
figure('Position',[120,90,840,900],'Color','white')
for ax = 1:3
    subplot('Position',[0.05+0.3*(ax-1),0.04,0.28,0.92])
    hold on
    for i = 1:disp_num
        offset = -offsetStep*(i-1);
        plot(t(t_ind),slctChannels(:,i,ax)+offset,'Color',[0.3 0.3 0.3]);       
    end
    xlim([disp_t_start disp_t_end])
    ylim([yMin-offsetStep*(disp_num-1) yMax])
    box off;
    if ax == 1
        temp = get(gca,'Ytick');
        yticks(temp(1):10:temp(end));
    else
        yticks([]);
        set(gca,'YColor','none');
    end
    if ax ~= 2
        xticks([]);
        set(gca,'XColor','none');
    end
    title(sprintf('%s-axis',axis_label{ax}))
    set(gca,'FontSize',16)
end
print(gcf,'AllAccWaveform','-dpdf','-painters');

%% Display all accelerometer waveforms in 3D
time = 1000*t(t_ind)';
time = time - time(1);
offsetStep = 10.0;
figure('Position',[120,90,840,900],'Color','white')
for ax = 1:3
    subplot('Position',[0.05+0.3*(ax-1),0.04,0.3,0.92])
    hold on
    for i = 1:disp_num
        offset = offsetStep*(i-1);
        y = offset*ones(size(slctChannels(:,i,ax)));
        plot3(time,y,slctChannels(:,i,ax),'Color',[0.3 0.3 0.3]);    
        zlim([yMin yMax])
%         zlim([-0.5 yMax])
    end
%     xlim([time(1) time(end)])
    box off;
    if ax ~= 1
        yticks([]);
        set(gca,'YColor','none');
    else
        yticks(0:offsetStep:offsetStep*(disp_num-1))
        yticklabels(1:disp_num)
        ylabel('Acc')
        zlabel('Amplitude (g)')
    end
    if ax ~= 2
        xticks([]);
        set(gca,'XColor','none');
    else
        xlabel('Time (ms)')
    end
    title(sprintf('%s-axis',axis_label{ax}))
    set(gca,'FontSize',16)
    view([-10 60]) 
end
print(gcf,'AllAccWaveform3D','-dpdf','-painters');

%% Individual subplot
if 0 %---------------------------------------------------------------switch
% Plot waveform (raw or smoothed)
row_num = ceil(disp_num/3);

yRange = [min(proj_waveform(:)), max(proj_waveform(:))];

figure('Name','%Projected raw signal waveform','Position',[120,90,840,900])
% figure('units','normalized','outerposition',[0 0 1 1])

for i = 1:disp_num
    subplot(row_num,3,i);
    plot(t(t_ind),proj_waveform(:,i));
    xlim([disp_t_start disp_t_end])
    ylim(yRange);
    box off;

    if (mod(i,3) == 1)&&(floor(i/3)==floor(0.5*row_num))
%             ylabel('Amplitude (g)');
        ylabel('Z-Axis Amplitude (g)');
    else
        yticks([]);
%             set(gca,'YColor','none');
    end
    text(1.2,6,sprintf('Acc %d',disp_acc_i(i)));
%         set(gca, 'color', 'none');

    if i == disp_num
        xlabel('Time (secs)')
    else
        xticks([]);
%             set(gca,'XColor','none');
    end
end

% print(gcf,'AllAccWaveform','-dpdf','-painters');
end %----------------------------------------------------------------switch

