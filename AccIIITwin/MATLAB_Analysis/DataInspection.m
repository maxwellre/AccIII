dataPath = '.\Tap Plamar\TapPalm_Loc1.mat';

TrialNum = 11;
correct_factor = [0.9993 1.0090]; % Mean factor (STD = 0.0008 Hz)

dataSeg = segmentData(dataPath, TrialNum, correct_factor);