% Configuration
read_num = 46;
half_read = 0.5*read_num; % Must be a integer (= 23)

% Initialization
axis_label = {'X', 'Y', 'Z'};

% Acquire sampling frequency
file_path1 = 'data_rate.txt';

file_id1 = fopen(file_path1);
samp_factor = textscan(file_id1, '%f'); % Read sampling frequency
fclose(file_id1);
Fs = samp_factor{1};

% Import data
file_path2 = 'data.bin';

file_id2 = fopen(file_path2);
hex_data = fread(file_id2,'*ubit8');
fclose(file_id2);

read_byte_num = length(hex_data);
data_num = floor(read_byte_num/read_num);
samp_num = floor(data_num/6); % Three axis X, Y and Z

T = 1/Fs; % Sampling time interval
t = (1:samp_num)*T;
fprintf('Sampling time = %.3f secs, Sampling frequency = %.2f Hz\n',...
    t(end),Fs);

hex_data = hex_data(1:(data_num*read_num));
hex_data = double(reshape(hex_data, [read_num,data_num])); % Double

% Hex to decimal conversion------------------------------------------------
odd_ind = 1:2:read_num;
even_ind = 2:2:read_num;
acc_data = zeros(samp_num, read_num, 3);

wb_h = waitbar(0, 'O', 'Name','Converting from HEX to DEC...');
count = 0;
for i=1:samp_num
    waitbar(i/samp_num,wb_h,sprintf('Processing sample %d',i));
    
    % Odd number sensor (Pull up)
    for j=1:3
        count = count +1;
        for k=1:half_read
            acc_data(i,odd_ind(k),j) = 256*(hex_data(half_read+k,count))+...
                (hex_data(k,count)); % data[Low,High]
        end
    end
    
    % Even number sensor
    for j=1:3
        count = count +1;
        for k=1:half_read
            acc_data(i,even_ind(k),j) = 256*(hex_data(half_read+k,count))+...
                (hex_data(k,count)); % data[Low,High]
        end
    end
end
close(wb_h);

%=========================== Format correction ============================
negInd = find(acc_data > 32767); % Negative data
acc_data(negInd) = acc_data(negInd) - 65536;
disp('Format conversion completed.')
% %--------------------------------------------------------------------------
%% Analysis ()
% if 1 %---------------------------------------------------------------Switch
GSCALE = 0.00073; % 0.73 mg/digit
% GSCALE = 1; % Unit: bits
acc_ind = [1:9,11:19,21:29,31:39,41:46];
% 
% if 1
% Raw signals------------------------------
for ax = 1:3 % 1:X-axis, 2:Y-axis, 3:Z-axis
    figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8],...
        'Name',sprintf('%s-axis',axis_label{ax}))
    for k = 1:length(acc_ind)
        subplot(14,3,k)
        plot(t, GSCALE*acc_data(:,acc_ind(k),ax));
        ylabel(sprintf('%d',acc_ind(k)));
        xlim([t(1) t(end)])
%         ylim([-16 16])
        ylim([-2 2])
        box off
        if k<42
            xticks([])
        end
    end
    xlabel('Time (Secs)')
% %     xlim([t(1) t(1000)])
% end
% % else
% % slct_i = 16;  
% % figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8])
% % for ax = 1:3 % 1:X-axis, 2:Y-axis, 3:Z-axis
% %     subplot(3,1,ax)
% %     plot(t, GSCALE*acc_data(:,acc_ind(slct_i),ax));
% %     xlim([t(1) t(end)])
% %     ylabel(sprintf('Acc %d-%s',acc_ind(slct_i),axis_label{ax}));
% %     ylim([-1 5])
% % end
% % xlabel('Time (Secs)')
end
% 
% end %------------------------------------------------------------Switch end

%--------------------------------------------------------------------------
%% Analysis ()
% if 0 %---------------------------------------------------------------Switch
% close all
% GSCALE = 0.00073; % 0.73 mg/digit
% 
% acc_ind = 1:24;
% 
% ax = 2; % 1:X-axis, 2:Y-axis, 3:Z-axis
% 
% % Raw signals
% for q=0:1
% figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8])
% for k = 1:24
%     subplot(8,3,k)
%     plot(t, GSCALE*acc_data(:,q*24+acc_ind(k),ax));
%     ylabel(sprintf('Acc %d-%s',q*24+acc_ind(k),axis_label{ax}));
%     xlim([t(1) t(end)])
%     ylim([-16 16])
% end
% xlabel('Time (Secs)')
% end
% 
% % Spectrum
% [ acc_FT, f ] = spectr(acc_data(:,:,ax), Fs);
% for q=0:1
% figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8])
% for k = 1:24
%     subplot(8,3,k)
%     plot(f, acc_FT(:,q*24+acc_ind(k)));
%     ylabel(sprintf('Acc %d-%s',q*24+acc_ind(k),axis_label{ax}));
% end
% xlabel('Frequency (Hz)')
% end
% 
% end %------------------------------------------------------------Switch end