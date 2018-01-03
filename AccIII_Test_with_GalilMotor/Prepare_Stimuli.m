%% Prepare stimuli signals for the DMC motor
%--------------------------------------------------------------------------
% Generate stimuli signals and write into .csv files, which will be loaded 
% into GalilTools as arrays.
% Use 'streamCSV.dmc' to play the produced signal.
%--------------------------------------------------------------------------
% Author: Yitian Shao (syt@ece.ucsb.edu)
% Created on 11/06/2016
% Updated on 11/28/2016
% Updated on 01/09/2017 Produce chirp signal with constant offset amplitude
%--------------------------------------------------------------------------
%% Configuration===========================================================
signal_type = 1; % Signal type =0: Sine, otherwise, type =1: Chirp
% type =2: Constant acceleration chirp

sine_freq = 100; % Set frequency of the sinusoidal wave to be produced

chirp_f0 = 10; % Instantaneous frequency at time 0 for chirp
chirp_f1 = 2000; % Instantaneous frequency at end time for chirp

is_display = 1;  % =1 to display produced signal and its spectrum
%% ========================================================================
SignalMaximumLength = 15999; % Maximum memory storage of DMC controller
% DMCFrequency = 6984; % Pre-calibrated (DO NOT CHANGE)
DMCFrequency = 6896; % Caliberated on 06/01/2017
samp_t = 1/DMCFrequency;
t = (1:SignalMaximumLength)*samp_t;

if signal_type % Chirp-----------------------------------------------------
    chirp_signal = 0.01*chirp(t,chirp_f0,t(end),chirp_f1); 
    if signal_type==2 % type =2: Constant acceleration chirp
        off_set0 = chirp_signal(1); % Offset of first-order derivative
        off_set1 = chirp_signal(2) -chirp_signal(1); % Offset of second-order derivative
        chirp_signal = diff(chirp_signal,2); % Second order derivative
        %     K = (chirp_f1 -chirp_f0)/(t(end)-t(1)); % Frequency f(t) = K*t + f(0)
        %     chirp_signal = 2*K*cos(K.*t.^2 +chirp_f0.*t) -...
        %         ((2*K.*t +chirp_f0).^2).*sin(K.*t.^2 +chirp_f0.*t);
    end
    
    threshold = abs(chirp_signal(1));
    en_index = find(chirp_signal>threshold);
    if ~isempty(en_index)
        signal_en = en_index(end);
    else
        signal_en = SignalMaximumLength;
    end
    output_signal = chirp_signal(1:signal_en);
    
    
    % Output signal as .csv file
    if signal_type==1
        file_id = fopen(sprintf('chirp_%dhz_%dhz.csv',chirp_f0,chirp_f1), 'w');
    elseif signal_type==2
        file_id = fopen(sprintf('diff_chirp_%dhz_%dhz.csv',chirp_f0,chirp_f1), 'w');
    end
    fprintf(file_id, '%s', 'signal');
    fprintf(file_id, '\n%d', signal_en);
    fprintf(file_id, '\n%f', output_signal);
    fclose(file_id);
    
    % Information
    disp('Sine signal generated');
    fprintf('Signal length = %d (%f seconds)\n', signal_en,t(signal_en));
    fprintf('DMC Loop Frequency = %d Hz\n',DMCFrequency);
    fprintf('Sinewave Frequency = %d Hz\n',sine_freq);
else % Sinewave------------------------------------------------------------
    sine_time_period = 1/sine_freq;
 
    sinewave = sin(2*pi*t/sine_time_period);
    cosinewave = cos(2*pi*t/sine_time_period);
    
    % Ensure full cycle
    threshold = -abs(sinewave(1));
    en_index = find(sinewave<=0 & threshold<sinewave & cosinewave>=0);
    signal_en = en_index(end);
    output_signal = 1000*sinewave(1:signal_en);
    
    % Output signal as .csv file
    file_id = fopen(sprintf('sine%dhz.csv',sine_freq), 'w');
    fprintf(file_id, '%s', 'signal');
    fprintf(file_id, '\n%d', signal_en);
    fprintf(file_id, '\n%f', output_signal);
    fclose(file_id);
    
    % Information
    disp('Sine signal generated');
    fprintf('Signal length = %d (%f seconds)\n', signal_en,t(signal_en));
    fprintf('DMC Loop Frequency = %d Hz\n',DMCFrequency);
    fprintf('Sinewave Frequency = %d Hz\n',sine_freq);
end

if is_display % Display----------------------------------------------------
% signal_type % Display second-order integration for chirp
% output_signal = cumsum(cumsum(output_signal)+off_set1)+off_set0;
    
    [ spect, freq ] = spectr(output_signal, DMCFrequency);
%     [ spect, freq] = periodogram(output_signal,[],[],DMCFrequency);
    [~,descend_ind] = sort(spect,'descend');
    peak_freq = mean(freq(descend_ind(1:10)));
    fprintf('Peak frequency = %.3f Hz\n',peak_freq)
    
    figure('Position',[40,100,1800,800]);
    subplot(2,1,1);
    plot(t(1:signal_en),output_signal);
    xlabel('Time (secs)');
    ylabel('Amplitude');
    subplot(2,1,2);
    plot(freq,spect);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
end