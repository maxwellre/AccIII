% -------------------------------------------------------------------------
addpath('../../WaveReconstructModel/');
% -------------------------------------------------------------------------

dataPath = '.\Tap Plamar\TapPalm_Loc9.mat';

TrialNum = 11;
correctFactor = [0.9993 1.0090]; % Mean factor (STD = 0.0008 Hz)

arrayLabel = {'Palm', 'Dorsum'};
% -------------------------------------------------------------------------
if ~exist('dist_map','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','dist_map');
end
if ~exist('m_obj','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','m_obj');
end
% -------------------------------------------------------------------------
% Data segmentation
dataSeg = segmentData(dataPath, TrialNum, 0, correctFactor);

if 0 % -------------------------------------------------------------------- 
%% (Optional) show all signals
dispInd = 1:100;
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
avgLen = 0.1; % Average time length (secs) 
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
            
            amp = (temp(:,1).^2 + temp(:,2).^2 + temp(:,3).^2).^0.5;
            avgSegRMSEn(b,i,j) = rms(amp);
        end       
    end
end

%--------------------------------------------------------------------------
%% 3D plot
% Interpolation weight construction
Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0; 

v_color{1} = Phi*(squeeze(avgSegRMSEn(1,:,:))'); % A
v_color{2} = Phi*(squeeze(avgSegRMSEn(2,:,:))'); % B

cmap = jet(1000);
%--------------------------------------------------------------------------
Default_View = [-100 75];
ctext = 'k'; % Color of axes and text

fig1 = figure('Position',get(0,'ScreenSize').*[20,80,0.98,0.8]);
set(fig1, 'Color', 'w');

for b = 1:2
    color_range = [min(v_color{b}(:)), max(v_color{b}(:))];   
    for j = 1:10 % Show only last ten trials
        subplot(4,5,(b-1)*10+j)
        colormap(cmap);
        scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
            2,v_color{b}(:,j+1),'Filled')
        axis equal
        view(Default_View)
 
        currLabel = sprintf('%s-%d',arrayLabel{b},j);
        title(currLabel);

        fprintf('%s [Range: %.2f - %.2f]\n',currLabel, caxis);
        axis off
        set(gca,'FontSize',8,'Color','none','XColor',ctext,'YColor',ctext,...
            'ZColor',ctext)
    end
end
