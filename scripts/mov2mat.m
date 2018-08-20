function [mov,options]=mov2mat( pathr)
%===============================================================
% Thesis:
% -------
% Mov2Mat
%
% Description:
% -----------
% This code converts a video .avi clip
% to a mat file with dimenstion (row, col , frames)
% Saved in same directory.
%
%
%
% Date: 18.1.18
% Author: Yaniv Tocker
% 
% Revision History:
% 1- 30.1.18 - added option to load mat file 
% 2- 3.2.18 - code gets inputs
% 3 - 4.2.18 - mov (output file) is resize to (120/160). original
%              dimensions are noted in options.row & options.col
%===============================================================

%selects a file and gets its properties

%default folder - from laptop
% [FileName,PathName] = uigetfile(fullfile('D:\GoogleDrive\Thesis\Datasets\ForThesis','*.avi;*.mpeg;*.mat'),'Select Video File');

if strcmp(pathr(end-2:end),'mat')
    disp('mat file loaded');
    mov = open(pathr);
    mov = im2double(squeeze(mov.mov));
    mov=mov(:,:,101:end);
    return;
end


A=read(VideoReader(pathr));

if size(A,3)>1 %RGB
    for i=1:size(A,4) %frames
        %converts to grayscale and double
        mov(:,:,i)=im2double(rgb2gray(A(:,:,:,i)));
    end
else %grayscale video
    for i=1:size(A,4) %frames
        %converts to double
        mov(:,:,i)=im2double(A(:,:,:,i));
    end
end


options.row=size(mov,1);
options.col=size(mov,2);
mov=imresize(mov,[120,160]);


