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
        [acc_data{i}, t{i}, Fs(i) ] =...
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
    axSpectX = spectr(curr_sigX, Fs(i), freqRange);
    axSpectY = spectr(curr_sigY, Fs(i), freqRange);
    [axSpectZ, freq{i}] = spectr(curr_sigZ, Fs(i), freqRange);
    accSpect(i,:) = mean((axSpectX.^2+axSpectY.^2+axSpectZ.^2).^0.5);
    [~,ind] = max(accSpect(i,:));
    fprintf('[%s] Highest amplitude: Acc %d\n',Measure_Type{i},...
        acc_ind(ind));
    fprintf('Frequency = %.2f +/- %.2f\n',mean(freq{i}),std(freq{i}))
end

%% Plot frequency response
% Plot_Sytle = {'r.','b.','k.','g.','r+','b+','k+','g+'};
Color_Pool = [0, 130, 200; 40, 180, 55; 145, 30, 180; 245, 130, 48;
              230, 25, 75; 205, 185, 25; 0, 0, 0; 0, 0, 128]./255;
disp_acc_ind = 32:39;
FR_Range = 1:647;
plt_h = [];
baseSpect = accSpect(:,(acc_ind==31));
figure('Name','RMS amplitude', 'Position',[120,120,840,600]);
hold on
for i = 1:length(disp_acc_ind)
    discreteTF = accSpect(:,(acc_ind==disp_acc_ind(i)))./baseSpect;
    logTF = 20*log10(discreteTF);
    fit_h = fit(Measure_Freq',logTF,'smoothingspline');
    
    dplt_h = plot(Measure_Freq,logTF,'.','MarkerSize',10,...
        'Color',Color_Pool(i,:));
%     curr_color = get(dplt_h,'Color');
    plt_h = [plt_h, plot(FR_Range,fit_h(FR_Range),'Color',Color_Pool(i,:))];

%     plt_h = [plt_h, plot(FR_Range,fit_h(FR_Range))];
end
hold off
legend(plt_h, sprintfc('Acc %d',disp_acc_ind),'Location','northeastoutside')
legend boxoff
xlim([0 650])
xlabel('Frequency (Hz)')
ylabel('Frequency response (dB)')
set(gca,'FontSize',16)
% print(gcf,'LocDependFreqResponse','-dpdf','-painters');
