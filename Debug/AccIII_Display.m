%% Test and display the accelerometer array data (Design III)
% Using LDV to caliberate the accelerometer array
% Created on 06/01/2017
% Updated on 07/14/2017 New data format from new board
% Updated on 08/15/2017 Corrected unit scale
% Updated on 09/05/2017 New data reading format
% Updated on 01/10/2018 Run exe and synchronize data
% Updated on 01/23/2018 Read AccIII (NoID data format)
% Updated on 05/09/2019 Acc Revive whole hand measurement
%--------------------------------------------------------------------------
close all
%--------------------------------------------------------------------------
NoID = 1;

expected_samp_time = 13;

disp('Sampling...')
if NoID
    % If NoID
    [status,cmdout] =...
        system(sprintf('AccIII.exe %.2f', expected_samp_time*0.45));
else
    [status,cmdout] =...
        system(sprintf('AccIII.exe %.2f', expected_samp_time));
end

disp(cmdout)

%%
if ~status
    if NoID
        [acc_data, t, Fs ] = readAccRevi('data.bin','data_rate.txt', 1);
        trunc_ind = (t <= expected_samp_time);
        t = t(trunc_ind);
        acc_data = acc_data(trunc_ind,:,:); % Truncate
    else
        [acc_data, Fs, t] = syncAccIII('data.bin','sample_time.txt',0,1);
    end
    fprintf('Actually sampling time = %.4f secs\n', t(end));
end

%% ------------------------------------------------------------------------
% Spectrum analysis
if 0    
    axis_label = {'X', 'Y', 'Z'};
    acc_ind = setdiff(1:46,[10,20,30,40]);
    
    acc_spectr = [];
    acc_allAmp = [];
    for k = 1:length(acc_ind)      
%         acc_Amp = (acc_data(:,acc_ind(k),1).^2 +...
%             acc_data(:,acc_ind(k),2).^2 +...
%             acc_data(:,acc_ind(k),3).^2).^0.5;
%         acc_allAmp = [acc_allAmp,acc_Amp];
        
        % 1:X-axis, 2:Y-axis, 3:Z-axis
        [acc_FT_X,~] = spectr(acc_data(:,acc_ind(k),1),Fs);
        [acc_FT_Y,~] = spectr(acc_data(:,acc_ind(k),2),Fs);
        [acc_FT_Z,f] = spectr(acc_data(:,acc_ind(k),3),Fs);
        acc_FT = (acc_FT_X.^2 + acc_FT_Y.^2 + acc_FT_Z.^2).^0.5;
        acc_spectr = [acc_spectr,acc_FT];
    end
    temp = acc_spectr(f > 0,:);
    yMax = max(temp(:));
    
    figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8],...
        'Name','Spectrum')

    for k = 1:length(acc_ind)
        subplot(14,3,k)
        plot(f, acc_spectr(:,k));
%         plot(acc_allAmp(:,k));
        
        axis([f(1) f(end) 0 yMax]);

        box off
        if k < 42
            xticks([])
        end
        if k == 19
            ylabel({'Amplitude (g)';sprintf('%d',acc_ind(k))});
        else
            ylabel(sprintf('%d',acc_ind(k)));
        end
    end
    xlabel('Frequency (Hz)')
end