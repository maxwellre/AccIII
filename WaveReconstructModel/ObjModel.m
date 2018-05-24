% Class: 3D model loaded from .obj file
% Constructor inputs:
%   1. 'posi_X' - a vector containing vertex position X
%   2. 'posi_Y' - a vector containing vertex position Y
%   3. 'posi_Z' - a vector containing vertex position Z
classdef ObjModel < handle
% Author: Yitian Shao (yitianshao@ucsb.edu)
% Created on 09/06/2017
properties %---------------------------------------------------------------
    v_posi % Vertex position ([posi_X posi_Y posi_Z])
    v_num % Vertex number
    v_sim % Vertex value based on simulation (Zeros when initialized)
end
properties(GetAccess = private)
    Step_Size = 2; % [private] Step size of propagation 
    
    sim_r % [private] Wave propagation simulation radius (distance limitation)
end
methods %------------------------------------------------------------------
    %% Constructor
    function obj = ObjModel(posi_X, posi_Y, posi_Z)
        if nargin == 3
            if isnumeric(posi_X) && isnumeric(posi_Y) &&...
                    isnumeric(posi_Z)
                obj.v_num = length(posi_X);
                if (length(posi_Y) == obj.v_num) &&...
                        (length(posi_Z) == obj.v_num)
                    disp('Model successfully loaded');
                else
                    error('Failed to load the model: all input vectors (X, Y, Z) must have the same length');
                end
                
                if size(posi_X,2) ~= 1
                    posi_X = posi_X';
                end
                if size(posi_Y,2) ~= 1
                    posi_Y = posi_Y';
                end
                if size(posi_Z,2) ~= 1
                    posi_Z = posi_Z';
                end
                obj.v_posi = [posi_X, posi_Y, posi_Z];
                
                obj.v_sim = []; 
            else
                error('Value must be numeric')
            end
        end
    end
    
    %% Function: Get distance between two vertices
    function [v_ind, v_dist] = getDist(obj, center_i, search_r)
    % Get distance from vertices within certain area to its center vertex
    %----------------------------------------------------------------------
    % [v_ind, v_dist] = getDist(obj, center_i, search_r)
    %
    % Inputs:
    % 1. 'obj' - an instance of the 'ObjModel' class
    % 2. 'center_i' - index of the vertex located at the center of search area
    % 3. 'search_r' - radius of search area
    %
    % Outputs:
    % 1. 'v_ind' - index of vertices within search area
    % 2. 'v_dist' - distance between vertices within search area and the center
    %----------------------------------------------------------------------
    ind = (obj.v_posi(:,1) < (obj.v_posi(center_i,1) + search_r));
    ind = ind & (obj.v_posi(:,1) > (obj.v_posi(center_i,1) - search_r));
    ind = ind & (obj.v_posi(:,2) < (obj.v_posi(center_i,2) + search_r));
    ind = ind & (obj.v_posi(:,2) > (obj.v_posi(center_i,2) - search_r));
    ind = ind & (obj.v_posi(:,3) < (obj.v_posi(center_i,3) + search_r));
    ind = ind & (obj.v_posi(:,3) > (obj.v_posi(center_i,3) - search_r));
    v_dist = ((obj.v_posi(ind,1)-obj.v_posi(center_i,1)).^2 +...
              (obj.v_posi(ind,2)-obj.v_posi(center_i,2)).^2 +...
              (obj.v_posi(ind,3)-obj.v_posi(center_i,3)).^2).^0.5;
    v_ind = find(ind == 1);
    
    % Exclude vertices outside the searching sphere and the center vertex
    ind_in = (v_dist < search_r) & (v_ind ~= center_i);
    v_ind = v_ind(ind_in);
    v_dist = v_dist(ind_in);
    end
    
    %% Function: Propagation vector
    function [v_ind, p_vect, v_dist] = getPropVect(obj, center_i, search_r)
    %----------------------------------------------------------------------
    ind = (obj.v_posi(:,1) < (obj.v_posi(center_i,1) + search_r));
    ind = ind & (obj.v_posi(:,1) > (obj.v_posi(center_i,1) - search_r));
    ind = ind & (obj.v_posi(:,2) < (obj.v_posi(center_i,2) + search_r));
    ind = ind & (obj.v_posi(:,2) > (obj.v_posi(center_i,2) - search_r));
    ind = ind & (obj.v_posi(:,3) < (obj.v_posi(center_i,3) + search_r));
    ind = ind & (obj.v_posi(:,3) > (obj.v_posi(center_i,3) - search_r));
    v_ind = find(ind == 1);
        
    p_vect = bsxfun(@minus,obj.v_posi(v_ind,:),obj.v_posi(center_i,:));
    
    % Exclude the center vertex
    ind_in = (v_ind ~= center_i);
    v_ind = v_ind(ind_in);
    p_vect = p_vect(ind_in,:);
    
    v_dist = (p_vect(:,1).^2 +p_vect(:,2).^2 +p_vect(:,3).^2).^0.5;
    end
    
    %% Function: Find vertex by their position
    function v_ind = findVertex(obj, search_posi)
        search_r = 0.01;
        find_v_num = 0;
        while (~find_v_num)
            ind = (obj.v_posi(:,1) < (search_posi(1) + search_r));
            ind = ind & (obj.v_posi(:,1) > (search_posi(1) - search_r));
            ind = ind & (obj.v_posi(:,2) < (search_posi(2) + search_r));
            ind = ind & (obj.v_posi(:,2) > (search_posi(2) - search_r));
            ind = ind & (obj.v_posi(:,3) < (search_posi(3) + search_r));
            ind = ind & (obj.v_posi(:,3) > (search_posi(3) - search_r));
            v_ind = find(ind > 0);
            find_v_num = length(v_ind);
            if (~find_v_num)
                search_r = search_r +0.001;
            elseif (find_v_num > 1)
                search_r = search_r -0.001;
            end
        end
    end
    
    %% Function: Wave propagation simulation
    function fig_h = waveSim(obj, acc_i, view_direct, sim_limit, is_disp)
    % Compute propagation distance from selected accelerometer to each vertex
    %----------------------------------------------------------------------
    % waveSim(obj, acc_i, view_direct, sim_limit)
    %
    % Inputs:
    % 1. 'obj' - an instance of the 'ObjModel' class
    % 2. 'acc_i' - index of the vextex where the selected accelerometer locates
    % 3. 'view_direct' - a vector indicating the direction of the view
    % 4. 'sim_limit' - wave propagation distance limitation for the simulation
    % Optional inputs:
    % 5. 'is_disp' - Display the simulation process if set to be 1
    %
    % Outputs:
    % 1. 'fig_h' = handle of the figure displaying the simulation process
    %----------------------------------------------------------------------
    Model_Color = [255,223,196]/255; % Default (color of skin)
    % ---------------------------------------------------------------------
    if nargin < 5
        is_disp = 1; % Display the simulation process by default
    end
        
    % Display propagation simulation
    if is_disp
        fig_h = figure('Position',get(0,'ScreenSize').*[0,0,1,1]);
        scatter3(obj.v_posi(:,1), obj.v_posi(:,2), obj.v_posi(:,3),...
            '.', 'MarkerEdgeColor',Model_Color);
        hold on
        scatter3(obj.v_posi(acc_i,1), obj.v_posi(acc_i,2), obj.v_posi(acc_i,3),...
            'filled', 'MarkerFaceColor','r');
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        axis equal
        view(view_direct);
    else
        fig_h = [];
    end
    
    obj.sim_r = sim_limit; % Simulation distance limitation
    
    % Initialize all vertices with largest distance value
    obj.v_sim = ones(obj.v_num,1); 
    obj.v_sim = obj.v_sim .*sim_limit;    
    obj.v_sim(acc_i) = 0; % Distance value for accelerometer vertex is zero

    propagate(obj, acc_i, [0,0,0], is_disp);

    end

    %% Recursive function: Propagate 
    function propagate(obj, center_i, curr_direct, is_disp)
    % Recursive function for propagation simulation 
    %----------------------------------------------------------------------
    % [] = propagate(m_obj, center_i, search_r)
    %
    % Inputs:
    % 1. 'obj' - an instance of the 'ObjModel' class
    % 2. 'center_i' - index of the vertex located at the center of search area
    % 3. 'curr_direct' - current propagation direction
    % 4. 'is_disp' - Display the simulation process if set to be 1
    %
    % Outputs:
    % 1. '' - 
    %----------------------------------------------------------------------
    if (obj.v_sim(center_i) < obj.sim_r) % Current distance within searching range
        [v_ind, p_vect, v_dist]=getPropVect(obj, center_i, obj.Step_Size); 
        
        adj_v_num = length(v_ind); % Number of adjacent vertices
        v_dist = v_dist +obj.v_sim(center_i); % Total distance  
        
        f_direct = 0.5*(curr_direct*curr_direct');
        
        if (adj_v_num > 0) % Exist adjacent vertices
            s_seq = randperm(adj_v_num); % Randomize searching sequence
            for i = s_seq
                if v_dist(i) < obj.v_sim(v_ind(i)) % Discovered a shorter path
                    obj.v_sim(v_ind(i)) = v_dist(i);

                    % Update the change on display (Slow down significantly!)
                    if is_disp
                        scatter3(obj.v_posi(v_ind(i),1),...
                            obj.v_posi(v_ind(i),2),obj.v_posi(v_ind(i),3),...
                            '.', 'MarkerEdgeColor',...
                            ones(1,3)*v_dist(i)/obj.sim_r);
                        drawnow;   
                    end
                    
                    p_direct = curr_direct*p_vect(i,:)'; % Propagation direction 
                    if (p_direct >= f_direct) % Forward propagation only
                        propagate(obj, v_ind(i), p_vect(i,:), is_disp); % Propagate to an adjacent vertex
                    end
                end
            end
        end
    end
    end
end
end