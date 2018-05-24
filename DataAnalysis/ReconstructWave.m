%% Reconstruct wave on a 3D hand model
close all
% -------------------------------------------------------------------------
addpath('../WaveReconstructModel/');
% -------------------------------------------------------------------------
Data_Path = 'Data';
axis_label = {'X', 'Y', 'Z'};

gest_name = 'Tap1to5';
%--------------------------------------------------------------------------
[acc_data, t, Fs ] = readAccIII(fullfile(Data_Path,gest_name,'data.bin'),...
    fullfile(Data_Path,gest_name,'data_rate.txt'), 0);

if ~exist('dist_map','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','dist_map');
end
if ~exist('m_obj','var')
    load('SimRadius64mm_StepSize2mm_120Degree_42Acc.mat','m_obj');
end

%--------------------------------------------------------------------------
disp_t_start = 0.5;
disp_t_end = 3.0;

disp_acc_i = setdiff(1:46,[10,20,30,40]);
disp_num = length(disp_acc_i);

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
    end
end


Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0;

v_color = Phi*(proj_waveform');

%%
slow_factor = 50; %(Slow-down the video)

color_range = [min(v_color(:)), max(v_color(:))];
frame_num = size(proj_waveform,1);
frame_rate = Fs/slow_factor;

v_h = VideoWriter(sprintf('%s.avi',gest_name));
v_h.FrameRate = frame_rate;
open(v_h);
curr_fig = figure('Position',get(0,'ScreenSize').*[0,0,0.7,0.95]);
colormap(jet(1000));
t_interval = 1000/Fs; % (ms)
for i = 1:frame_num
    scatter3(m_obj.v_posi(:,1), m_obj.v_posi(:,2), m_obj.v_posi(:,3),...
        100,v_color(:,i),'Filled')    
    caxis(color_range);
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
    view([-0.0234, 0.0022, 0.0273])
    text(10,30,sprintf('t = %.1f ms',i*t_interval))
    writeVideo(v_h,getframe(curr_fig));
end
close(v_h);