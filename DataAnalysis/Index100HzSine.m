%% Signal waveform on hand (Index 100Hz Sinewave stimulus)
% Created on 05/17/2018
%--------------------------------------------------------------------------
Data_Path = 'Data/100Hz_sine/';
axis_label = {'X', 'Y', 'Z'};
%--------------------------------------------------------------------------
[acc_data, t, Fs ] = readAccIII([Data_Path,'data.bin'],...
    [Data_Path,'data_rate.txt'], 0);
%--------------------------------------------------------------------------
if ~exist('acc_data','var')
    error('AccIII data required!');
end
%% ------------------------------------------------------------------------
disp_t_start = 1;
disp_t_end = 1.2;

% Display selected accelerometer signal waveform
% disp_acc_i = 21:29; 
% disp_acc_i = 31:39;
disp_acc_i = setdiff(1:46,[10,20,30,40]);
disp_num = length(disp_acc_i);

%--------------------------------------------------------------------------
t_ind = (t >= disp_t_start) & (t <= disp_t_end);

if disp_num == 1
    slctChannels = squeeze(acc_data(t_ind,disp_acc_i,:));
    yRange = [min(slctChannels(:)), max(slctChannels(:))];
elseif disp_num > 1
    slctChannels = zeros(sum(t_ind),disp_num,3);
    proj_waveform = zeros(sum(t_ind),disp_num);
    for i = 1:disp_num
        slctChannels(:,i,:) = acc_data(t_ind,disp_acc_i(i),:);
        amp = slctChannels(:,i,1).^2 + slctChannels(:,i,2).^2 +...
              slctChannels(:,i,3).^2;
        [~,max_i] = max(amp);
        proj_vector = squeeze(slctChannels(max_i,i,:));
        proj_vector = proj_vector./norm(proj_vector);
        proj_waveform(:,i) = squeeze(slctChannels(:,i,:))*...
                    proj_vector;
    end
end

%% ------------------------------------------------------------------------
% Design a Low-pass digital filtern to remove noise in recordings
% A_stop1 = 80;	% Attenuation in the first stopband = 80 dB	
% F_pass1 = 200;
% F_stop1 = F_pass1 +10;% Edge of the passband 
% A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
% LowPassObj = fdesign.lowpass('Fp,Fst,Ap,Ast',...
%     F_pass1*2/Fs,F_stop1*2/Fs,A_pass,A_stop1);
% Filter = design(LowPassObj,'FIR');
% smoothData = filter(Filter, smoothData);
% smooth_t = t;
%--------------------------------------------------------------------------
% % Smoothed (Up-sample)
% Smooth_Fs = 4000; 
% [smoothData,smooth_t] = resample(squeeze(acc_data(:,disp_acc_i,:)),...
%   t,Smooth_Fs);
% 
% smooth_ind = (smooth_t >= disp_t_start) & (smooth_t <= disp_t_end);

%--------------------------------------------------------------------------
% 1) Figure showing A 100 Hz sinewave stimuli was applied to the tip of 
%    digit II of the subject.
if 0 %---------------------------------------------------------------switch
% Plot waveform (raw or smoothed)
if disp_num == 1
    figure('Position',[260,150,600,400]);
    for ax = 1:3
        subplot(3,1,ax)
        plot(t(t_ind),slctChannels(:,ax));
        
        %     hold on
        %     plot(smooth_t(smooth_ind),smoothData(smooth_ind,ax));
        
        if ax == 1
            title(sprintf('Acc %d',disp_acc_i));
        end
        if ax == 2
            ylabel({'Amplitude (g)';sprintf('%s-axis',axis_label{ax})});
        else
            ylabel(sprintf('%s-axis',axis_label{ax}));
        end
        set(gca, 'FontSize',12);
        ylim(yRange);
        box off;
    end
    xlabel('Time (secs)')
elseif disp_num > 1
    row_num = ceil(disp_num/3);
    
    yRange = [min(proj_waveform(:)), max(proj_waveform(:))];
    
%     figure('Name','%Projected raw signal waveform',...
%         'Position',[120,60,840,400]);
    figure('units','normalized','outerposition',[0 0 1 1])

    for i = 1:disp_num
        subplot(row_num,3,i);
        plot(t(t_ind),proj_waveform(:,i));
        xlim([disp_t_start disp_t_end])
        ylim(yRange);
        box off;
        
        if (mod(i,3) == 1)&&(floor(i/3)==floor(0.5*row_num))
            ylabel('Amplitude (g)');
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
end

% print(gcf,'AccIIISignalWaveform','-dpdf','-painters');
end %----------------------------------------------------------------switch

%% ------------------------------------------------------------------------
% 2) Figure showing the RMS amplitude measured at every location
%    (bar chart of amplitude vs sensor number)
if 1 %---------------------------------------------------------------switch
    t_ind = (t >= 0.005) & (t <= 5.005);
    
    accAmp = (acc_data(:,:,1).^2+acc_data(:,:,2).^2+...
        acc_data(:,:,3).^2).^0.5;
    accRMS_Amp = rms(accAmp(t_ind,:),1);
    
    figure('Name','RMS amplitude', 'Position',[120,120,840,300]);
    bar_h = bar(1:length(accRMS_Amp),accRMS_Amp,'k','EdgeColor','none');
    xlabel('Acc# (Digit V)                       (IV)                           (III)                            (II)                       (I)')
    ylabel('RMS Amplitude (g)')
    xticks([1,9,11,19,21,29,31,39,41,46]);
    box off
    
    print(gcf,'Index100HzSineRMSAMP','-dpdf','-painters');
end %----------------------------------------------------------------switch