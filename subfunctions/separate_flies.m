function [pos,N_flies_found] = separate_flies(frame,CC_large,N_flies,fitflies_whole,fitflies_edge,debugflag,weight,area_min)

%This script separate clusters of flies at locations given by the cell
%array "CC_large" in the image "frame" where brighter pixels represent flies. There are known to be "N_flies"
%flies.

%This combines two similar methods. Each one convolves "fitflies" (a cell
%array of a fitfly rotated at different angles) across all the of the
%clusters of flies. The methods differ in that one fitfly contains all
%the edges of flies and convolves that with the outlines of the clusters of
%flies. The other convolves a regular fitfly across the simply
%thresholded image.

%The above two methods are combined and a parameter "weight" is chosen to
%say how much importance each parameter has. At a value of "0" we only use
%edges, "0.5" using an approximately equal weighting between the two
%methods, and "1" represents using only the whole image of the flies.

frame = imcomplement(frame);
cluster_whole = {};
cluster_edge = {};
N_clusters = length(CC_large);
%For each cluster
for i=1:N_clusters
    [y,x] = ind2sub(size(frame),CC_large{i});
    min_x = min(x) - 1; max_x = max(x) + 1;
    min_y = min(y) - 1; max_y = max(y) + 1; %Get the limits of the cluster in the image. increase the frame size to avoid edge effects.
    
    %Get the logical whole cluster locations (using logical values works
    %better than the grayscale fly image)
    mask = zeros(size(frame));
    mask(CC_large{i}) = 1;
    cluster_whole{i} = mask(min_y:max_y,min_x:max_x);
    
    %Now get the location of the edges of the cluster.
    cluster_edge{i} = bwmorph(cluster_whole{i},'remove');
    x_shift(i) = min_x-1; y_shift(i) = min_y-1; %Remember the whole image shift needed
end

C = {}; %Initialize cross correlation array
maxima = zeros(1,N_clusters);
for i=1:N_clusters
    %!!!!!!!!!!NOTE: cluster_whole might change and might not be best
    %!!!!!!!!!!for third input into below functions.
    [C_whole] = cross_correlation(cluster_whole{i},fitflies_whole,cluster_whole{i}); %Convolve with whole flies
    [C_edge] = cross_correlation(cluster_edge{i},fitflies_edge,cluster_whole{i}); %Convolve with just edges
    %C_whole = sqrt(C_whole);
    
    %C_whole = C_whole - min(C_whole(C_whole>0));
    %C_edge = C_edge - min(C_edge(C_edge>0));
    C{i} = weight.*C_whole + (1-weight).*C_edge.*max(C_whole(:))./max(C_edge(:)); %Combine those results with a certain weight
    maxima(i) = max(C{i}(:)); %Keep track of the maxima
end

%%%%%%%%%%%%%Now find flies%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pos = [];
for i=1:N_flies %For each fly we need to find
    %Find the correct cluster with the best fly.
    ind = find(maxima == max(maxima));
    
    if length(ind)
        ind = ind(1);
        
        C_temp = C{ind};
        %The location of the maxima gives the location in the image of the fly
        %and which fitfly to use.
        [m,loc] = max(C_temp(:));
        [y_fly,x_fly,angle] = ind2sub(size(C_temp),loc);
        pos(i,1) = x_fly(1);
        pos(i,2) = y_fly(1);
        %Now remove the fly from the images of the whole flies and edges. The
        %rot(90,...,2) is there because of the way a convolution works.
        
        %figure;subplot(1,2,1);imagesc(fitflies_whole{angle});subplot(1,2,2); imagesc(cluster_whole{ind});hold on; scatter(pos(i,1),pos(i,2),'r*');waitforbuttonpress;
        
        [cluster_whole{ind}] = remove_fly(cluster_whole{ind},rot90(fitflies_whole{angle},2),pos(end,:),100,area_min);
        cluster_edge{ind} = bwmorph(cluster_whole{ind},'remove');
        
        %%%%%%%DEBUGGING
        
        
        %Now update the cross correlations
        [C_whole] = cross_correlation(cluster_whole{ind},fitflies_whole,cluster_whole{ind}); %Convolve with whole flies
        [C_edge] = cross_correlation(cluster_edge{ind},fitflies_edge,cluster_whole{ind}); %Convolve with just edges
        %C_whole = C_whole - min(C_whole(C_whole>0));
        %C_edge = C_edge - min(C_edge(C_edge>0));
        C{ind} = weight.*C_whole + (1-weight).*C_edge.*max(C_whole(:))./max(C_edge(:)); %Combine those results with a certain weight
        maxima(ind) = max(C{ind}(:)); %Keep track of the maxima
        %Shift the fly to real image positions
        pos(end,1) = pos(end,1)+x_shift(ind);
        pos(end,2) = pos(end,2)+y_shift(ind);
    end
end
N_flies_found = size(pos,1);
