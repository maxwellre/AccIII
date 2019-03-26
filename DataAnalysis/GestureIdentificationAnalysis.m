%% Gesture Identification Analysis
% Created on 03/25/2019
%--------------------------------------------------------------------------
ChannelNum = 46;

Data_Path = 'Data';
Measure_Freq = [20,50,100,200,250,300,500];
Measure_Type = sprintfc('%03dHz_sine',Measure_Freq);
temp = {'ClickMouse_II_III','GrabHandleAndRelease','GrabTengenri',...
    'PlayPhone_I','PowerGripCylinder','PricisionGripCylinder','Tap1to5',...
    'TapKeyBoard2018','WritingRETouch'};
Measure_Type = [Measure_Type,temp];
data_num = length(Measure_Type);

acc_ind = setdiff(1:ChannelNum,[10,20,30,40]);
disp_num = length(acc_ind);

if ~( exist('acc_data','var')&&exist('t','var')&&exist('Fs','var') )
    try
        load('SixteenGestures.mat');    
    catch
        disp('Preload failed - Redo data conversion!');
        
        acc_data = cell(data_num,1);
        t = cell(data_num,1);
        Fs = zeros(data_num,1);
        for i = 1:data_num
            [acc_data{i}, t{i}, Fs(i) ] =...
                readAccIII(fullfile(Data_Path,Measure_Type{i},'data.bin'),...
                fullfile(Data_Path,Measure_Type{i},'data_rate.txt'), 0);
            fprintf('Data %s loaded\n',Measure_Type{i})
        end
    end
end

%--------------------------------------------------------------------------
% Data Preprocessing
dsFreq = 1294; % Downsample to 1294 Hz
segDuration = 5; % 5 sec duration
tSync = 0:(1/dsFreq):(5 -1/dsFreq); % Synchronized time stamps

accAmp = cell(data_num,1);
for i = 1:data_num
    accAmp{i} = zeros(segDuration*dsFreq,ChannelNum);
    
%    % RMS amplitude (Inaccurate representation)
%     for ax_i = 1:3
%         temp = acc_data{i}(:,:,ax_i);
%         temp = resample(temp,dsFreq*10,round(Fs(i)*10));       
%         temp = detrend(temp,'constant');
%         accAmp{i} = accAmp{i} + temp(1:(segDuration*dsFreq),:).^2;        
%     end
%     accAmp{i} = accAmp{i}.^0.5;
    
    % Projected waveform
    for ch_i = acc_ind
        temp = squeeze(acc_data{i}(:,ch_i,:));
        temp = resample(temp,dsFreq*10,round(Fs(i)*10));       
        temp = detrend(temp(1:(segDuration*dsFreq),:),'constant');
        [~,score,~] = pca(temp); % PCA
        accAmp{i}(:,ch_i) = score(:,1);
    end
end

