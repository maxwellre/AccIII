%% Test and display the accelerometer array data (Design III)
% Using LDV to caliberate the accelerometer array
% Inputs:
%   1. 'dataPath' - Path of the .bin file that stores the data
%   2. 'trialNum' - Number of repeated measurement for each configuration
% Optional inputs:
%   3. 'inspectSeg' - display onset detection for inspection
%   4. 'correctFactor' - samping frequency correction factor
% Outputs:
%   1. 'output_data' - Segmentated data [t_A | data_A | t_B | data_B]
function output_data = segmentDataOrigin(dataPath, trialNum, thresh_ratio,...
    inspectSeg, correctFactor)
%--------------------------------------------------------------------------
% Created on 11/04/2019 
% Created by Yitian Shao (yitianshao@ucsb.edu)
% Updated on 11/10/2019 High-pass filter the accelerometer data
%--------------------------------------------------------------------------
if nargin < 3    
    thresh_ratio = 0.04;
end
if nargin < 4
    inspectSeg = 0;
end
if nargin < 5
    correctFactor = [1 1];
end

Overlord = 1; % Force a 1 second interval for segmentation

load(dataPath);

if ~exist('expected_samp_time','var')
    expected_samp_time = floor(min([t_A(end),t_B(end)]));
end

% Remove spikes at beginning and end of measurements
indA=1:round(expected_samp_time*Fs_A);
indB=1:round(expected_samp_time*Fs_B);
acc_data_A = acc_data_A(indA+2,:,:);
acc_data_B = acc_data_B(indB+2,:,:);

t_A=(0:size(acc_data_A,1)-1)/Fs_A;
t_B=(0:size(acc_data_B,1)-1)/Fs_B;

% --------------------------- Clean filtering -----------------------------
A_stop1 = 80;	% Attenuation in the first stopband = 80 dB
F_stop1 = 10;	% Edge of the stopband = 10 Hz
F_pass1 = 20;	% Edge of the passband = 20 Hz
% % % F_pass2 = 352;	% Closing edge of the passband = ? Hz
% % % F_stop2 = 362;	% Edge of the second stopband = ? Hz
A_pass = 1;		% Amount of ripple allowed in the passband = 1 dB

HighPassObjA = fdesign.highpass('Fst,Fp,Ast,Ap',...
    F_stop1*2/Fs_A,F_pass1*2/Fs_A,A_stop1,A_pass);
FilterAH = design(HighPassObjA,'FIR');

% % % LowPassObjA = fdesign.lowpass('Fp,Fst,Ap,Ast',...
% % %     F_pass2*2/Fs_A,F_stop2*2/Fs_A,A_pass,A_stop1);
% % % FilterAL = design(LowPassObjA,'FIR');

HighPassObjB = fdesign.highpass('Fst,Fp,Ast,Ap',...
    F_stop1*2/Fs_B,F_pass1*2/Fs_B,A_stop1,A_pass);
FilterBH = design(HighPassObjB,'FIR');

% % % LowPassObjB = fdesign.lowpass('Fp,Fst,Ap,Ast',...
% % %     F_pass2*2/Fs_B,F_stop2*2/Fs_B,A_pass,A_stop1);
% % % FilterBL = design(LowPassObjB,'FIR');

acc_data_A = filter(FilterAH, acc_data_A);
% % % acc_data_A = filter(FilterAL, acc_data_A);
acc_data_B = filter(FilterBH, acc_data_B);
% % % acc_data_B = filter(FilterBL, acc_data_B);
% -------------------------------------------------------------------------
% Compute total energy of all channels and axes
accEnA = acc_data_A(:,:,1).^2 +acc_data_A(:,:,2).^2 +acc_data_A(:,:,3).^2;
accEnB = acc_data_B(:,:,1).^2 +acc_data_B(:,:,2).^2 +acc_data_B(:,:,3).^2; 
accTotalEnA = sum(accEnA,2);
accTotalEnB = sum(accEnB,2);

% Onset detection using total energy (A)
temp = accTotalEnA - mean(accTotalEnA);
temp = movmean(temp,100); % Smooth
thresh = thresh_ratio*max(temp);
onset_ind = (temp > thresh);
onset_d = diff(onset_ind);
onset_A = find(onset_d == 1);

if Overlord
    onset_A = round(onset_A(1) + (0:9)*Fs_A);
end

% Check onset detection result (A)
if (length(onset_A) ~= trialNum)
    figure; plot(temp);hold on; plot(onset_A,thresh,'.r');
    error('Onset detection for array A is incorrect!')
end

% Onset detection using total energy (B)
temp = accTotalEnB - mean(accTotalEnB);
temp = movmean(temp,100); % Smooth
thresh = thresh_ratio*max(temp);
onset_ind = (temp > thresh);
onset_d = diff(onset_ind);
onset_B = find(onset_d == 1);

if Overlord
    onset_B = round(onset_B(1) + (0:9)*Fs_B);
end

% Check onset detection result (B)
if (length(onset_B) ~= trialNum)
    figure; plot(temp);hold on; plot(onset_B,thresh,'.r');
    error('Onset detection for array B is incorrect!')
end

% (Optional) display onset detection results
if inspectSeg
figure; 
yyaxis left; plot(t_A,accTotalEnA); ylabel('Palm (A) Total Energy');
hold on; plot(t_A(onset_A),mean(accTotalEnA),'+r');
yyaxis right; plot(t_B,accTotalEnB); ylabel('Dorsum (B) Total Energy');
hold on; plot(t_B(onset_B),mean(accTotalEnB),'ok');
xlabel('Time (secs)')
end

% Data segmentation using detection onset ticks
segLenA = round(0.8*Fs_A); % fixed 0.8 secs segmentation
segLenB = round(0.8*Fs_B); % fixed 0.8 secs segmentation

output_data = cell(trialNum,4);
for t_i = 1:trialNum
% for t_i = 1:(trialNum-1)
% % %     ind_A = onset_A(t_i):(onset_A(t_i+1)-1);
    ind_A = onset_A(t_i):(onset_A(t_i)+segLenA);
    output_data{t_i,1} = t_A(ind_A);
    output_data{t_i,2} = acc_data_A(ind_A,:,:);
    
% % %     ind_B = onset_B(t_i):(onset_B(t_i+1)-1);
    ind_B = onset_B(t_i):(onset_B(t_i)+segLenB);
    output_data{t_i,3} = t_B(ind_B);
    output_data{t_i,4} = acc_data_B(ind_B,:,:);
end
% % % output_data{trialNum,1} = t_A(onset_A(end):end);
% % % output_data{trialNum,2} = acc_data_A(onset_A(end):end,:,:);
% % % output_data{trialNum,3} = t_B(onset_B(end):end);
% % % output_data{trialNum,4} = acc_data_B(onset_B(end):end,:,:);
disp('Segmentated data format: [t_A | data_A | t_B | data_B]')
end