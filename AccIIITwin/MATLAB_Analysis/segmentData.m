function output_data = segmentData(data_path, trialNum, correct_factor)
load(data_path);

% Sampling frequency and time stamps correction (for old data)
Fs_A = Fs_A*correct_factor(1);
Fs_B = Fs_B*correct_factor(2);
t_A = t_A./correct_factor(1);
t_B = t_B./correct_factor(2);

accEnA = acc_data_A(:,:,1).^2 +acc_data_A(:,:,2).^2 +acc_data_A(:,:,3).^2;
accEnB = acc_data_B(:,:,1).^2 +acc_data_B(:,:,2).^2 +acc_data_B(:,:,3).^2; 

accTotalEnA = sum(accEnA,2);
accTotalEnB = sum(accEnB,2);

temp = accTotalEnA - mean(accTotalEnA);
temp = movmean(temp,40); % Smooth
thresh = 0.5*max(temp);
onset_ind = (temp > thresh);
onset_d = diff(onset_ind);
onset_A = find(onset_d == 1);

if (length(onset_A) ~= trialNum)
    error('Onset detection for array A is incorrect!')
end

temp = accTotalEnB - mean(accTotalEnB);
temp = movmean(temp,40); % Smooth
thresh = 0.5*max(temp);
onset_ind = (temp > thresh);
onset_d = diff(onset_ind);
onset_B = find(onset_d == 1);

if (length(onset_B) ~= trialNum)
    error('Onset detection for array B is incorrect!')
end

figure; 
yyaxis left; plot(t_A,accTotalEnA); ylabel('Palm (A) Total Energy');
hold on; plot(t_A(onset_A),mean(accTotalEnA),'+r');
yyaxis right; plot(t_B,accTotalEnB); ylabel('Dorsum (B) Total Energy');
hold on; plot(t_B(onset_B),mean(accTotalEnB),'+k');
xlabel('Time (secs)')

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
end