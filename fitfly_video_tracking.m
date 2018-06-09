%fitfly_video_tracking
%This runs fitfly analysis on an movie file. Modified 6_1_2018

%MODIFICATIONS NEEDED: 
%1) Ability to watch tracking as it goes.

%GET USER INPUT FOR MOVIE FILENAME
[mv_filename,pathname] = uigetfile('*.avi','Select movie file');
mv_pathfilename = strcat(pathname,mv_filename);
mv = VideoReader(mv_pathfilename);

%GET PARAMS FILE THAT SHOULD CONTAIN THE ROI AND BWMASK
[filename,pathname] = uigetfile('*.mat','Select params file');
params_filename = strcat(pathname,filename);
params = load(params_filename,'params');%Params file is to get the ROI
params = params.params;
names = fieldnames(params);
for i=1:size(names,1)
    eval(strcat(names{i},'=params.',names{i},';')); %Bad coding, but it gets all the variables out of params
end

p=0;
iter = 0;
ResMat = [];

%t_s = [0:mv.Duration/600:mv.Duration];
%t_s = t_s(1:end-1);

while hasFrame(mv)
    iter = iter+1;
    t = mv.CurrentTime
    %mv.CurrentTime = t_s(iter);
    frame = rgb2gray(readFrame(mv));
    [bw, CC, CC_large] = get_thresholded_flies(frame,t_thresh,bwMask,SE, area_min, area_max, fsize,background);
    CC = CC.PixelIdxList;
    CC_large = CC_large.PixelIdxList;
    flag = 0;
    ResMat_temp = []; %For PERI flies
    if ~isempty(CC_large)
        flag = 2;
        N_missing = N_tot - length(CC);
        [pos,N_flies_found] = separate_flies(frame,CC_large,N_missing,fitflies_whole,fitflies_edge,0,weight,area_min);
        if N_flies_found>0
            ResMat_temp = [t*ones(N_flies_found,1), pos(:,1), pos(:,2), flag*ones(N_flies_found,1), i*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),NaN*ones(N_flies_found,1)];
        end
    end
    N_still_missing = N_tot - length(CC)-size(ResMat_temp,1);
    ResMat_temp3 = [];
    if N_still_missing>0 %This is important for mixed gender experiments where two males for example could be confused for a female
        areas = zeros(length(CC),1);
        for j=1:length(CC)
            areas(j) = length(CC{j});
        end
        [ar, order] = sort(areas);
        CC_large = {};
        for k=1:N_still_missing
            CC_large{k} = CC{order(end-k+1)};
        end
        %CC_large = CC{order(end-N_still_missing+1:end)};
        flag = 2;
        [pos,N_flies_found] = separate_flies(frame,CC_large,N_still_missing,fitflies_whole,fitflies_edge,0,weight,area_min);
        if N_flies_found>0
            ResMat_temp3 = [t*ones(N_flies_found,1), pos(:,1), pos(:,2), flag*ones(N_flies_found,1), i*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),0*ones(N_flies_found,1),NaN*ones(N_flies_found,1)];
        end
    end
    
    ResMat_temp2 = zeros(length(CC),5);
    ResMat_temp2(:,1) = t;
    ResMat_temp2(1,4) = flag;
    ResMat_temp2(:,5) = iter;
    for j=1:length(CC)
        [y,x] = ind2sub(size(frame),CC{j});
        ResMat_temp2(j,2) = mean(x);
        ResMat_temp2(j,3) = mean(y);
        ResMat_temp2(j,9) = length(CC{j});
    end
    ResMat = [ResMat; ResMat_temp; ResMat_temp2; ResMat_temp3];
    if ~mod(iter,3)
       save('temp','ResMat') 
       sum(ResMat(:,1)==t)
       figure;imagesc(frame);hold on;colormap('gray');scatter(ResMat(ResMat(:,1)==t,2),ResMat(ResMat(:,1)==t,3),'r*');drawnow
    end
end

date_analyzed = datetime;
save(strcat('results',mv_filename,'.mat'),'ResMat','params','fitflies_whole','fitflies_edge','date_analyzed');