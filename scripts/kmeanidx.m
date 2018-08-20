function [ imidx] = kmeanidx( im,k )
%===============================================================
% Thesis:
% -------
% kmeanidx.m
%
% Description:
% -----------
% The function performes k-means clustering on a given image.
% the features that are used are pixel location (x-y coordinates) and
% colors. the usage of the locations is for giving weight also to
% proximity, hence close pixel tend to express same distributions.
% To avoid bias, each feature is normalized to same scale (0-1).
%
% to assure consistency, k-means is run 10 times and the output which
% yielded minimum square error is taken.
%
% Input: im - image to cluster. can be color or greyscale.
%        k - number of clusters to divide the image
%
% Output : imidx - image contains labels for each pixel (which cluster it
%                  belongs to).
%
%
% Date: 21.1.18
% Author: Yaniv Tocker
% 
% Revision History:
% 1-
% 2-
%===============================================================

if length(size(im))> 2 %color image
    [row,col,color]=size(im);
else
    [row,col]=size(im);
end

% create feature matrix

% x-y locations for each pixel - to classify also by proximity 
% 2 images are created showing the row of each pixel and column. both are
% normalized!
rowim=repmat((1:row)'/row,1,col);
colim=repmat((1:col)/col,row,1);
%-------

% color features - normalized
if exist('color')==1 
    normimR=im(:,:,1)./(max(max(im(:,:,1))));
    normimG=im(:,:,2)./(max(max(im(:,:,2))));
    normimB=im(:,:,3)./(max(max(im(:,:,3))));
    featuremat=[ normimR(:) normimG(:) normimB(:) rowim(:) colim(:)];
    
else %grayscale
    normim=im./(max(max(im)));
    featuremat=[ normim(:) rowim(:) colim(:)];
end
%-------

%% K-means clustering

idx=kmeans(featuremat,k,'Replicates',10);
imidx=reshape(idx,[row,col]);

end

