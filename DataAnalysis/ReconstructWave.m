%% Reconstruct wave on a 3D hand model
close all
% -------------------------------------------------------------------------
addpath('../WaveReconstructModel/');
% -------------------------------------------------------------------------
Data_Path = 'Data';
axis_label = {'X', 'Y', 'Z'};
% -------------------------------------------------------------------------
% gest_name = 'Tap1to5';
% gest_name = 'TapKeyboardRandomly';
% gest_name = '020Hz_sine';
gest_name = '100Hz_sine';
% gest_name = '300Hz_sine';
% gest_name = '500Hz_sine';
%--------------------------------------------------------------------------
% [acc_data, t, Fs ] = readAccIII(fullfile(Data_Path,gest_name,'data.bin'),...
%     fullfile(Data_Path,gest_name,'data_rate.txt'), 0);

if ~exist('dist_map','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','dist_map');
end
if ~exist('m_obj','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','m_obj');
end

%% ------------------------------------------------------------------------
disp_t_start = 1.0;
disp_t_end = 1.2;

disp_acc_i = setdiff(1:46,[10,20,30,40]);
disp_num = length(disp_acc_i);

ref_ind = 31413;
%--------------------------------------------------------------------------
% DC-filtering
acc_data = bsxfun(@minus, acc_data,mean(acc_data,1));
%--------------------------------------------------------------------------
t_ind = (t >= disp_t_start) & (t <= disp_t_end);
if disp_num == 1
    slctChannels = squeeze(acc_data(t_ind,disp_acc_i,:));
    yRange = [min(slctChannels(:)), max(slctChannels(:))];
elseif disp_num > 1
    slctChannels = zeros(sum(t_ind),disp_num,3);
    proj_waveform = zeros(sum(t_ind),disp_num);
    for i = 1:disp_num
        slctChannels(:,i,:) = acc_data(t_ind,disp_acc_i(i),:);
        amp = slctChannels(:,i,1).^2 + slctChannels(:,i,2).^2 +...
              slctChannels(:,i,3).^2;
        [~,max_i] = max(amp);
        proj_vector = squeeze(slctChannels(max_i,i,:));
        proj_vector = proj_vector./norm(proj_vector);
        proj_waveform(:,i) = squeeze(slctChannels(:,i,:))*...
                    proj_vector;
%         proj_waveform(:,i) = amp;
    end
end
% plot(t(t_ind),proj_waveform)

Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0;

v_color = Phi*(proj_waveform');

%% Resolve flicking problem 
% ref_color = v_color(ref_ind,:);
% v_color = bsxfun(@minus, v_color,ref_color);

% figure;hist([min(v_color,[],2),max(v_color,[],2)],100)

threshold = [-0.9 1.1];
thres_max = max(threshold);
m_ind = (v_color > threshold(1)) & (v_color < 0);
p_ind = (v_color >= 0) & (v_color < threshold(2));


%% Produce video of wave propagation
Default_View = [-95.3710 49.2741];

slow_factor = 200; %(Slow-down the video)

color_range = [min(v_color(:)), max(v_color(:))];
frame_num = size(proj_waveform,1);
frame_rate = Fs/slow_factor;

azimuth_angle = [linspace(30, -60, floor(0.5*frame_num)),...
                 linspace(-60, 30, round(0.5*frame_num))];
elevation_angle = [linspace(-20, 0, floor(0.5*frame_num)),...
                   linspace(0, -20, round(0.5*frame_num))];

v_h = VideoWriter(sprintf('%s_slow%dx.avi',gest_name,slow_factor));
v_h.FrameRate = frame_rate;
open(v_h);
curr_fig = figure('Position',get(0,'ScreenSize').*[0,0,0.7,0.95]);
set(curr_fig, 'Color', 'None')
colormap(jet(1000));
t_interval = 1000/Fs; % (ms)
for i = 1:frame_num
    scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
        3,v_color(:,i),'Filled');   
    hold on
    color_range = caxis;
    xticks(-10:20:130)
    xlabel('X (mm)')
    yticks(50:20:250)
    ylabel('Y (mm)')
    zticks(-60:20:60)
    zlabel('Z (mm)')
    axis equal
    view(Default_View+[azimuth_angle(i) elevation_angle(i)])
    text(0,80,-30,sprintf('t = %.1f ms',i*t_interval),'FontSize',20,...
        'Color','w')
    c = colorbar('Color','w','Box','off');
    c.Label.String = 'Acceleration Amplitude (g)';
%     grid off
    set(gca,'FontSize',24,'Color','k','XColor','w','YColor','w',...
        'ZColor','w')
    v_nega = v_color(m_ind(:,i),i);
    scatter3(m_obj.v_posi(m_ind(:,i),1), m_obj.v_posi(m_ind(:,i),2),...
        m_obj.v_posi(m_ind(:,i),3),...
        3,v_color(m_ind(:,i),i).*((v_nega./threshold(1)).^4),'Filled'); 
    v_posi = v_color(p_ind(:,i),i);
    scatter3(m_obj.v_posi(p_ind(:,i),1), m_obj.v_posi(p_ind(:,i),2),...
        m_obj.v_posi(p_ind(:,i),3),...
        3,v_color(p_ind(:,i),i).*((v_posi./threshold(2)).^4),'Filled'); 
    caxis(color_range);
    hold off
    writeVideo(v_h,getframe(curr_fig));
end
close(v_h);