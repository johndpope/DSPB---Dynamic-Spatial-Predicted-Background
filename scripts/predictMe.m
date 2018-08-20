function [xEstimated error] = predictMe(movVectorStyle,yPxlMatCentered,yMean,numOfBackGroundFrames,pixRefIdxs,idxEstimated)
%===============================================================
% module: 
% ------
% predictMe.m
%
% project: 
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% This function predict a given pixel linearly in the numOfBackGroundFrames
% + 1 frame
%
% Inputs:
% ------
% movVectorStyle- a matrix represanting a movie- each col is a frame
% yPxlMatCentered- same matrix, without the mean of each col, each row is
% an observation
% yMean- mean of yPxlMat- col vector
% numOfBackGroundFrames- train frames amount
% pixRefIdxs- reference pixels, with them the predicion is done
% idxEstimated- index to estimate
%
% Outputs:
% -------
% xEstimated-  estimated x pixel
% error- between real x at that frame and the estimated one
%
% Authors: Itay kezurer & Yaniv Tocker
% Copyright 2012-2013 The Hageges
% Revision: 1.0 Date: 8/03/2013 16:35
%=============================================================== 

% each row in xPxl is an observation
% col vector
xPxl = movVectorStyle(idxEstimated,1:numOfBackGroundFrames)';
%cov matrix x-y
covXY = bsxfun(@minus,xPxl,mean(xPxl))' * yPxlMatCentered/(size(xPxl,1)-1);
%cov matix y
covYY = cov(yPxlMatCentered);
%mean X
xMean = mean(xPxl);
%yValue- in numOfBackGroundFrames+1 frame
yValue = movVectorStyle(pixRefIdxs,numOfBackGroundFrames + 1);    %col vector

%estimation
xEstimated = xMean + covXY*pinv(covYY)*(yValue - yMean);
error = xEstimated - movVectorStyle(idxEstimated,numOfBackGroundFrames + 1);



end