function [ RefPix, pixAreaIdxs ] = GetRefPix( LblIm,options )
%===============================================================
% Thesis:
% -------
% GetRefPix.m
%
% Description:
% -----------
% Get reference pixels indices (for image in vector fashion) from uniform
% disribution for each cluster. from each cluster [options.numRefPxls]
% are taken
%
% 
%
% Input: LblIm - Image with clustering label at each pixel
%        options - user set parameters (or default). only use [options.numRefPxls]
%
%
% Output : RefPix - matrix with REfrence pixels. each column is a differene
%                   cluster and number of point is same as
%                   [options.numRefPxls]
%
%          pixAreaIdxs - a cell array in which each cell has a list of
%                        pixel indices that belong to each cluster.
%
%
% Date: 31.1.18
% Author: Yaniv Tocker
% 
% Revision History:
% 1- 1.2.18 - added option to choose no. estimators (=control sets) in each
%             cluster
% 2-
%===============================================================

%no. of clusters
k=length(unique(LblIm));

for i=1:k
    curLblIm=(LblIm==i); %binary image with just 1 label (out of k)
    PixIdc=find(curLblIm(:)); %get indices of pixels that belong to cluster 
    numPixels=length(PixIdc);
    
    %---------
    % Original
    %---------
    
%     RandomIDX=unidrnd(numPixels,options.numOfRefPxls);
%     RefPix(:,i)=PixIdc(RandomIDX);

    %-----------
    % CHANGED TO!
    %-----------
    RandomIDX=unidrnd(numPixels,options.numOfRefPxls,options.numOfRefSets);
    RefPix(:,i,:)=PixIdc(RandomIDX);

 
    pixAreaIdxs{i}=PixIdc;
end


end

