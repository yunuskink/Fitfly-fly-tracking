function [fitflies_edge,fitflies_whole] = get_fitflies(test_frames,ang_res,params)

names = fieldnames(params);
for i=1:size(names,1)
    eval(strcat(names{i},'=params.',names{i},';')); %Bad coding, but it gets all the variables out of params
end

CC_total = []; frame_ids = [];
for i=1:length(test_frames)
    im = test_frames{i};
    
    im(bwMask==0) = background;
    im = imcomplement(im);
    bw = adaptivethresh(im,fsize,t_thresh);
    bw(bwMask==0) = 0;
    CC = bwconncomp(bw);
    
    areas  = regionprops(CC,'Area');
    areas = cat(1, areas.Area);
    CC.PixelIdxList([find(areas<area_min);find(areas>area_max)]) = [];
    
    CC = CC.PixelIdxList;
    CC_total = [CC_total,CC];
    frame_ids = [frame_ids, ones(1,length(CC))*i];
end

CC = CC_total;
[optimizer, metric] = imregconfig('monomodal');

fly = {};

frame = test_frames{1};
%max_dim = 0;
[y,x] = ind2sub(size(frame),CC{1});
mask = zeros(size(frame)); mask(CC{1}) = 1;
fitfly_whole = double(frame);
fitfly_whole(~mask) = 0;
%fitfly_whole(setdiff(CC{1},[1:(size(fitfly_whole,1)*size(fitfly_whole,2))])) = 0;
fitfly_whole = fitfly_whole(min(y)-10:max(y)+10,min(x)-10:max(x)+10);
fitfly_edge = double(bwmorph(fitfly_whole,'remove'));

for i=1:length(CC)
    [y,x] = ind2sub(size(test_frames{frame_ids(i)}),CC{i});
    fly{i} = imcomplement(test_frames{frame_ids(i)});
    mask = zeros(size(test_frames{frame_ids(i)})); mask(CC{i}) = 1;
    fly{i}(~mask) = 0;
    %fly{i}(setdiff(CC{1},[1:(size(fly{i},1)*size(fly{i},2))])) = 0;
    fly{i} = fly{i}(min(y)-10:max(y)+10,min(x)-10:max(x)+10);
    fly{i} = imregister(fly{i},round(fitfly_whole/i),'rigid',optimizer,metric);
    fitfly_whole = fitfly_whole + double(fly{i});
    fitfly_edge = fitfly_edge + bwmorph(fly{i},'remove');
    i/length(CC)
end

fitfly_edge = round(255*fitfly_edge./max(fitfly_edge(:)));
fitfly_whole = round(255*fitfly_whole./max(fitfly_whole(:)));
fitfly_edge(fitfly_edge<15)=0; fitfly_whole(fitfly_whole<15)=0;

fitflies_edge = {};
fitflies_whole = {};
for i=1:ang_res
    fitflies_edge{i} = double(imrotate(fitfly_edge,360*i/ang_res,'nearest','loose'));
    fitflies_whole{i} = double(imrotate(fitfly_whole,360*i/ang_res,'nearest','loose'));
end