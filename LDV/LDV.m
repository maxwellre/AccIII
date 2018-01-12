%% Galil motor with Raspberry Pi accelerometer and LDV
% Using LDV to caliberate the accelerometer array
% Created on 09/14/2017 Based on 'AccIII_Test_withLDV.m'
% =========================================================================
% ftp://pi@retouch-pi-01.mat.ucsb.edu/home/pi/TestAcc/RPI_acc_data.txt
% =========================================================================
close all
clc
%--------------------------------------------------------------------------
addpath('Debug');
%--------------------------------------------------------------------------

LDVSamplingFreq = 48000; % Sampling frequency of LDV: 48kS/sec

MeasurementDuration = 10; % secs

%--------------------------------------------------------------------------
% Initialize the MOTU interface to record LDV output
InputChannelNum = 1;
fprintf('Input from: %s\n', audiodevinfo(1,InputChannelNum));
rec_obj = audiorecorder(LDVSamplingFreq,16,InputChannelNum);
fprintf('LDV Sampling frequency = %.0f Hz\n', LDVSamplingFreq);


%--------------------------------------------------------------------------
tic
% Recording LDV
record(rec_obj, LDVSamplingFreq*(MeasurementDuration+10)); % Start the recording

pause(MeasurementDuration)

%--------------------------------------------------------------------------
% Stop LDV measurement
rec_time = toc;
stop(rec_obj);   
LDV_data = getaudiodata(rec_obj);
LDV_time = length(LDV_data)/LDVSamplingFreq;
fprintf('Measurement completed: [%.3f] %.3f secs\n', rec_time, LDV_time) 

%% Analyze LDV data--------------------------------------------------------
dispLogScale = 1;

figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8]);
subplt_LDV_h = cell(2,1);
subplt_LDV_h{1} = subplot(2,1,1); % LDV Temporal plot
subplt_LDV_h{2} = subplot(2,1,2); % LDV Frequency plot
disp('------------------------------ LDV ------------------------------');
analyzeData(LDV_data, LDV_time, subplt_LDV_h, dispLogScale);
title(subplt_LDV_h{1}, 'LDV Amplitude')
title(subplt_LDV_h{2}, 'LDV Spectrum')
xlim(subplt_LDV_h{2}, [0 10000]);

%Compute max displacement from LDV velocity data for sin wave
scaling_factor = 25;   %25mm/s/V
vmax = max(LDV_data);
vmin = min(LDV_data);
v_ampl = vmax-vmin; %Peak to peak amplitude
fprintf('Peak to peak amplitude = %.2f mm/s\n', v_ampl*scaling_factor)