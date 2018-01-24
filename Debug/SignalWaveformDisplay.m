%% Signal waveform display
% Created on 01/23/2018
%--------------------------------------------------------------------------
axis_label = {'X', 'Y', 'Z'};
%--------------------------------------------------------------------------
if ~exist('acc_data','var')
    error('AccIII data required!');
end
%--------------------------------------------------------------------------
disp_acc_i = 34; % Display selected accelerometer signal waveform
disp_t_start = 1.0;
disp_t_end = 1.2;

%--------------------------------------------------------------------------
t_ind = (t >= disp_t_start) & (t <= disp_t_end);

slctChannels = squeeze(acc_data(t_ind,disp_acc_i,:));
yRange = [min(slctChannels(:)), max(slctChannels(:))];

% -------------------------------------------------------------------------
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
% Smoothed
% Smooth_Fs = 2000; 
% [smoothData,smooth_t] = resample(squeeze(acc_data(:,disp_acc_i,:),...
%   t,Smooth_Fs);

% smooth_ind = (smooth_t >= disp_t_start) & (smooth_t <= disp_t_end);

%--------------------------------------------------------------------------
% Plot waveform (raw and smoothed)
figure('Position',[260,150,600,400]);
for ax = 1:3
    subplot(3,1,ax)
    plot(t(t_ind),slctChannels(:,ax));
%     hold on
%     plot(smooth_t(smooth_ind),smoothData(smooth_ind,ax));
%     hold off
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