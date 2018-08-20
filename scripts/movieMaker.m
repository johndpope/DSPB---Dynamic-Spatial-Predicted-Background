%movie maker
makeMovie = 1; %means to make a movie
if(makeMovie)
    movie = VideoWriter('FG-BG.avi');
    movie.FrameRate = 10;
    open(movie);
end
h1 = figure(100);
for ii=1:size(foreGroundMovieLogic,3)
    subplot(2,2,1)
    imshow(mov(:,:,ii),[],'InitialMagnification','fit');
    title(['Original movie- Frame Number ' num2str(ii)]);
    subplot(2,2,2)
    imshow(abs(C(:,:,ii)-foreGroundMovieLogic(:,:,ii)),[],'InitialMagnification','fit');
    title(['Difference RPCA-Spatial Estimations- Frame Number ' num2str(ii)]);
    subplot(2,2,3)
    imshow(C(:,:,ii),[],'InitialMagnification','fit');
    title(['Foreground RPCA Estimation- Frame Number ' num2str(ii)]);
    subplot(2,2,4)
    imshow(foreGroundMovieLogic(:,:,ii),[],'InitialMagnification','fit');
    title(['Foreground Spatial Estimation- Frame Number ' num2str(ii)]);
    F = getframe(gcf);
    writeVideo(movie,F);
end

close(movie);