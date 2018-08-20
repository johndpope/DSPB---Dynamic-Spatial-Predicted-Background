function [PxlMatCentered PxlMatMeanInTime] = centerMe(PxlMat)
%===============================================================
% module: 
% ------
% centerMe.m
%
% project: 
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% This function take out the mean of each column of a given matrix
%
% Inputs:
% ------
% PxlMat- a matrix represanting a movie- each col is a frame
%
% Outputs:
% -------
% PxlMatCentered-  every col is a frame (observation), centered
% PxlMatMeanInTime- mean of PxlMat- PxlMatMeanInTime is a col vector, mean of every pixel in time
%
% Authors: Itay kezurer & Ysniv Tocker
% Copyright 2012-2013 The Hageges
% Revision: 1.0 Date: 8/03/2013 16:35
%=============================================================== 

% % center PxlMat matrix- in respect of it's mean for every frame
% frameMeans = mean(PxlMat,1);

% PxlMatMeanInTime is a col vector, mean of every pixel in time
PxlMatMeanInTime = mean(PxlMat,2); 

% PxlMatCentered is a matrix- each col is frame which is centered
PxlMatCentered = PxlMat - repmat(PxlMatMeanInTime,1,size(PxlMat,2));



end