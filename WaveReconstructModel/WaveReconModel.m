%% Generate model for wave reconstruction from sensor array
% Author: Yitian Shao (yitianshao@ucsb.edu)
% Created on 09/05/2017
% -------------------------------------------------------------------------
close all
% clear all
% clc
% -------------------------------------------------------------------------
% Configuration
Skin_Color = [255,223,196]/255;
Hand_Truncate_Threshold = 40;
Digit_Diameter = 16; 
Acc_Ind = setdiff(1:46,[10,20,30,40]);
% -------------------------------------------------------------------------
% Loading vertices of a 3D model from a .obj file
file_id = fopen('arm.obj');
scan_data = textscan(file_id,'%s');
fclose(file_id);
scan_data = scan_data{1};

v_ind = find(strcmp(scan_data,'v')==1);

v_posi_X = -str2double(scan_data(v_ind+1));
v_posi_Y = str2double(scan_data(v_ind+2));
v_posi_Z = -str2double(scan_data(v_ind+3));

% Truncate the hand model------------------------
trunc_ind = (v_posi_Y > Hand_Truncate_Threshold);
v_posi_X = v_posi_X(trunc_ind);
v_posi_Y = v_posi_Y(trunc_ind);
v_posi_Z = v_posi_Z(trunc_ind);
% -----------------------------------------------

% Create a instance of the 'ObjModel' class
m_obj = ObjModel(v_posi_X, v_posi_Y, v_posi_Z);
% -------------------------------------------------------------------------
% Location information identification

plane_v_posi = zeros(3,3); % Vertices position of the plane
% Center of digit I:
[~, digitI_bottom_ind] = min(v_posi_Z);
v_ind1 = getDist(m_obj, digitI_bottom_ind, Digit_Diameter);
plane_v_posi(1,1) = mean(v_posi_X(v_ind1));
plane_v_posi(1,2) = mean(v_posi_Y(v_ind1));
plane_v_posi(1,3) = mean(v_posi_Z(v_ind1));

% Center of digit III:
[~, digitI_tip_ind] = max(v_posi_Y);
v_ind2 = getDist(m_obj, digitI_tip_ind, Digit_Diameter);
plane_v_posi(2,1) = mean(v_posi_X(v_ind2));
plane_v_posi(2,2) = mean(v_posi_Y(v_ind2));
plane_v_posi(2,3) = mean(v_posi_Z(v_ind2));

% Center of digit V:
[~, digitV_top_ind] = max(v_posi_Z);
v_ind3 = getDist(m_obj, digitV_top_ind, Digit_Diameter);
plane_v_posi(3,1) = mean(v_posi_X(v_ind3));
plane_v_posi(3,2) = mean(v_posi_Y(v_ind3));
plane_v_posi(3,3) = mean(v_posi_Z(v_ind3));

% Plane dividing palmar and dorsal hand (Defined by a*x+b*y+c*z=1)
hand_plane = plane_v_posi\ones(3,1);
% palm_ind = ((m_obj.v_posi * hand_plane) > 1);
dorsum_ind = ((m_obj.v_posi * hand_plane) < 1);

% -------------------------------------------------------------------------
acc_posi = [% Digit V --------------------
            119.9  171.8  48.22  % 01 (DP)
            108.2  177.9  46.05  % 02 (DP)  
            115.9  163.9  44.64  % 03 (MP)
            104.5  169.9  43.05  % 04 (MP) 
            91.09  129.9  37.18  % 05 (MH)
            99.87  152.9  43.08  % 06 (PP)
            71.89  96.88  44.61  % 07 (MB)
            74.89  116.1  42.11  % 08 (MS)
            60.89  81.88  48.5   % 09 (C) 
            % Digit VI -------------------
            103.7  203.9  32.93  % 11 (DP)
            90.92  208.9  30.02  % 12 (DP)
            95.9   189.8  35.06  % 13 (MP)
            82.93  194.8  31.05  % 14 (MP)
            76.89  138.9  34.69  % 15 (MH)
            75.89  167.9  39.19  % 16 (PP)
            59.89  101.9  45.34  % 17 (MB)
            60.94  123.9  40.06  % 18 (MS)
            46.89  86.88  47.89  % 19 (C) 
            % Digit III ------------------
            81.91  223.9  16.06  % 21 (DP)
            67.89  228.4  13.05  % 22 (DP)
            76.54  206.9  19.05  % 23 (MP)
            60.64  211.9  15.05  % 24 (MP)
            58.89  148.9  32.42  % 25 (MH)
            55.93  178.8  29.05  % 26 (PP)
            45.89  106.9  43.35  % 27 (MB)
            43.89  130.9  36.48  % 28 (MS)
            34.89  89.88  44.32  % 29 (C)             
            % Digit II -------------------
            42.89  212.9  -13.52 % 31 (DP)
            28.75  211.9  -16.95 % 32 (DP)
            43.89  195.9  -7.366 % 33 (MP)
            27.72  194.9  -10.95 % 34 (MP)
            39.85  154.9  24.11  % 35 (MH)
            33.05  175.8  8.014  % 36 (PP)
            31.96  110.7  36.03  % 37 (MB)
            29.71  134.9  27.16  % 38 (MS)
            24.73  90.88  38.2   % 39 (C) 
            % Digit I --------------------
            17.61  129.9  6.054  % 41 (betw MS)
            18.41  110.9  20.05  % 42 (betw MS MB)
            15.66  90.88  23.05  % 43 (C) 
            12.09  103.9  6.05   % 44 (MS)
            2.07   146.9  -36.95 % 45 (DP)
            6.49   124.9  -16.95 % 46 (PP)
           ];
acc_num = size(acc_posi,1);

% -------------------------------------------------------------------------
% Wave propagation simulation
sim_radius = 64; % (Default: 50)    
dist_map = zeros(m_obj.v_num,acc_num);
tic
parfor sim_i = 1:acc_num
    acc_i = findVertex(m_obj, acc_posi(sim_i,:));
    waveSim(m_obj, acc_i, -hand_plane, sim_radius, 0);
    dist_map(:,sim_i) = m_obj.v_sim;
    fprintf('Simulation time = %.2f min\n', (toc/60));
end
save('WaveReconModel.mat','dist_map','m_obj');
disp('Simulated propagation model saved!')
      
%% Plot the hand
if 0 %---------------------------------------------------------------Switch
disp_acc_num = 1;
figure('Position',get(0,'ScreenSize').*[0,0,1,0.95])
% hold on
for sim_i = 1:acc_num
% for sim_i = 1
    v_color = repmat(Skin_Color,[m_obj.v_num,1]);
%     v_color(:,1) = dist_map(:,sim_i)/sim_radius;
    scatter3(v_posi_X, v_posi_Y, v_posi_Z,20,v_color,'.') 
    hold on
    scatter3(acc_posi(:,1), acc_posi(:,2), acc_posi(:,3),...
        'filled', 'MarkerFaceColor','m', 'MarkerEdgeColor','m')
    scatter3(acc_posi(sim_i,1), acc_posi(sim_i,2), acc_posi(sim_i,3),...
        'filled', 'MarkerFaceColor','r')   
    if disp_acc_num
        text(acc_posi(sim_i,1), acc_posi(sim_i,2), acc_posi(sim_i,3)+5,...
            num2str(Acc_Ind(sim_i)),'FontSize',20)
    end
    hold off
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
    view(-hand_plane)
    drawnow
end
end %----------------------------------------------------------------Switch