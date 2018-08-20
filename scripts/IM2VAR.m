function [vid,options] = IM2VAR( pathr,options)
%load images from a path
%to create a mat variable as movie

files=dir([pathr '*.jpg']);% for movie! gt are bmp
%                 a=imread([pathr files(1).name]);
%                 vid=zeros([size(a) length(files)]);
for i=1:size(files,1)
    vid(:,:,i)=im2double(rgb2gray(imread([pathr files(i).name])));
    options.row=size(vid,1);
    options.col=size(vid,2);
end

vid=imresize(vid,0.5);

   



