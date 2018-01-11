%% Test and display the accelerometer array data (Design III)
% Using LDV to caliberate the accelerometer array
% Inputs:
%   1. 'data_path' - Path of the .bin file that stores the data
% Optional inputs:
%   2. 'meas_time' - Path of the .txt file that stores the measurement time
%   3. 'yRange' -  Range of y-axis: (0,16]. No range limit if set to 0
%   4. 'is_disp' - Display signals from all accelerometers if set to 1
% 
% Outputs:
%   1. 'acc_data' - Readed accelerometer data with unit 'g' (gravity)
%--------------------------------------------------------------------------
function [acc_data, Fs ] = decodeAccIII(data_path, meas_time, yRange,...
    is_disp)
% Created on 09/08/2017 Based on 'readAccIII.m'
%--------------------------------------------------------------------------
% Configuration
GSCALE = 0.00073; % 0.73 mg/digit
ID_Num = 23; % Each ID is associated with both pull up and pull down sensor
Exclude_Acc = [10,20,30,40]; % Skip Acc 10,20,30,40
% Initialization
axis_label = {'X', 'Y', 'Z'};
acc_ind = setdiff(1:(2*ID_Num),Exclude_Acc);

% Acquire sampling frequency (From 'file_path2')
if nargin < 2
    samp_time = 2;
    disp('Unknown sampling time');
else % Actual sampling frequency
    if ischar(meas_time)
        file_id1 = fopen(meas_time);
        samp_factor = textscan(file_id1, '%f'); % Read sampling frequency
        fclose(file_id1);
        samp_time = samp_factor{1};
    elseif isnumeric(meas_time)
        if isempty(meas_time)
            samp_time = 2; 
            disp('Unknown measurement time');
        else  
            samp_time = meas_time;
            disp('Inputed measurement time manually');
        end
    end
end

if nargin < 3
    yRange = 16; % Full range by default
end

if yRange <= 0
    yRange = 0;
elseif yRange > 16
    yRange = 16;
    disp('Display full range (16g)');
end

if nargin < 4
    is_disp = 1;
end

% Import data (From 'file_path1')
file_id2 = fopen(data_path);
hex_data = fread(file_id2,'*ubit8');
fclose(file_id2);

read_byte_num = length(hex_data);
data_num = floor(0.5*read_byte_num);
hex_data = hex_data(1:(2*data_num));
hex_data = double(reshape(hex_data, [2,data_num])); % Double

check_ID = unique(hex_data(1,:));
if length(check_ID) ~= ID_Num
    fprintf('ID: %d\n', check_ID);
    disp('Failed: Number of ID is incorrect');
else
    if (sum(abs((1:ID_Num)-check_ID)) == ID_Num)
        disp('Passed: IDs are correct')
    else
        disp('Failed: IDs are incorrect');
    end
end

% Hex to decimal conversion------------------------------------------------
wb_h = waitbar(0,'O', 'Name','Converting from HEX to DEC...');
acc_data = cell(2*ID_Num, 1);
samp_num = zeros(2*ID_Num, 1);
for i = check_ID
    waitbar(i/ID_Num,wb_h,sprintf('Processing ID %d',i));
    curr_ind = find(hex_data(1,:) == i);
    check_ind = curr_ind(1:2);
    curr_data_num = floor((length(curr_ind)-2)/6);
    data_ind = curr_ind(3:(6*curr_data_num +2));  
    pull_ind = zeros(6,curr_data_num);
    pull_ind(:,1:2:end) = 1; % (Pull up = 1, pull down = 0)
    pull_ind = logical(pull_ind(:))';
    for pull_x = 1:2 % 1: up, 2: down
        acc_ID = 2*i+pull_x;              
        if (hex_data(2,check_ind(pull_x)) == 63) % Check ID
            acc_data{acc_ID} = zeros(samp_num(acc_ID), 3);
            if (pull_x == 1)
                curr_data = hex_data(2,data_ind(pull_ind)); 
            else
                curr_data = hex_data(2,data_ind(~pull_ind));
            end
            samp_num(acc_ID) = length(curr_data)/6;
            
            for j = 1:samp_num(acc_ID)
                acc_data{acc_ID}(j,1) = 256*(curr_data((j-1)*6+2))+...
                    (curr_data((j-1)*6+1)); % X-axis[Low,High]
                acc_data{acc_ID}(j,2) = 256*(curr_data((j-1)*6+4))+...
                    (curr_data((j-1)*6+3)); % Y-axis[Low,High]
                acc_data{acc_ID}(j,3) = 256*(curr_data((j-1)*6+6))+...
                    (curr_data((j-1)*6+5)); % Z-axis[Low,High]
            end
            
            %=================== Format correction =====================
            negInd = find(acc_data{acc_ID} > 32767); % Negative data
            acc_data{acc_ID}(negInd) = acc_data{acc_ID}(negInd) - 65536;
            %===================== Unit coversion ======================
            acc_data{acc_ID} = GSCALE*acc_data{acc_ID};
            %===========================================================
            
            
        elseif(sum(Exclude_Acc == acc_ID) > 0)
            fprintf('Exclude Acc %d\n',acc_ID);
        else
            fprintf('Failed: ID check of Acc %d is incorrect!\n', acc_ID);
        end    
    end
end
close(wb_h);

Fs = samp_num/samp_time;
for i = acc_ind
    fprintf('Acc %d: Sampling frequency = %.2f Hz\n',i,Fs(i))
end

% %% Synchronization through decimation (failed)
% min_Fs = min(Fs(Fs>0));
% fprintf('Decimate frequency to %.2f Hz\n',min_Fs);
% for k = 1:length(acc_ind)
%     deci_ratio = Fs(acc_ind(k))/min_Fs;
%     fprintf('Acc %d: Sampling frequency = %.2f Hz, decimate by %f\n',...
%         acc_ind(k), Fs(acc_ind(k)), deci_ratio);
%     for ax = 1:3
%         acc_data{acc_ind(k)}(:,ax) =...
%             decimate(acc_data{acc_ind(k)}(:,ax),deci_ratio);
%     end
% end

%% Analysis 
if is_disp    
    % Raw signals------------------------------
    for ax = 1:3 % 1:X-axis, 2:Y-axis, 3:Z-axis
        figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8],...
            'Name',sprintf('%s-axis',axis_label{ax}))
        for k = 1:length(acc_ind)
            subplot(14,3,k)
            if ~isempty(acc_data{acc_ind(k)})
                t = linspace(0,samp_time,samp_num(acc_ind(k)));
                
                plot(t, acc_data{acc_ind(k)}(:,ax));
                
                ylabel(sprintf('%d',acc_ind(k)));
                xlim([t(1) t(end)])
                if yRange > 0
                    ylim([-yRange yRange])
                end
                
                box off
                if k<42
                    xticks([])
                end
            else
                text(0.1,0.5,sprintf('Acc %d is broken',acc_ind(k)),...
                    'Color','r');
                axis off
            end
        end
        xlabel('Time (Secs)')
    end
end
