%===============================================================
% Description:
% -----------

% Main code for DSPB (Dynamic Spatial Prediction Background) 
% foreground-background separation algorithm.
% This script loads a video clip as a video file or image sequence and 
% performs DSPB algorithm.
%
% all the scripts were written as a part of thesis fullfillment demands
% at Department of Electrical Engineering, Ben-Gurion University,Israel.
% The codes provided are for academic use only, and are protected by
% copyright. For any other usage of these scripts contact me at 
% ytocker@gmail.com
%
% 
% Date: 20.8.18
% Author: Yaniv Tocker
% 
%===============================================================

clc
clear all
close all

%load file
addpath(fullfile(pwd,'scripts'));
pref =str2num(cell2mat(inputdlg('Is your video clip a video file or image squence? 1-video file 2- image seq.','Sample', [1 50])));

if (pref==1) % VIDEO FILE
    [file,path] = uigetfile('*','Select a video file');
    [mov,options]=mov2mat(fullfile(path,file));
elseif (pref==2) % IMAGE SEQUENCE
    path = uigetdir;
    [mov,options] = IM2VAR(path);
else 
    errordlg('Input 1 or 2 only')
end

disp(['Processing ' file '; Dimensions = ' num2str(size(mov))])

%

% set algorithm settings
options.saveFGBG=0; 
options.profileMode=0;
options.progress=0; %display current frame being processed
options.dispfinal=0; %display summary
    
% set algorothm parameters (default values)
options.numOfRefSets = 3; % no. control pixel sets (=estimators)
options.numOfAreas = 1; % no. of parts to divide image
options.numOfRefPxls = 5; % no. control pixels in each set
options.alphaBG = 0.99; % Learning rate value

disp ([    'RefSets-' num2str(options.numOfRefSets) '  Areas-' num2str(options.numOfAreas) '  RefPix-' num2str(options.numOfRefPxls) '  Alpha-' num2str(options.alphaBG) ]);
%
options.Method=['DSPB_' num2str(options.numOfRefSets) 'sets_' num2str(options.numOfAreas) 'area_' num2str(options.numOfRefPxls) 'pix_' num2str(options.alphaBG) 'alpha'];

%

%FG-BG Separation
tic
[FG,~]=FG_BG ( mov, options ); %change ~ to BG to get the background
options.runtime=toc;
%Post Processing
FG= POST_PRO(FG,9,options);  

% Display results 
implay([mov FG]);

