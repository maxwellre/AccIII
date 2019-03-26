%% Gesture Identification Analysis
% Created on 03/25/2019
%--------------------------------------------------------------------------
Data_Path = 'Data';
Measure_Freq = [20,50,100,200,250,300,500];
Measure_Type = sprintfc('%03dHz_sine',Measure_Freq);
temp = {'ClickMouse_II_III','GrabHandleAndRelease','GrabTengenri',...
    'PlayPhone_I','PowerGripCylinder','PricisionGripCylinder','Tap1to5',...
    'TapKeyBoard2018','WritingRETouch'};
Measure_Type = [Measure_Type,temp];
data_num = length(Measure_Type);

acc_ind = setdiff(1:46,[10,20,30,40]);
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



