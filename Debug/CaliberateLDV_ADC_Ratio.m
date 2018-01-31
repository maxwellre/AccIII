%% Caliberate LDV: analog to digital ratio
% [8.8303,8.9754,8.4152,8.5453,8.4411,8.9008,8.8494,9.1104,9.5788,8.9566]

[peaks,locs] = findpeaks(LDV_data,LDVSamplingFreq);

% mins = findpeaks(-LDV_data);
% peak2peak = (maxs + mins);
% peak2peak = peak2peak(peak2peak>0.1);
% figure; hist(peak2peak,100);

Oscilloscope_p2p = 2.62;


peak2peak = mean(peaks(peaks>0.1)) - mean(peaks(peaks<-0.1));

fprintf('Positive: %d, Negative: %d\n',sum(peaks>0.1),sum(peaks<-0.1));

DAC_ratio = Oscilloscope_p2p/(peak2peak)