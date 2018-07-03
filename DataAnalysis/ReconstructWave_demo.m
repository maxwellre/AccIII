%% Reconstruct wave on a 3D hand model - No upsampling - normalized colorbar
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
% gest_name = '050Hz_sine';
% gest_name = '100Hz_sine';
% gest_name = '200Hz_sine';
% gest_name = '500Hz_sine';
% gest_name = 'PricisionGripCylinder';
% gest_name = 'PowerGripCylinder';
% gest_name = 'WritingRETouch';
gest_name = 'GrabHandleAndRelease';
%--------------------------------------------------------------------------
if 1
[acc_data, t, Fs ] = readAccIII(fullfile(Data_Path,gest_name,'data.bin'),...
    fullfile(Data_Path,gest_name,'data_rate.txt'), 0);
end

if ~exist('dist_map','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','dist_map');
end
if ~exist('m_obj','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','m_obj');
end

%% ------------------------------------------------------------------------
% disp_t_start = 0;
% disp_t_end = 5;
% disp_t_start = 1.4; % TapII
% disp_t_end = 1.6; % TapII
% disp_t_start = 0.36; % WritingRETouch
% disp_t_end = 0.52; % WritingRETouch
disp_t_start = 0.55;
disp_t_end = 0.6;

disp_acc_i = setdiff(1:46,[10,20,30,40]);
disp_num = length(disp_acc_i);

ref_ind = 31413;
%--------------------------------------------------------------------------
% DC-filtering
acc_data = bsxfun(@minus, acc_data,mean(acc_data,1));
%--------------------------------------------------------------------------
t_ind = (t >= disp_t_start) & (t <= disp_t_end);

% t_ind = zeros(size(t_ind));
% t_ind([1401:1450,1901:1950,2401:2450,2891:2940,3401:3450]) = 1;
% t_ind = logical(t_ind);
t_ind_num = sum(t_ind);

if disp_num == 1
    slctChannels = squeeze(acc_data(t_ind,disp_acc_i,:));
    yRange = [min(slctChannels(:)), max(slctChannels(:))];
elseif disp_num > 1
    proj_vect = [];
    slctChannels = zeros(t_ind_num,disp_num,3);
    proj_waveform = zeros(t_ind_num,disp_num);
    for i = 1:disp_num
        slctChannels(:,i,:) = acc_data(t_ind,disp_acc_i(i),:);
        amp = slctChannels(:,i,1).^2 + slctChannels(:,i,2).^2 +...
              slctChannels(:,i,3).^2;
          
%         [~,max_i] = max(amp);
%         proj_vector = squeeze(slctChannels(max_i,i,:));
%         proj_vector = proj_vector./norm(proj_vector);
%         proj_vect = [proj_vect, proj_vector];
%         proj_waveform(:,i) = squeeze(slctChannels(:,i,:))*...
%                     proj_vector;

        proj_waveform(:,i) = amp;
    end
end
% plot(t(t_ind),proj_waveform)

Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0;

v_color = Phi*(proj_waveform');

%% Plot projected waveform
% figure('Position', get(0,'ScreenSize').*[10 50 0.5 0.88],...
%             'Name','Projected Waveform')
% for k = 1:disp_num
%     subplot(14,3,k)
%     plot(t(t_ind), proj_waveform(:,k));
%     ylabel(sprintf('%d',disp_acc_i(k)));
%     xlim([disp_t_start disp_t_end])
%     ylim([-16 16])
%     box off
%     if k<42
%         xticks([])
%     end
% end
% xlabel('Time (Secs)')

%% Produce video of wave propagation
Default_View = [-95.3710 49.2741];

slow_factor = 100; % (Slow-down the video)

color_range = [min(v_color(:)), max(v_color(:))];
color_ticks = round(color_range(1),1):0.2:round(color_range(2),1);
frame_num = size(v_color,2);
if exist('upfac','var')
    frame_rate = Fs*upfac/slow_factor;
    t_interval = 1000/(Fs*upfac);
else
    frame_rate = Fs/slow_factor;
    t_interval = 1000/Fs; % (ms)
end

azimuth_angle = [linspace(30, -60, floor(0.5*frame_num)),...
                 linspace(-60, 30, round(0.5*frame_num))];
elevation_angle = [linspace(-20, 0, floor(0.5*frame_num)),...
                   linspace(0, -20, round(0.5*frame_num))];

v_h = VideoWriter(sprintf('%s_slow%dx_%.ffps.avi',gest_name,slow_factor,...
    frame_rate));
v_h.FrameRate = frame_rate;
open(v_h);
curr_fig = figure('Position',get(0,'ScreenSize').*[0,0,0.8,0.95]);
set(curr_fig, 'Color', 'None')

cMapLen = 1000;
cMap = colormap(jet(cMapLen));
for i = 1:frame_num
    scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2),...
        m_obj.v_posi(:,3), 3,v_color(:,i),'Filled');  
    
    c = colorbar('Color','w','Box','off');
    caxis(color_range)

    hold on
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
    set(gca,'FontSize',24,'Color','k','XColor','w','YColor','w',...
        'ZColor','w');
    % ---------------------------------------------------------------------
    hold off
    writeVideo(v_h,getframe(curr_fig));
end
close(v_h);