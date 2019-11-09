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
function output_data = segmentDataOrigin(dataPath, trialNum, inspectSeg,...
    correctFactor)
%--------------------------------------------------------------------------
% Created on 11/04/2019 
% Created by Yitian Shao (yitianshao@ucsb.edu)
%--------------------------------------------------------------------------
if nargin < 3
    inspectSeg = 0;
end
if nargin < 4
    correctFactor = [1 1];
end

Overlord = 1; % Force a 1 second interval for segmentation

load(dataPath);

% Remove spikes at beginning and end of measurements
indA=1:round(expected_samp_time*Fs_A);
indB=1:round(expected_samp_time*Fs_B);
acc_data_A = acc_data_A(indA+2,:,:);
acc_data_B = acc_data_B(indB+2,:,:);

t_A=(0:size(acc_data_A,1)-1)/Fs_A;
t_B=(0:size(acc_data_B,1)-1)/Fs_B;

% Compute total energy of all channels and axes
accEnA = acc_data_A(:,:,1).^2 +acc_data_A(:,:,2).^2 +acc_data_A(:,:,3).^2;
accEnB = acc_data_B(:,:,1).^2 +acc_data_B(:,:,2).^2 +acc_data_B(:,:,3).^2; 
accTotalEnA = sum(accEnA,2);
accTotalEnB = sum(accEnB,2);

thresh_ratio = 0.03;

% Onset detection using total energy (A)
temp = accTotalEnA - mean(accTotalEnA);
temp = movmean(temp,100); % Smooth
thresh = thresh_ratio*max(temp);
onset_ind = (temp > thresh);
onset_d = diff(onset_ind);
onset_A = find(onset_d == 1);

if Overlord
    onset_A = round(onset_A(1) + (0:10)*Fs_A);
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
    onset_B = round(onset_B(1) + (0:10)*Fs_A);
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
hold on; plot(t_B(onset_B),mean(accTotalEnB),'+k');
xlabel('Time (secs)')
end

% Data segmentation using detection onset ticks
output_data = cell(trialNum,4);
for t_i = 1:(trialNum-1)
    ind_A = onset_A(t_i):(onset_A(t_i+1)-1);
    output_data{t_i,1} = t_A(ind_A);
    output_data{t_i,2} = acc_data_A(ind_A,:,:);
    
    ind_B = onset_B(t_i):(onset_B(t_i+1)-1);
    output_data{t_i,3} = t_B(ind_B);
    output_data{t_i,4} = acc_data_B(ind_B,:,:);
end
output_data{trialNum,1} = t_A(onset_A(end):end);
output_data{trialNum,2} = acc_data_A(onset_A(end):end,:,:);
output_data{trialNum,3} = t_B(onset_B(end):end);
output_data{trialNum,4} = acc_data_B(onset_B(end):end,:,:);
disp('Segmentated data format: [t_A | data_A | t_B | data_B]')
end