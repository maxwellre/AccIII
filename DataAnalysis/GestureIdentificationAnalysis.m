%% Gesture Identification Analysis
% Created on 03/25/2019
%--------------------------------------------------------------------------
ChannelNum = 46;

Data_Path = 'Data';
Measure_Freq = [20,50,100,200,250,300,500];
Measure_Type = sprintfc('%03dHz_sine',Measure_Freq);
temp = {'ClickMouse_II_III','GrabHandleAndRelease','GrabTengenri',...
    'PlayPhone_I','PowerGripCylinder','PricisionGripCylinder','Tap1to5',...
    'TapKeyBoard2018','WritingRETouch'};
Measure_Type = [Measure_Type,temp];
data_num = length(Measure_Type);

acc_ind = setdiff(1:ChannelNum,[10,20,30,40]);
disp_num = length(acc_ind);

if ~( exist('acc_data','var')&&exist('t','var')&&exist('Fs','var') )
    try
        load('SixteenGestures.mat');    
    catch
        disp('Preload failed - Redo data conversion!');
        
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
end

%--------------------------------------------------------------------------
% Data Preprocessing
dsFreq = 1294; % Downsample to 1294 Hz
segDuration = 5; % 5 sec duration
tSync = 0:(1/dsFreq):(5 -1/dsFreq); % Synchronized time stamps

accAmp = cell(data_num,1);
for i = 1:data_num
    accAmp{i} = zeros(segDuration*dsFreq,ChannelNum);   
    
    % Projected waveform
    for ch_i = acc_ind
        temp = squeeze(acc_data{i}(:,ch_i,:));
        temp = resample(temp,dsFreq*10,round(Fs(i)*10));       
        temp = detrend(temp(1:(segDuration*dsFreq),:),'constant');
        [~,score,~] = pca(temp); % PCA
        accAmp{i}(:,ch_i) = score(:,1);
    end
end
%__________________________________________________________________________
if 1 
%% Pearson Correlation Analysis
CorrMat = NaN(data_num,data_num);
for i = 8:data_num
    for j = i:data_num
        corrRes = zeros(segDuration*dsFreq*2-1,1);
        for ch_i = acc_ind
            sig1 = accAmp{i}(:,ch_i)./std(accAmp{i}(:,ch_i));
            sig2 = accAmp{j}(:,ch_i)./std(accAmp{j}(:,ch_i));
            corrRes = corrRes +xcorr(sig1,sig2);
        end
        CorrMat(i,j) = max(abs(corrRes));
    end
end
CorrMat = 100*bsxfun(@rdivide, CorrMat, diag(CorrMat));

% Plot Similarity Matrix
figure('Position',[40,80,860,820],'Color','w');
h = heatmap(CorrMat);
h.YLabel = 'Gesture';
h.XLabel = 'Gesture';
h.Colormap = flipud(gray(1000));
h.CellLabelFormat = '%.0f';
h.FontSize = 10;
h.Title = 'Similarity (%)';
h.GridVisible = 'off';
h.XDisplayLabels = Measure_Type;
h.YDisplayLabels = Measure_Type;
end %______________________________________________________________________

%% Frequency Band Analysis
% freqBand = [0, 10, 20, 40, 80, 160, 320, 640];
% freqBandNum = length(freqBand)-1;
% 
% spectEn = cell(data_num,1);
% for i = 1:data_num
%     spectEn{i} = nan(freqBandNum,disp_num);
%     
%     [accSpect,f] = spectr(accAmp{i}(:,acc_ind),dsFreq);
%     for j = 1:freqBandNum
%         minF = find(f > freqBand(j));
%         maxF = find(f <= freqBand(j+1));
%         freRange = intersect(minF,maxF); % Frequency band index
%         spectEn{i}(j,:) = rms(accSpect(freRange,:));
%     end
% end

%% Plot Spectrum Engergy Distribution
% figure('Position',[40,80,860,820],'Color','w');
% colormap(flipud(gray(1000)));
% for i = 1:data_num
%     subplot(8,2,i);
%     imagesc(spectEn{i});
%     box off;
%     if (mod(i,2)==0)
%         set(gca,'yTick',[]);
%     else
%         set(gca,'yTick',(0:freqBandNum)+0.5,'yTickLabels',freqBand);
%     end
%     
%     if (i == 7)
%         ylabel('Frequency (Hz)');
%     end
%     
%     if (i < 15)
%         set(gca,'xTick',[]);
%     else
% % currTicks = get(gca,'xTick'); set(gca,'xTickLabels',acc_ind(currTicks));
%         set(gca,'xTick',1:42,'xTickLabels',acc_ind);
%     end
%     
%     if (i == 16)
%         xlabel('Accelerometer #');
%     end
%     
%     text(16,-0.6,Measure_Type{i},'Interpreter', 'none');
% end

%%
% FlatSpectEn = [];
% for i = 1:data_num
%     FlatSpectEn = [FlatSpectEn;spectEn{i}(:)'];  
% end
% pairedDist = pdist(FlatSpectEn);
% 
% % DissimilarMat = squareform(pairedDist);
% % figure('Position',[40,80,860,820],'Color','w');
% % h = heatmap(DissimilarMat);
% % h.YLabel = 'Gesture';
% % h.XLabel = 'Gesture';
% % h.Colormap = (gray(1000));
% % h.CellLabelFormat = '%.2f';
% % h.FontSize = 10;
% % h.GridVisible = 'off';
% % h.XDisplayLabels = Measure_Type;
% % h.YDisplayLabels = Measure_Type;
% 
% figure('Position',[40,80,860,820],'Color','w');
% dendrogram(linkage(pairedDist,'single'),...
%     'Labels',Measure_Type);
% xtickangle(40); set(gca, 'TickLabelInterpreter', 'none')

%% Time Series Modeling Preparation 
% slct_measure = 1;
% IDdata = iddata(accAmp{slct_measure},[],(1/dsFreq),...
%     'OutputName',sprintfc('Acc%d',1:ChannelNum),...
%     'OutputUnit',repmat('g',ChannelNum,1),...
%     'TimeUnit','seconds');

%% State Space Model (Need further exploration)
% sys = n4sid(IDdata(:,acc_ind));

%% Auto Regression Model (not suitable)
% modelOrder = 10;
% sys = ar(IDdata(:,1),modelOrder);

%% Test
%__________________________________________________________________________
if 0 
%% Display waveform of selected channel
figure('Position',[20,80,1600,800])
slct_channel = 31;
hold on;
for i = 1:data_num
    plot(tSync,accAmp{i}(:,ch_i));
end
hold off;
ylabel('Amplitude (g)');
xlabel('Time (secs)');
title(sprintf('Channel %d',slct_channel));
set(gca, 'FontSize',12);
legend(Measure_Type,'Interpreter', 'none');
end %______________________________________________________________________
