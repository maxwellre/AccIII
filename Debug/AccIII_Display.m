%% Test and display the accelerometer array data (Design III)
% Using LDV to caliberate the accelerometer array
% Created on 06/01/2017
% Updated on 07/14/2017 New data format from new board
% Updated on 08/15/2017 Corrected unit scale
% Updated on 09/05/2017 New data reading format
% Updated on 01/10/2018 Run exe and synchronize data
%--------------------------------------------------------------------------
close all

expected_samp_time = 4.2;

disp('Sampling...')
[status,cmdout] = system(sprintf('AccIII.exe %.2f', expected_samp_time));

disp(cmdout)

%%
if ~status
    [acc_data, Fs, t] = syncAccIII('data.bin','sample_time.txt',0,1);
    
    fprintf('Actually sampling time = %.4f secs\n', t(end));
end

%% ------------------------------------------------------------------------
% Spectrum analysis
if 0    
    axis_label = {'X', 'Y', 'Z'};
    acc_ind = setdiff(1:46,[10,20,30,40]);
%     for ax = 1:3 % 1:X-axis, 2:Y-axis, 3:Z-axis
    for ax = 3
        figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8],...
            'Name',sprintf('%s-axis',axis_label{ax}))
        for k = 1:length(acc_ind)
            subplot(14,3,k)
            if ~isempty(acc_data{acc_ind(k)}) 
                samp_freq = Fs;
                [acc_FT,f] = spectr(acc_data{acc_ind(k)}(:,ax),samp_freq);
                plot(f, acc_FT);
                
                ylabel(sprintf('%d',acc_ind(k)));
                xlim([f(1) f(end)])
                
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
        xlabel('Frequency (Hz)')
    end
end