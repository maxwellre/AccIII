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
%--------------------------------------------------------------------------
function output_data = segmentData(dataPath, trialNum, inspectSeg,...
    correctFactor)
% Created on 11/04/2019 
% Created by Yitian Shao (yitianshao@ucsb.edu)
% Updated by Bharat Dandu 11/06/19 - Added an iterative update rule for the
% threshold of total energy, and a rule preventing close onsets
%--------------------------------------------------------------------------
if nargin < 3
    inspectSeg = 0;
end
if nargin < 4
    correctFactor = [1 1];
end

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

threshVal = 0.25;    % Starting Threshold Value
foundOnsets = 10;

% Onset detection using total energy (A)
while (foundOnsets ~= 0)
    temp = accTotalEnA - mean(accTotalEnA);
    temp = movmean(temp,100); % Smooth
    thresh = threshVal*(max(temp)-min(temp))+min(temp);
    onset_ind = (temp > thresh);
    onset_d = diff(onset_ind);
    onset_A = find(onset_d == 1);
    
    if (length(onset_A) > trialNum)
    % If excessive onsets detected, ensure they don't happen too close together (which may be due to smoothing not doing a good job)
        onset_locVerA = find(diff(onset_A)>400);     % Detected events should be seperated by at least 400ms 
        onset_A = onset_A([1;onset_locVerA+1]);
    end
    
    % Check onset detection result (A)
    if (length(onset_A) == trialNum)
        foundOnsets = 0;    % Onsets correctly found, exit iterative approach
    else
        foundOnsets = foundOnsets - 1;  % Only do this iterative approach a certain amount of times before giving up
        if (foundOnsets == 2)
            error('Onset detection for array A is incorrect!')
        end
        
        if (length(onset_A) < trialNum)     % Current threshold is too aggressive, ramp down. Can use a more complicated logic, but this seems to work well
            threshVal = threshVal*.9;
        else
            threshVal = threshVal*1.1;      % Threshold too lax
        end
    end
end


threshVal = 0.25;    % Starting Threshold Value
foundOnsets = 10;

% Onset detection using total energy (B)
while (foundOnsets ~= 0)
    temp = accTotalEnB - mean(accTotalEnB);
    temp = movmean(temp,100); % Smooth
    thresh = threshVal*(max(temp)-min(temp))+min(temp);
    onset_ind = (temp > thresh);
    onset_d = diff(onset_ind);
    onset_B = find(onset_d == 1);
    
    if (length(onset_B) > trialNum)
    % If excessive onsets detected, ensure they don't happen too close together (which due to smoothing not doing a good job)
        onset_locVerB = find(diff(onset_B)>400);     % Detected events should be seperated by at least 400ms. Modify based on stimuli knowledge
        onset_B = onset_B([1;onset_locVerB+1]);
    end
    
    % Check onset detection result (A)
    if (length(onset_B) == trialNum)
        foundOnsets = 0;    % Onsets correctly found, exit iterative approach
    else
        foundOnsets = foundOnsets - 1;  % Only do this iterative approach a certain amount of times before giving up
        if (foundOnsets == 2)
            error('Onset detection for array A is incorrect!')
        end
        
        if (length(onset_B) < trialNum)     % Current threshold is too aggressive, ramp down
            threshVal = threshVal*.9;
        else
            threshVal = threshVal*1.1;      % Threshold too lax
        end
    end
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