function analyzeData( dat, time_stamp, subplt_h, is_log )
%% Analyze data
% Author: Yitian Shao
% Date: 11/29/2016
%==========================================================================
if nargin < 4
    is_log = 1; % Plot spectrum in log scale by default
end
avg_kernel = ones(20,1)/20;

signal_en = length(dat);
if length(time_stamp) == signal_en
    acc_freq = signal_en/time_stamp(end);
elseif isscalar(time_stamp)
    acc_freq = signal_en/time_stamp;
    time_stamp = linspace(0, time_stamp, signal_en+1);
else
    error('Invalid input argument: length mismatch between data and time!')
end
fprintf('Sampling frequency = %.0f Hz\n', acc_freq);

% Temporal plot-------------------------------
plot(subplt_h{1}, time_stamp(1:signal_en),dat);
xlabel(subplt_h{1}, 'Time (secs)');
ylabel(subplt_h{1}, 'Amplitude');

% Frequency plot------------------------------
dat = dat - mean(dat);
[ spect, freq ] = powerSpectrum(dat, acc_freq, [0.1, 0.5*acc_freq]);
smooth_spect = filter(avg_kernel, 1, spect);
[~,descend_ind] = sort(smooth_spect,'descend');
peak_freq = mean(freq(descend_ind(1:5)));
fprintf('        Peak frequency = %.3f Hz\n',peak_freq);

if is_log
    plot(subplt_h{2}, freq, 20*log10(spect));
    hold on
    plot(subplt_h{2}, freq, 20*log10(smooth_spect), 'c');
    ylabel(subplt_h{2}, 'DB');
else
    plot(subplt_h{2}, freq, spect);
    hold on
    plot(subplt_h{2}, freq, smooth_spect, 'c');
    ylabel(subplt_h{2}, 'Amplitude');
end
vline_range = get(subplt_h{2}, 'ylim');
plot(subplt_h{2}, [peak_freq,peak_freq], vline_range, '--r');
% text(subplt_h{2}, peak_freq, vline_range(2)+14,...
%     sprintf('Peak freq = %.3f Hz', peak_freq), 'Color','red');
text(peak_freq+2, vline_range(2)-10,...
    sprintf('Peak freq = %.3f Hz', peak_freq), 'Color','red');
xlabel(subplt_h{2}, 'Frequency (Hz)');
end

%% Local function: Compute Power Spectrum using FFT
function [ output_data, output_f ] = powerSpectrum( input_data, Fs,...
    frequencRange )
L=length(input_data); % Sampling data number
NFFT = 2^nextpow2(L); % Next power of 2 from length of y

Y_fft = fft(input_data, NFFT)/L; % FFT 
f = Fs/2*linspace(0, 1, NFFT/2+1); % Frequency scale

abs_Y_fft = 2*abs(Y_fft(1:NFFT/2+1)); % Power spectrum 

if nargin < 3 % No truncation    
    output_data=abs_Y_fft;
    output_f=f;
else % Truncate certain frequency range    
    minF=find(f>=frequencRange(1));
    maxF=find(f<=frequencRange(2));
    freRange=intersect(minF,maxF);
    output_data=abs_Y_fft(freRange,:);
    output_f=f(freRange);
end
end