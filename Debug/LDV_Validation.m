%% Validate accelerometer array (AccIII) with LDV
% Using LDV to caliberate the accelerometer array
% Created on 01/30/2018 Based on 'LDV.m'
%--------------------------------------------------------------------------
addpath('Debug');
%--------------------------------------------------------------------------
LDVSamplingFreq = 48000; % Sampling frequency of LDV: 48kS/sec

ScaleFactor = 0.025; % 25(mm/s)/V for 100mm/s measurement scale
M2G = 1/9.807; % 1g = 9.807 m/s2
AngleCompen = 25/11; % Angle compensation = 1/cos(theta)
DAC_ratio = 8.8603; % Caliberated on 01/30/2018

NoID = 1;
expected_samp_time = 5;

%--------------------------------------------------------------------------
% Initialize the MOTU interface to record LDV output
InputChannelNum = 1;
fprintf('Input from: %s\n', audiodevinfo(1,InputChannelNum));
rec_obj = audiorecorder(LDVSamplingFreq,16,InputChannelNum);
fprintf('LDV Sampling frequency = %.0f Hz\n', LDVSamplingFreq);


%--------------------------------------------------------------------------
disp('Sampling...')

tic
% Recording LDV
record(rec_obj, LDVSamplingFreq*(MeasurementDuration+10)); % Start the recording

if NoID
    % If NoID
    [status,cmdout] =...
        system(sprintf('AccIII.exe %.2f', expected_samp_time*0.45));
else
    [status,cmdout] =...
        system(sprintf('AccIII.exe %.2f', expected_samp_time));
end

disp(cmdout)

%--------------------------------------------------------------------------
% Stop LDV measurement
rec_time = toc;
stop(rec_obj);   
LDV_data = getaudiodata(rec_obj);
LDV_time = length(LDV_data)/LDVSamplingFreq;
fprintf('Measurement completed: [%.3f] %.3f secs\n', rec_time, LDV_time) 

%% LDV data to acceleration waveform
disp_t_start = 1.0;
disp_t_end = 1.2;

signal_en = length(LDV_data);
time_stamp = linspace(0, LDV_time, signal_en);

t_ind = (time_stamp >= disp_t_start) & (time_stamp <= disp_t_end);

% -------------------------------------------------------------------------
% % Design a Low-pass digital filtern to remove noise in recordings
A_stop1 = 80;	% Attenuation in the first stopband = 80 dB	
F_pass1 = 1000;
F_stop1 = F_pass1 +200;% Edge of the passband 
A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB
LowPassObj = fdesign.lowpass('Fp,Fst,Ap,Ast',...
    F_pass1*2/LDVSamplingFreq,F_stop1*2/LDVSamplingFreq,A_pass,A_stop1);
Filter = design(LowPassObj,'FIR');
smoothData = filter(Filter, (AngleCompen*ScaleFactor*DAC_ratio).*LDV_data);
%--------------------------------------------------------------------------
% smoothData = (AngleCompen*ScaleFactor).*LDV_data;

LDV_acc = [diff(smoothData(t_ind)); 0].*LDVSamplingFreq.*M2G;

figure('Position',[260,150,600,150]);
plot(time_stamp(t_ind),LDV_acc);
xlabel('Time (secs)');
ylabel('Acceleration (g)');
box off;

%% Decode accelerometer data
if ~status
    if NoID
        [acc_data, t, Fs ] = readAccIII('data.bin','data_rate.txt', 0);
        trunc_ind = (t <= expected_samp_time);
        t = t(trunc_ind);
        acc_data = acc_data(trunc_ind,:,:); % Truncate
    else
        [acc_data, Fs, t] = syncAccIII('data.bin','sample_time.txt',0,1);
    end
    fprintf('Actually sampling time = %.4f secs\n', t(end));
    
    SignalWaveformDisplay;
end
