function [FG_post, options]=POST_PRO(FG,idx,options) %like a boss

% The function gets FG binary video (row,col,frames) and tries post_pro
% technique.
% the name of method tried os saved in options.Method
% 'k' is the iteration number and chooses which post pro tech to try!

switch idx
    
    case 1 % raw
        options.Method = [options.Method(1:4) '_raw'];
        Method='raw';
        FG_post=FG;
        
    case 2 %median 3x3
        options.Method = [options.Method(1:4) '_3x3med'];
        Method='3x3 median';
        FG_post=medfilt3(FG,[3 3 1]);

    case 3 %median 5x5
        options.Method = [options.Method(1:4) '_5x5med'];
        Method='5x5 median';
        FG_post=medfilt3(FG,[5 5 1]);
        
    case 4 %median 7x7
        options.Method = [options.Method(1:4) '_7x7med'];
        Method='7x7 median';
        FG_post=medfilt3(FG,[7 7 1]);
        
    case 5 %morph closing
        options.Method = [options.Method(1:4) '_close'];
        Method='closing';
        se = strel('square',2);
        FG_post=imclose(FG,se);

    case 6 %morph opening
        options.Method = [options.Method(1:4) '_open'];
        Method='opening';
        se = strel('square',2);
        FG_post=imopen(FG,se);

    case 7 %holes
        options.Method = [options.Method(1:4) '_holes'];
        Method='close holes';
        FG_post=imfill(FG,'holes');
        
    case 8 %morph are open (drop lowest CC)
        options.Method = [options.Method(1:4) '_area'];
        FG_post=RemoveLowCC(FG,3);
        
    case 9 %close + holes
        options.Method = [options.Method(1:4) '_close_holes'];
        Method='opening + close holes';
        se = strel('square',2);
        FG=imclose(FG,se);
        for i=1:size(FG,3)
            FG_post(:,:,i)=imfill(FG(:,:,i),'holes');
        end
        
    case 10 %open + holes
        options.Method = [options.Method(1:4) '_open_holes'];
        Method='opening + open holes';
        se = strel('square',2);
        FG=imopen(FG,se);
        for i=1:size(FG,3)
            FG_post(:,:,i)=imfill(FG(:,:,i),'holes');
        end
 
end
    
disp(['Post processing technique: ' Method]);
end

