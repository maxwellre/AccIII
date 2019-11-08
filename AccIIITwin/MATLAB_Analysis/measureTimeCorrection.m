%% Measurement Time Correction for TwinAcc Setup
% This function estimate measurement time for twin accelerometer arrays
% The input is the saved file 'sample_time.txt' where processor time ticks
% are saved.
% -------------------------------------------------------------------------
function [tEndA,tEndB] = measureTimeCorrection(samp_time_data_path)
% Created on 11/14/2019
% -------------------------------------------------------------------------
% Import sampling time sticks 
file_ttick = fopen(samp_time_data_path); % Open file storing time ticks
tTick = textscan(file_ttick, '%f'); % Read sampling frequency
fclose(file_ttick);
tTick = tTick{1,1};

% Extract time ticks for array A and B
tickInd0 = (tTick == 0);
tickInd0 = diff(tickInd0);
tickInd0 = find(tickInd0 == 1);
if (length(tickInd0) ~= 2)
    error('sample_time incorrect!');
end
tickA = tTick((tickInd0(1)+1):tickInd0(2)); % Time ticks for array A
tickB = tTick((tickInd0(2)+1):end); % Time ticks for array B

% Use linear regression to estimate the actual sampling time
tickLinearA = fitlm(1:length(tickA),tickA); % Linear regression model A
tickLinearB = fitlm(1:length(tickB),tickB); % Linear regression model B

% Estimated measurement time for array A and B
tEndA = predict(tickLinearA,length(tickA)); % Predicted end time A
tEndB = predict(tickLinearB,length(tickB)); % Predicted end time B

% % % %% For debugging
% % % figure;
% % % plot(tickA); hold on; plot(tickB); ylabel('Time (secs)')
% % % plot([0 length(tickA)], [0 tEndA],'--c');
% % % plot([0 length(tickB)], [0 tEndB],'--y');