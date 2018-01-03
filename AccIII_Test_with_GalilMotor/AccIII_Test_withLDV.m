%% Test and display the accelerometer array data (Design III)
% Using LDV to caliberate the accelerometer array
% Created on 06/01/2017
% Updated on 07/14/2017 New data format from new board
% Updated on 08/15/2017 Corrected unit scale
% Updated on 09/05/2017 New data reading format
%--------------------------------------------------------------------------
close all
clc
%--------------------------------------------------------------------------
addpath('Debug');
%--------------------------------------------------------------------------
DMC_path = './DMC_file/'; % Relative path

LSVSamplingFrequency = 5000; % Sampling frequency of LDV: 5kHz by default
MaxMeasurementDuration = 10; % secs
%--------------------------------------------------------------------------
% Initialize the MOTU interface to record LDV output
InputChannelNum = 1;
fprintf('Input from: %s\n', audiodevinfo(1,InputChannelNum));
rec_obj = audiorecorder(LSVSamplingFrequency,16,InputChannelNum);
fprintf('LDV Sampling frequency = %.0f Hz\n', LSVSamplingFrequency);

% Generating stimuli with DMC motor
if 1 %---------------------------------------------------------------switch
% Initialize the DMC motor
if ~exist('galil_obj', 'var')
    galil_obj = motorInitialization(DMC_path);
end

try
    DMC_file_name = 'streamOut.dmc';
%     DMC_file_name = 'sine.dmc';
    galil_obj.programDownloadFile( [DMC_path,DMC_file_name] ); % Load .dmc file
    galil_obj.command('XQ');% Run the Program
catch
    if exist('galil_obj', 'var')
        motorShutdown(galil_obj) % Shutdown the DMC motor
    end
    error('DMC Motor Error: Redo motor initialization needed!')
end
end %----------------------------------------------------------------switch

%--------------------------------------------------------------------------
% Recording LDV
record(rec_obj, LSVSamplingFrequency*MaxMeasurementDuration); % Start the recording

% Reading accelerometer array
status = 1;
tic
try
    disp('Reading data...')
    [status,cmdout] = system('Debug\AccIII.exe');
catch
    disp('Failed to connect FPGA board!')
end

if status==0
    disp('Data imported successfully!')
end

%--------------------------------------------------------------------------
% Stop LDV measurement
rec_time = toc;
stop(rec_obj)
LDV_data = getaudiodata(rec_obj);
LDV_acc_data = diff(LDV_data);
LDV_time = length(LDV_data)/LSVSamplingFrequency;
fprintf('Measurement completed: [%.3f] %.3f secs\n', rec_time, LDV_time) 

%--------------------------------------------------------------------------
% Reading accelerometer data
[acc_data, t, Fs ] = readAccIII('data.bin', 'data_rate.txt');

%--------------------------------------------------------------------------
if 0
    %% End motor
    motorShutdown(galil_obj); % Shutdown the DMC motor
end

%% Analysis
axis_label = {'X', 'Y', 'Z'};
ax = 3; % 1:X-axis, 2:Y-axis, 3:Z-axis
acc_ind = [1:9,11:19,21:29,31:39,41:46]; % Skip Acc 10,20,30,40
disp_num = (0.5*length(acc_ind)); % Number of channels displayed per figure
% % Raw signals--------------------------------------------------------------
% for q=0:1
% figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8])
% for k = 1:disp_num
%     subplot(ceil(disp_num/3),3,k)
%     plot(t, acc_data(:,q*disp_num+acc_ind(k),ax));
%     ylabel(sprintf('Acc %d-%s',q*disp_num+acc_ind(k),axis_label{ax}));
%     ylim([-16 16])
% end
% xlabel('Time (Secs)')
% end
% Spectrum-----------------------------------------------------------------
[ acc_FT, f ] = spectr(acc_data(:,:,ax), Fs);
for q=0:1
figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8])
for k = 1:disp_num
    subplot(ceil(disp_num/3),3,k)
    plot(f, acc_FT(:,q*disp_num+acc_ind(k)));
    ylabel(sprintf('Acc %d-%s',q*disp_num+acc_ind(k),axis_label{ax}));
    xlim([1 0.5*Fs])
end
xlabel('Frequency (Hz)')
end


%% Analyze LDV data
figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8]);
subplt_LDV_h = cell(2,1);
subplt_LDV_h{1} = subplot(2,1,1); % LDV Temporal plot
subplt_LDV_h{2} = subplot(2,1,2); % LDV Frequency plot
disp('------------------------------ LDV ------------------------------');
analyzeData(LDV_acc_data, LDV_time, subplt_LDV_h);
title(subplt_LDV_h{1}, 'LDV Amplitude')
title(subplt_LDV_h{2}, 'LDV Spectrum')