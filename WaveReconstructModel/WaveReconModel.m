%% Generate model for wave reconstruction from sensor array
% Author: Yitian Shao (yitianshao@ucsb.edu)
% Created on 09/05/2017
% -------------------------------------------------------------------------
close all
clear all
clc
% -------------------------------------------------------------------------
% Configuration
Skin_Color = [255,223,196]/255;
Skin_Color2 = [255,205,148]/255;
Hand_Truncate_Threshold = 40;
Digit_Diameter = 16; 
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
acc_posi = [119.9  171.8  48.22  % 1 (DP)
            108.2  177.9  46.05  % 2 (DP)  
    
            103.7  203.9  32.93  % 11 (DP)
            90.92  208.9  30.02  % 12 (DP)
            
            81.91  223.9  16.06  % 21 (DP)
            68.2   227.9  14.05  % 22 (DP)
            
            42.12  118.9  38.99  % 28 (MS)
            
            42.89  212.9  -13.52 % 31 (DP)
            28.75  211.9  -16.95 % 32 (DP)
            
            12.09  103.9  6.05   % 44 (MS)
            2.07   146.9  -36.95 % 45 (DP)
            6.49   124.9  -16.95 % 46 (PP)
           ];
acc_num = size(acc_posi,1);
%             68.88  211.9  22.06  % 8
%             90.89  194.8  37.01  % 9
%             107.9  165.9  47.43  % 10
%             33.98  198.7  -4.984 % 11
%             70.33  170.9  33.05  % 12
%             68.8   180.9  23.93  % 13
%             85.47  164.9  35.05  % 14
%             51.05  185.9  21.05  % 15
%             93.88  155.9  36.14  % 16
%             44.89  177.9  0.59   % 17
%             25.79  176.9  -2.95  % 18 
%             49.89  151.9  33.73  % 19
%             66.08  142.9  36.96  % 20
%             82.89  131.9  39.77  % 21
%             30.89  152.9  21.7   % 23
%             45.89  97.88  45.49  % 27
%             27.89  100.9  37.64  % 28
%             63.36  75.88  48.05  % 29
%             13.64  83.88  23.05  % 30

% -------------------------------------------------------------------------
% Wave propagation simulation
% sim_radius = 50;    
% dist_map = zeros(m_obj.v_num,acc_num);
% tic
% for sim_i = 1:acc_num
%     acc_i = findVertex(m_obj, acc_posi(sim_i,:));
%     waveSim(m_obj, acc_i, -hand_plane, sim_radius, 0);
%     dist_map(:,sim_i) = m_obj.v_sim;
%     fprintf('Simulation time = %.2f min\n', (toc/60));
% end
      
%% Plot the hand
if 1 %---------------------------------------------------------------Switch
figure('Position',get(0,'ScreenSize').*[0,0,1,0.95])
% for sim_i = 1:acc_num
for sim_i = 1
    v_color = repmat(Skin_Color2,[m_obj.v_num,1]);
%     v_color(:,1) = dist_map(:,sim_i)/sim_radius;
    scatter3(v_posi_X, v_posi_Y, v_posi_Z,10,v_color,'.')
    hold on
    scatter3(acc_posi(:,1), acc_posi(:,2), acc_posi(:,3),...
        'filled', 'MarkerFaceColor','m', 'MarkerEdgeColor','m')
    scatter3(acc_posi(sim_i,1), acc_posi(sim_i,2), acc_posi(sim_i,3),...
        'filled', 'MarkerFaceColor','r')    
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    axis equal
    view(-hand_plane)
end
end %----------------------------------------------------------------Switch