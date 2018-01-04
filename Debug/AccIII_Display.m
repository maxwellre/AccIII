%% Test and display the accelerometer array data (Design III)
% Using LDV to caliberate the accelerometer array
% Created on 06/01/2017
% Updated on 07/14/2017 New data format from new board
% Updated on 08/15/2017 Corrected unit scale
% Updated on 09/05/2017 New data reading format
%--------------------------------------------------------------------------
close all
[acc_data, Fs ] = decodeAccIII('data.bin','sample_time.txt',0);

%--------------------------------------------------------------------------
% % % Spectrum
% % [ acc_FT, f ] = spectr(acc_data(:,:,ax), Fs);
% % for q=0:1
% % figure('Position', get(0,'ScreenSize').*[10 50 0.95 0.8])
% % for k = 1:24
% %     subplot(8,3,k)
% %     plot(f, acc_FT(:,q*24+acc_ind(k)));
% %     ylabel(sprintf('Acc %d-%s',q*24+acc_ind(k),axis_label{ax}));
% % end
% % xlabel('Frequency (Hz)')
% % end
