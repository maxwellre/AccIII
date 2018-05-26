%% Reconstruct wave on a 3D hand model
close all
% -------------------------------------------------------------------------
addpath('../WaveReconstructModel/');
% -------------------------------------------------------------------------
Data_Path = 'Data';
axis_label = {'X', 'Y', 'Z'};
% cmap = [0, 0, 0;
%         64, 64, 64;
%         0, 0, 128;
%         128, 0, 0;
%         170, 110, 40;
%         0, 128, 128
%         145, 30, 180
%         245, 130, 48
%         60, 180, 75
%         230, 25, 75
%        ]./255;
% cmap = [linspace(0,1,1000)', zeros(1000,1), linspace(1,0,1000)'];
cmap = 0.7*jet(1000);

%% ------------------------------------------------------------------------
gest_name = 'Tap1to5';
% gest_name = '100Hz_sine';
% -------------------------------------------------------------------------
[acc_data, t, Fs ] = readAccIII(fullfile(Data_Path,gest_name,'data.bin'),...
    fullfile(Data_Path,gest_name,'data_rate.txt'), 0);

if ~exist('dist_map','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','dist_map');
end
if ~exist('m_obj','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','m_obj');
end

%% ------------------------------------------------------------------------
disp_t_start = 0.0;
disp_t_end = 5.0;

disp_acc_i = setdiff(1:46,[10,20,30,40]);
disp_num = length(disp_acc_i);

%--------------------------------------------------------------------------
% DC-filtering
acc_data = bsxfun(@minus, acc_data,mean(acc_data,1));
%--------------------------------------------------------------------------
% t_ind = (t >= disp_t_start) & (t <= disp_t_end);
% t_ind_num = sum(t_ind);

% t_ind = [1415, 1919, 2413, 2916, 3425];
t_ind = 1913:1922;
t_ind_num = length(t_ind);

if disp_num == 1
    slctChannels = squeeze(acc_data(t_ind,disp_acc_i,:));
    yRange = [min(slctChannels(:)), max(slctChannels(:))];
elseif disp_num > 1
    slctChannels = zeros(t_ind_num,disp_num,3);
    proj_waveform = zeros(t_ind_num,disp_num);
    for i = 1:disp_num
        slctChannels(:,i,:) = acc_data(t_ind,disp_acc_i(i),:);
        amp = slctChannels(:,i,1).^2 + slctChannels(:,i,2).^2 +...
              slctChannels(:,i,3).^2;
        [~,max_i] = max(amp);
        proj_vector = squeeze(slctChannels(max_i,i,:));
        proj_vector = proj_vector./norm(proj_vector);
        proj_waveform(:,i) = squeeze(slctChannels(:,i,:))*...
                    proj_vector;
        proj_waveform(:,i) = amp;
    end
end

Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0;

v_color = Phi*(proj_waveform');

%% Produce frames of wave propagation
% Default_View = [-95.3710 49.2741];
Default_View = [-135 37];
ctext = 'k'; % Color of axes and text

color_range = [min(v_color(:)), max(v_color(:))];
frame_num = size(proj_waveform,1);

row_num = 2;
col_num = ceil(frame_num/row_num);

fig1 = figure('Position',get(0,'ScreenSize').*[20,80,0.98,0.8]);
set(fig1, 'Color', 'w')
fig1.InvertHardcopy = 'off';
% colormap(jet(1000));
colormap(cmap);
t_interval = 1000/Fs; % (ms)
for i = 1:frame_num
    row_i = floor((i-1)/col_num);
    col_i = mod(i-1,col_num);
    subpltPosi = [col_i/col_num, (0.08+(row_num-1-row_i)/row_num),...
        0.9/col_num, 1/row_num];
    subplot('Position',subpltPosi)
%     scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
%         1,v_color(:,i),'Filled')  
%     scatter3(m_obj.v_posi([1,end],1), m_obj.v_posi([1,end],2),...
%         m_obj.v_posi([1,end],3), 10,'m','Filled') 
    caxis(color_range);
    if (row_i == row_num-1) && (col_i == col_num-1)
        xlabel('X (mm)')
        ylabel('Y (mm)')
        zlabel('Z (mm)')
%         scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
%         1,v_color(:,i),'Filled')  
    else
        axis off
    end
    axis equal
    view(Default_View)
    text(150,150,50,sprintf('%.2f ms',(t_ind(i)-t_ind(1))*t_interval),...
        'FontSize',20, 'Color',ctext)
    if (row_i == row_num-1) && (col_i == 1)
        c = colorbar('Color',ctext,'Box','off','Location','south');
        cbarPosi = get(c,'Position');
        c.Label.Position = [80*cbarPosi(1) -20*cbarPosi(2)];
        c.Label.String = sprintf('Acceleration Amplitude (%.1f - %.1f g)',...
            color_range);
    end
    grid off
    set(gca,'FontSize',20,'Color','none','XColor',ctext,'YColor',ctext,...
        'ZColor',ctext)
end
% print('-painters',fig1,sprintf('%s_%dframe',gest_name,frame_num),'-depsc');

%%
fig2 = figure('Position',[200,120,800,800]);
set(fig2, 'Color', 'w')
fig2.InvertHardcopy = 'off';
colormap(cmap);
for i = 1:frame_num
    scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
        1,v_color(:,i),'Filled')    
    caxis(color_range);
    axis off
    axis equal
    view(Default_View)
    set(gca,'FontSize',20,'Color','w','XColor',ctext,'YColor',ctext,...
        'ZColor',ctext)
    print('-r600',fig2,sprintf('%s_%03d',gest_name,i),'-dpng');
end