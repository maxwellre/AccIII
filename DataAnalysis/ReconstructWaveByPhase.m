%% Reconstruct wave by phase variation
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
gest_name = '100Hz_sine';
% gest_name = '200Hz_sine';
% gest_name = '500Hz_sine';
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
disp_t_start = 1.0;
disp_t_end = 1.2015;

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
    proj_vect = [];
    slctChannels = zeros(sum(t_ind),disp_num,3);
    proj_waveform = zeros(sum(t_ind),disp_num);
    for i = 1:disp_num
        slctChannels(:,i,:) = acc_data(t_ind,disp_acc_i(i),:);
        amp = slctChannels(:,i,1).^2 + slctChannels(:,i,2).^2 +...
              slctChannels(:,i,3).^2;
        [~,max_i] = max(amp);
        proj_vector = squeeze(slctChannels(max_i,i,:));
        proj_vector = proj_vector./norm(proj_vector);
        proj_vect = [proj_vect, proj_vector];
        proj_waveform(:,i) = squeeze(slctChannels(:,i,:))*...
                    proj_vector;
%         proj_waveform(:,i) = amp;
    end
end
% plot(t(t_ind),proj_waveform)
helical = hilbert(proj_waveform);
% wavephase = unwrap(angle(helical));
wavephase = angle(helical);

Phi = 17./(dist_map+25.5) - 0.087;
Phi(Phi < 0) = 0;
Phi = bsxfun(@rdivide, Phi, sum(Phi,2));
Phi(isnan(Phi)) = 0;

v_color = Phi*(wavephase');

%% Upsampling (bandlimited)
tic
upfac = 10;
alpha = 0.2;
h1 = intfilt(upfac,2,alpha);
temp = upsample(v_color',upfac);
temp = filter(h1,1,temp);
delay = mean(grpdelay(h1));
temp(1:delay,:) = [];
fprintf('Bandlimited upsampling time = %.2f sec\n',toc)
% stem(1:upfac:upfac*size(v_color,2),v_color')
% hold on
% plot(temp,'.-')
v_color = temp';
%% Resolve flicking problem 
% ref_color = v_color(ref_ind,:);
% v_color = bsxfun(@minus, v_color,ref_color);

% figure;hist([min(v_color,[],2),max(v_color,[],2)],100)

% threshold = [-0.9 1.1];
% thres_max = max(threshold);
% m_ind = (v_color > threshold(1)) & (v_color < 0);
% p_ind = (v_color >= 0) & (v_color < threshold(2));

if ~exist('digitII_dist_map','var')
    load('SimRadius128mm_digitII_tip.mat','digitII_dist_map');
end

dim_ratio = 0.5;
fade_boundary = 100;

v_rms = rms(v_color,2);
threhold = 0.7;
% fade_ind = (v_rms < threhold);
fade_ind = (digitII_dist_map > fade_boundary);
orig_ind = ~fade_ind;
out_ind = (digitII_dist_map == 128);

% max(digitII_dist_map(orig_ind))

temp = digitII_dist_map(fade_ind);
temp = temp - min(temp);
digitII_dist = temp./max(temp);
fade_ratio = 1-exp(-2*digitII_dist);

v_fadeColor = dim_ratio*ones(sum(fade_ind),3);

%% Produce video of wave propagation
Default_View = [-95.3710 49.2741];

slow_factor = 200; % (Slow-down the video)

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
    scatter3(m_obj.v_posi(orig_ind,1), m_obj.v_posi(orig_ind,2),...
        m_obj.v_posi(orig_ind,3), 3,v_color(orig_ind,i),'Filled');   
    hold on
    currCR = caxis;
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
    cMaxLen = color_range(2) - color_range(1);
    cOffset = (currCR(1) - color_range(1))/cMaxLen; 
    cLen = (currCR(2) - currCR(1))/cMaxLen; 
    cPosi = [0.9 0.05+(0.9*cOffset) 0.02 0.9*cLen];
    c = colorbar('Color','w','Box','off','Position',cPosi);
%     c = colorbar('Color','w','Box','off');
    c.Ticks = color_ticks;
    c.TickLength = 0.02;
    c.Label.String = 'Phase Angle (Radians)';
    c.Label.Position = [3 0 0];
%     grid off
    set(gca,'FontSize',24,'Color','k','XColor','w','YColor','w',...
        'ZColor','w');
    % Fading --------------------------------------------------------------
%     cMap_ind = fix(cMapLen*(v_color(fade_ind,i) - currCR(1))/...
%         (currCR(2)-currCR(1)))+1;
%     curr_color = squeeze(ind2rgb(cMap_ind,cMap));
%     fade_ratio = (v_color(fade_ind,i)/max(abs(v_color(fade_ind,i)))).^2;

    cMap_ind = fix(cMapLen*(v_color(fade_ind,i) - currCR(1))/...
            (currCR(2)-currCR(1)))+1;
    curr_color = squeeze(ind2rgb(cMap_ind,cMap));
       
    v_fade = fade_ratio.*v_fadeColor + (1-fade_ratio).*curr_color;
    
    scatter3(m_obj.v_posi(fade_ind,1), m_obj.v_posi(fade_ind,2),...
        m_obj.v_posi(fade_ind,3), 3,v_fade,'Filled');  
    
    scatter3(m_obj.v_posi(out_ind,1), m_obj.v_posi(out_ind,2),...
        m_obj.v_posi(out_ind,3), 3,v_fadeColor(1,:),'Filled');  
    
    caxis(currCR);
    % ---------------------------------------------------------------------
    hold off
    writeVideo(v_h,getframe(curr_fig));
end
close(v_h);