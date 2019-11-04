% Signals to be sent to actuator for measurements with accelerometer arrays
% on both sides of the hand
% Protocol listed - https://docs.google.com/spreadsheets/d/1EzjZjUhMcyXwryn78g4z3Mp9YM-0Z_duSRy-Gow-oKY/edit#gid=0
% Written by Bharat Dandu - 10/31/19

%% % Signal Design, link to MOTU 

% To correctly set up Motu connection, run audiodevinfo command. Assuming 
% Main outs are hooked up to amplifier, note down the Motu speaker devID
devID = 4;

fs = 48000; 

% Tapping Signals - Impulsive forces
tapSignal = zeros(1,1*fs);  % 1 second long signal
tapSignal((fs/10+1):round(fs/10+fs/100)) = 0.5;  % Tap signal is an 1ms impulse, filtered through the actuator response. Starts after 100ms of silence
tapSignal = repmat(tapSignal,1,11);     % 11 copies of the signal;

tapOut = audioplayer([zeros(1,1*fs),tapSignal],fs,16,devID);

% Windowed Sinusoidal Freqs
t = (1/fs):(1/fs):.5;   % Actual Sinusoid is 500ms long
win = tukeywin(length(t),.2)';   % Tukey Window
zeroPad = zeros(1,fs/4);    % 250ms zero padding

% Create the windowed sines
sin40Sig = 0.45*sin(2*pi*40*t).*win;
sin80Sig = 0.6*sin(2*pi*80*t).*win;
sin120Sig = 0.35*sin(2*pi*120*t).*win;
sin160Sig = 0.3*sin(2*pi*160*t).*win;
sin240Sig = 0.3*sin(2*pi*240*t).*win;
sin320Sig = 0.3*sin(2*pi*320*t).*win;
sin480Sig = 0.3*sin(2*pi*480*t).*win;
sin640Sig = 0.3*sin(2*pi*640*t).*win;

% Pad out, repeat
sin40Sig = repmat([zeroPad sin40Sig zeroPad],1,11);
sin80Sig = repmat([zeroPad sin80Sig zeroPad],1,11);
sin120Sig = repmat([zeroPad sin120Sig zeroPad],1,11);
sin160Sig = repmat([zeroPad sin160Sig zeroPad],1,11);
sin240Sig = repmat([zeroPad sin240Sig zeroPad],1,11);
sin320Sig = repmat([zeroPad sin320Sig zeroPad],1,11);
sin480Sig = repmat([zeroPad sin480Sig zeroPad],1,11);
sin640Sig = repmat([zeroPad sin640Sig zeroPad],1,11);

% Create the relevant audioplayer objects
sin40Out = audioplayer([zeros(1,1*fs),sin40Sig],fs,16,devID);
sin80Out = audioplayer([zeros(1,1*fs),sin80Sig],fs,16,devID);
sin120Out = audioplayer([zeros(1,1*fs),sin120Sig],fs,16,devID);
sin160Out = audioplayer([zeros(1,1*fs),sin160Sig],fs,16,devID);
sin240Out = audioplayer([zeros(1,1*fs),sin240Sig],fs,16,devID);
sin320Out = audioplayer([zeros(1,1*fs),sin320Sig],fs,16,devID);
sin480Out = audioplayer([zeros(1,1*fs),sin480Sig],fs,16,devID);
sin640Out = audioplayer([zeros(1,1*fs),sin640Sig],fs,16,devID);

% play(tapOut);










