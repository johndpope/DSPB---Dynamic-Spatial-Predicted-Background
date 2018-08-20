function DispVid( vid )

    [row col frames]=size(vid);
    figure(1)
    for i=1:frames
        imshow(vid(:,:,i),'InitialMagnification','fit')
        title([ 'Frame #' num2str(i) '/' num2str(frames) ]);
        pause(0.05)
    end


end

