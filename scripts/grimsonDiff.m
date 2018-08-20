function [grimsonStd grimsonMean] = grimsonDiff(diffSeries,numOfGrimsonFrames,lastFrame)
%===============================================================
% module: 
% ------
% grimsonDiff.m
%
% project: 
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% This function receives a MxNxK cube of diff images and calculates grimson model
%
% Inputs:
% ------
% diffSeries- a MxNxK cube of diff images
% numOfGrimsonFrames- amount of frames to build to model
% lastFrame- last frame of the model
%
% Outputs:
% -------
% grimsonStd-  a (MXN) matrix, contains std of the cube- for every pixel
% grimsonMean- a (MXN) matrix, contains mean of every pixel
%
% Authors: Itay kezurer & yaniv tocker
% Copyright 2012-2013 The Hageges
% Revision: 1.0 Date: 2/03/2013 16:35
%=============================================================== 

%--------------------------------------------
% NEW
%--------------------------------------------
% matrix of means for the training data
grimsonMean = mean(diffSeries,3);
% matrix of std for the training data
grimsonStd = std(diffSeries,1,3); 

%============================================

%--------------------------------------------
% OLD
%--------------------------------------------
% %first frame of the model
% firstFrame = lastFrame - numOfGrimsonFrames + 1;
% %data for the model
% trainData = diffSeries(:,:,firstFrame:lastFrame);
% % matrix of means for the training data
% grimsonMean = mean(trainData,3);
% % matrix of std for the training data
% grimsonStd = std(trainData,1,3); 
%============================================


end
