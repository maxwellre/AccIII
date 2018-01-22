%% Phantom skin display
% Created on 01/21/2018
%--------------------------------------------------------------------------
close all

%--------------------------------------------------------------------------
% Important Parameters
Alpha = 200; % The influence parameter of each accelerometer position
Range = 1000; % The influence range of each accelerometer position

AccNum = 42; % Accelerometer number
acc_ind = setdiff(1:46,[10,20,30,40]);
%--------------------------------------------------------------------------
if ~exist('acc_data','var')
    error('AccIII data required!');
end

%--------------------------------------------------------------------------
% Compute the accelerometer locations based on dot maps--------------------
acc_loc_image=imread('AccIII_PhantomSkin_Location.jpg'); 
[imgLen,imgLen2,~] = size(acc_loc_image);
if (imgLen == imgLen2)
    clear imgLen2;
else
    error('Must be square image!');
end
acc_loc_image=rgb2gray(acc_loc_image); % Gray section edge point map
% Low pass filter the chosen grid and computable area
lpF=ones(3)/9; % 3-by-3 mean filter
LPFilter=uint8(filter2(lpF,acc_loc_image));
acc_loc_image(2:end-1,2:end-1)=LPFilter(2:end-1,2:end-1);
acc_Posi=centerPoint(acc_loc_image, AccNum, 16000);
acc_Posi = round(acc_Posi); % Round the position to get index
%--------------------------------------------------------------------------
acc_order = [10, 7, 16, 15, 25, 20, 36, 30, 41,...
4, 3, 13, 11, 24, 19, 35, 29, 38,...
1, 2, 8, 9, 23, 17, 34, 27, 40,...
5, 6, 12, 14, 22, 18, 33, 28, 39,...
31, 37, 42, 32, 21, 26];
acc_Posi = acc_Posi(acc_order,:);

%--------------------------------------------------------------------------
if 0
figure('Position',[60,50,860,800]); 
imshow(acc_loc_image); 
hold on; 
scatter(acc_Posi(:,2),acc_Posi(:,1),'y','filled'); 
for i = 1:AccNum
    text(acc_Posi(i,2)+40,acc_Posi(i,1)+5,sprintf('%d',acc_ind(i)),...
        'Color','r')
end
hold off
axis equal;
box off;
end

%--------------------------------------------------------------------------
% Compute distance between an accelerometer and a pixel in the map
[imgCol, imgRow] = meshgrid(1:imgLen, 1:imgLen);
accDistMap = zeros(imgLen, imgLen, AccNum);
for i = 1:AccNum
    accDistMap(:,:,i) = ((imgRow - acc_Posi(i,1)).^2 +...
        (imgCol - acc_Posi(i,2)).^2).^0.5;
end

%--------------------------------------------------------------------------
% Compute time-averaged energy
accAvgEn = zeros(AccNum,1);
for i = 1:AccNum
    temp = rssq(acc_data{acc_ind(i),1},2);
    accAvgEn(i) = temp(2737);
end

%% ------------------------------------------------------------------------
% Render the energy map
Phi = 100./(accDistMap+Alpha);
Phi = bsxfun(@rdivide, Phi, sum(Phi,3));

enMap = zeros(imgLen);
for i = 1:AccNum
    enMap = enMap + Phi(:,:,i)*accAvgEn(i);
end

figure('Position',[60,50,860,800]); 
imagesc(enMap);
axis equal;
box off;