%% Location-dependent Frequency Response
% Created on 05/17/2018
%--------------------------------------------------------------------------
Data_Path = 'Data';
Measure_Freq = [20,50,100,200,250,300,500];
data_num = length(Measure_Freq);
Measure_Type = sprintfc('%03dHz_sine',Measure_Freq);

acc_ind = setdiff(1:46,[10,20,30,40]);
disp_num = length(acc_ind);


if ~( exist('acc_data','var')&&exist('t','var')&&exist('Fs','var') )
    acc_data = cell(data_num,1);
    t = cell(data_num,1);
    Fs = zeros(data_num,1);
    for i = 1:data_num
        [acc_data{i}, t{i}, Fs{i} ] =...
            readAccIII(fullfile(Data_Path,Measure_Type{i},'data.bin'),...
            fullfile(Data_Path,Measure_Type{i},'data_rate.txt'), 0);
        fprintf('Data %s loaded\n',Measure_Type{i})
    end
end

accSpect = zeros(data_num,disp_num);
freq = cell(data_num,1);
for i = 1:data_num
    freqRange = [Measure_Freq(i)-1,Measure_Freq(i)+1];
    t_ind = (t{i} >= 0.005) & (t{i} <= 5.005);
    curr_sigX = acc_data{i}(t_ind,acc_ind,1);
    curr_sigY = acc_data{i}(t_ind,acc_ind,2);
    curr_sigZ = acc_data{i}(t_ind,acc_ind,3);
    axSpectX = spectr(curr_sigX, Fs{i}, freqRange);
    axSpectY = spectr(curr_sigY, Fs{i}, freqRange);
    [axSpectZ, freq{i}] = spectr(curr_sigZ, Fs{i}, freqRange);
    accSpect(i,:) = mean((axSpectX.^2+axSpectY.^2+axSpectZ.^2).^0.5);
    [~,ind] = max(accSpect(i,:));
    fprintf('[%s] Highest amplitude: Acc %d\n',Measure_Type{i},...
        acc_ind(ind));
    fprintf('Frequency = %.2f +/- %.2f\n',mean(freq{i}),std(freq{i}))
end

%% Plot frequency response
baseSpect = accSpect(:,(acc_ind==31));
figure('Name','RMS amplitude', 'Position',[120,120,840,600]);
hold on
for acc_i = 32:39
    discreteTF = accSpect(:,(acc_ind==acc_i))./baseSpect;
    plot(Measure_Freq,20*log10(discreteTF))
end
hold off
legend(sprintfc('Acc %d',32:39),'Location','northeastoutside')
legend boxoff
xlabel('Frequency (Hz)')
ylabel('Frequency response (dB)')
set(gca,'FontSize',16)
print(gcf,'LocDependFreqResponse','-dpdf','-painters');
