function [pointPosi]=centerPoint( pointMap, pointNum, PRadSqr)
% Created on 10/27/2016
% Previously a local function inside "gMapConfig.m".
% Locate position of the center of points indicated in black dots
% Updated on 10/28/2016 - reduce the point radius from 1024 to 768
% Updated on 06/19/2017 - allowing user-defined point radius
%------------------------------------------------------------------
[rowP,colP]=find(pointMap<255);

% Pinpoint center - point with radius of 16px in a 4096-by-4096px map
if nargin < 3
    PRadSqr = 768; % Square of radius (radius^2) of point area (Old: 1024)
end

pointPosi=zeros(pointNum,2); % Point position
classP=zeros(1,length(rowP)); % Point class
for c=1:pointNum
    availP=find(classP==0); % Available Points without signed class
    pointPosi(c,:)=[rowP(availP(1)),colP(availP(1))]; % Pick a center
    for i=availP
        if (rowP(i)-pointPosi(c,1))^2+(colP(i)-pointPosi(c,2))^2<PRadSqr
            classP(i)=c;
        end
    end
    pointPosi(c,1)=mean(rowP(classP==c));
    pointPosi(c,2)=mean(colP(classP==c));
end
end