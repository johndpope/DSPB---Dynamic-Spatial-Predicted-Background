function [modelStruct] = modelCreation(movVectorStyle,startFrame,numOfBackGroundFrames,pixRefIdxs,pixAreaIdxs)
%===============================================================
% module: 
% ------
% modelCreation.m
%
% project: 
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% This function builds the model
%
% Inputs:
% ------
% movVectorStyle- a matrix represanting a movie- each col is a frame
% startFrame- frame to start from for buliding the background model
% numOfBackGroundFrames- train frames amount
% pixRefIdxs- reference pixels, with them the predicion is done
% pixAreaIdxs- indices of pixels in matching area of control set pixels
%
% Outputs:
% -------
% as a struct modelStruct
% xMean- col vector, every element is the mean of a pixel x in time
% covXY- cov matrix x-y
% covYY- cov matix y, not a cell. it's the matrix
% yMean- col vecotr- mean of 'numOfBackGroundFrames' of refPxls
%
% Authors: Itay kezurer & Yaniv Tocker
% Copyright 2012-2013 The Hageges
% Revision: 1.0 Date: 8/03/2013 16:35
%
% Revision History 
%-----------------
%
% 1 - 31.1.18 - each [pixRefIdx] is a control pixel set which corresponds only to
%               a certain area of the image and only pixels of same area should be
%               estimated by it.
% 2 - 1.2.18  - added option to choose no. estimators (=control sets) in each
%               cluster
%=============================================================== 

%each col is a frame, take only 'numOfBackGroundFrames' for basis of
%estimation of the background
movFramesForEstimation = movVectorStyle(:,startFrame:startFrame + numOfBackGroundFrames - 1);
%take out the mean before calculation of estimation of each pixel, every
%col is a frame in x/yPxlMatCentered- be careful in cov calculation- should
%be every row is a frame


%CHANGED
%----------------------
[yPxlMatCentered modelStruct.yMean] = centerMe(movFramesForEstimation(pixRefIdxs,:));
[xPxlMatCentered modelStruct.xMean] = centerMe(movFramesForEstimation(pixAreaIdxs,:));

%HERE IS ORIGINAL CODE
%----------------------
% [yPxlMatCentered modelStruct.yMean] = centerMe(movFramesForEstimation(pixRefIdxs,:));
% [xPxlMatCentered modelStruct.xMean] = centerMe(movFramesForEstimation);
%----------------------


%cov matrix x-y
modelStruct.covXY = xPxlMatCentered*yPxlMatCentered'/(size(xPxlMatCentered,2)-1);
%cov matix y- the input must be as each row is an observation
modelStruct.covYY = yPxlMatCentered*yPxlMatCentered'/size(yPxlMatCentered,1);


end