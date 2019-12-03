% -------------------------------------------------------------------------
addpath('../../WaveReconstructModel/');
% -------------------------------------------------------------------------
locNum = 2

dataPath = sprintf('./FullSetData_Yit/Tap Palmar/TapPalm_Loc%d_1Hz.mat',...
    locNum);

TrialNum = 10;

avgLen = 0.3; % Average time length (secs) 

arrayLabel = {'Palm', 'Dorsum'};

% handPlane = [0.0234307671, -0.0022175929, -0.0272901326];

% -------------------------------------------------------------------------
if ~exist('dist_map','var')
    load('PalmAndDorsum84Acc_Radius64mm.mat','dist_map');
end
if ~exist('m_obj','var')
    load('PalmAndDorsum84Acc_Radius64mm.mat','m_obj');
end

% Interpolation weight construction
Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0; 

% -------------------------------------------------------------------------
if (locNum == 1)
    thresh_ratio = 0.06;
elseif (locNum == 7) 
    thresh_ratio = 0.1;
elseif (locNum == 9)
    thresh_ratio = 0.27;
elseif (locNum == 11)
    thresh_ratio = 0.06;
else
    thresh_ratio = 0.04;
end
% Data segmentation
dataSeg = segmentDataOrigin(dataPath, TrialNum, thresh_ratio, 1);

if 0 % -------------------------------------------------------------------- 
%% (Optional) show all signals
dispInd = 1:round(avgLen*1290);
figure('Position',get(0,'ScreenSize').*[20,20,0.9,0.9]);
for i = 1:TrialNum
    for j = 1:3
        subplot(TrialNum,6,(i-1)*6+j)
        plot(dataSeg{i,1}(dispInd),dataSeg{i,2}(dispInd,:,j))
    end
    for j = 1:3
        subplot(TrialNum,6,(i-1)*6+3+j)
        plot(dataSeg{i,3}(dispInd),dataSeg{i,4}(dispInd,:,j))
    end
end
end

%% Process data for visualization
accInd = setdiff(1:46,[10,20,30,40]);
accNum = length(accInd);

%--------------------------------------------------------------------------
avgSegRMSEn = nan(2,TrialNum,accNum); % Averaged segment RMS energy
for i = 1:TrialNum % Trial index
    for b = 1:2 % Board index
        t = dataSeg{i,2*b-1};
        t = t - t(1);
        avgEndInd = find(t >= avgLen, 1);
        
        accData = dataSeg{i,2*b};
        
        % DC-filtering -----------------------------------
        accData = bsxfun(@minus, accData, mean(accData,1));
        
        for j = 1:accNum % Accelerometer index
            temp = squeeze(accData(1:avgEndInd,accInd(j),:));

            avgSegRMSEn(b,i,j) = sum(rms(temp).^2).^0.5;

% % %             amp = (temp(:,1).^2 + temp(:,2).^2 + temp(:,3).^2).^0.5;
% % %             avgSegRMSEn(b,i,j) = rms(amp);
        end       
    end
end

%% 3D plot of trial average
avgSegRMSEn_FullHand = [squeeze(avgSegRMSEn(1,:,:)),...
    squeeze(avgSegRMSEn(2,:,:))]; % [Palm data(A), Dorsum data (B)]

% v_color = Phi*(mean(avgSegRMSEn_FullHand,1,'omitnan')');
v_color = Phi*(mean(avgSegRMSEn_FullHand(1:10,:),1)');

cmap = jet(1000);
% % % cmap = cmap(1:end-60,:);

Default_View = [-100 75];
ctext = 'k'; % Color of axes and text

for b = 1:2
%     subplot('Position',[0.05+0.48*(b-1),0.05,0.45,0.9]);
    fig_h = figure('Position',[20,0,800,560],'Color', 'w');
    colormap(cmap);
    scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
       18,'k','Filled');
    hold on;
    scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
       16,v_color,'Filled');
    axis equal;
    if (b == 1)
        view(-Default_View); % View palm
        camroll(160);
    elseif (b == 2)
        view(Default_View); % View dorsum
    end
    currLabel = arrayLabel{b};
%     title(currLabel);
    fprintf('%s [Range (g): %.2f - %.2f]\n',currLabel, caxis);
    fprintf('%s [Range (m/s^2): %.2f - %.2f]\n',currLabel, caxis.*9.8);
    axis off
%     colorbar('TickLabels',[],'Ticks',[],'box','off');
    set(gca,'FontSize',8,'Color','none','XColor',ctext,'YColor',ctext,...
        'ZColor',ctext)
    
%     print(fig_h,sprintf('RevFig_ComparePalmDorsum/Loc%d_%s',...
%         locNum,currLabel),'-dpng','-r600');    
% % % %     print(fig_h,sprintf('RevFig_ComparePalmDorsum/Loc%d_%s',...
% % % %         locNum,currLabel),'-dpdf','-painters'); % Vectorized Graphics
    pause(0.1); 
%     close(fig_h);
end

%--------------------------------------------------------------------------
