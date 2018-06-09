function [bw, CC, CC_large] = get_thresholded_flies(im,t_thresh,bwMask,SE, area_min, area_max, fsize,background)
%This takes in an image and outputs the bw thresholded image along with
%it's connected components.  If area_min and area_max are passed in, it
%gets rid of any cc's that are not in that range.

%Threshold the flies into a binary image. 
im(bwMask==0) = background; 
im = imcomplement(im);
bw = adaptivethresh(im,fsize,t_thresh);
bw(bwMask==0) = 0;

CC = bwconncomp(bw);
CC_large = CC;
areas  = regionprops(CC,'Area');
areas = cat(1, areas.Area);
small = find(areas<area_min);
for i=1:length(small)
    bw(cell2mat(CC.PixelIdxList(small(i))))=0;
end
CC.PixelIdxList([find(areas<area_min);find(areas>area_max)]) = [];
CC_large.PixelIdxList([find(areas<area_max)]) = [];
