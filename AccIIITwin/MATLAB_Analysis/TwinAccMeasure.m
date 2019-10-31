%% Twin Accelerometer Array Measurement
% Measurement using two set of AccIII with order determined by connection:
%   Connect PC to board A first, then board B.
% Created on 10/30/2019
% Created by Yitian Shao (yitianshao@ucsb.edu)
%--------------------------------------------------------------------------
ProgramPath = '..\AccIII\Debug\';

expected_samp_time = 6;

[status,cmdout] = system(sprintf('%sAccIII.exe %.2f',...
    ProgramPath, expected_samp_time*0.51));
disp(cmdout)

%% ------------------------------------------------------------------------
% Decode data and present
[temp_data, t, Fs_A ] = readAccRevi('data_A.bin', 'data_rate_A.txt', 1);
trunc_ind = (t <= expected_samp_time);
t_A = t(trunc_ind);
acc_data_A = temp_data(trunc_ind,:,:); % Truncate

[temp_data, t, Fs_B ] = readAccRevi('data_B.bin', 'data_rate_B.txt', 1);
trunc_ind = (t <= expected_samp_time);
t_B = t(trunc_ind);
acc_data_B = temp_data(trunc_ind,:,:); % Truncate

%% Save data
data_name = 'Sin10Hz';
trial_num = 1;
save(sprintf('%s_t%d.mat',data_name,trial_num),'acc_data_A','acc_data_B',...
    't_A','t_B','Fs_A','Fs_B');