%% Twin Accelerometer Array Measurement
% Measurement using two set of AccIII with order determined by connection:
%   Connect PC to board A first, then board B.
% Created on 10/30/2019
% Created by Yitian Shao (yitianshao@ucsb.edu)
%--------------------------------------------------------------------------
% 2019/10/31: Palm is A, Dorsum is B
%--------------------------------------------------------------------------
close all;

ProgramPath = '..\AccIII\Debug\';

inspectMeasurement = 1; % Display measurement if set to 1

expected_samp_time = 12.2; % Measurement time ( < 12.5 secs)

StimSignals; % Prepare stimulus signals for actuator output

play(tapOut);
% freq = 320
% 
% switch freq
%     case 40
%         play(sin40Out);
%     case 80
%         play(sin80Out);
%     case 120
%         play(sin120Out);
%     case 160
%         play(sin160Out);
%     case 240
%         play(sin240Out);
%     case 320
%         play(sin320Out);
%     case 640
%         play(sin640Out);
% end

[status,cmdout] = system(sprintf('%sAccIII.exe %.2f',...
    ProgramPath, expected_samp_time*0.51));
disp(cmdout)

%% ------------------------------------------------------------------------
% Decode data and present
[acc_data_A, ~, Fs_A ] = readAccRevi('data_A.bin', 'data_rate_A.txt',...
    inspectMeasurement);
[acc_data_B, ~, Fs_B ] = readAccRevi('data_B.bin', 'data_rate_B.txt',...
    inspectMeasurement);

%% Board synchronization
ratio_A = Fs_A; ratio_B = Fs_B;
fprintf('Before correction: Fs_A = %.1f Hz, Fs_B = %.1f Hz\n',Fs_A,Fs_B);
[tEndA,tEndB] = measureTimeCorrection('sample_time.txt');
Fs_A = size(acc_data_A,1)/tEndA;
Fs_B = size(acc_data_B,1)/tEndB;
fprintf('After correction: Fs_A = %.1f Hz, Fs_B = %.1f Hz\n',Fs_A,Fs_B);
ratio_A = Fs_A/ratio_A; ratio_B = Fs_B/ratio_B;
fprintf('Sampling frequency correction ratio (A | B):\n%.10f,%.10f\n',...
    ratio_A,ratio_B);

%% Save data
data_name = 'Explore/HoldRuler_All';
% data_name = 'WindowedSine';
var = 1;
save(sprintf('%s_%dHz.mat',data_name,var),'acc_data_A','acc_data_B',...
    't','Fs_A','Fs_B','expected_samp_time','tEndA','tEndB','ratio_A','ratio_B');