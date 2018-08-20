function [ totStd ] = stdCalc( frame )
%===============================================================
% module:
% ------
% stdCalc.m
%
% project:
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% This function Calculates the Std of the given frame
%
% Inputs:
% ------
% frame- image with values between 0 and 1
%
% Outputs:
% -------
% totStd- global Std of the given frame
%
% Authors: Itay kezurer & Yaniv Tocker
% Copyright 2012-2013 The Hageges
% Revision: 1.0 Date: 2/03/2013 16:35
%===============================================================

[rowAmount,colAmount]=size(frame);

%--------------------------------------------
% MEAN
%--------------------------------------------
% The average of sum of all the values in the matrix.
% To find the mean for each column
colmean=sum(frame)/rowAmount;

%To calculate the mean of the matrix
totmean=sum(frame(:))/(rowAmount*colAmount);
%============================================


%--------------------------------------------
% VARIANCE
%--------------------------------------------
% To calculate the variance and standard-deviation column-wise
myvar=zeros([colAmount,1]);
mystd=zeros([colAmount,1]);
for ii = 1: colAmount
    diff=frame(:,ii)-colmean(ii);
    myvar(ii)=sum(diff.^2)/(rowAmount-1);
    mystd(ii)=sqrt(myvar(ii));
end

%To calculate the variance and standard deviation
totdiff=(frame-totmean).^2;
totSum=sum(totdiff(:));
nele=(rowAmount*colAmount)-1;
totVar = totSum/nele;
totStd=sqrt(totVar);
%============================================




end

