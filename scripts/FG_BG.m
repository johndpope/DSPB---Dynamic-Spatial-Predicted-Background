function [ foreGroundMovieLogic, estimatedBackground ] = FG_BG ( mov, options )
%===============================================================
% module:
% ------
% ramiStyle.m
%
% project:
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% this code creates a FG-BG separation according to rami's method.
%
%
% Inputs:
% ------
% mov- cube of frames (the movie) as double
% options - hyperparameter values as set at MAIN.m
%
% Outputs:
% -------
% estimatedBackground- a 3 dimentional cube representing the BG
% foreGroundMovieLogic- a Logic cube of the FG
%
%
% Date: 11.1.18
% Author: Yaniv Tocker
% 
% Revision History:
% 1- 30.1.18 - playing with clustering - set areas to 5 and only 1 control
%              set for each - for start: each control area will draw
%              control pixel set and estimate ALL IMAGE (just to make sure
%              this is working properly)
%
%            - added "Initialize.m" to hold setting defalut values of
%              options
%
% 2- 1.2.18 - done embedding cluster image and predicting each cluster by
%             it's own estimator - lokos great!. started to add back no. of
%             control sets in each clsuter. wish me luck
%===============================================================

%============================================


%--------------------------------------------
% Initiallization
%--------------------------------------------
%checks if fields exist, if not use default values
if ~exist('options','var')
    options = [];
end

%set defalut values for parameters if user haven't
[ options ] = Initialize( options ); 
% slash handling
if(ismac)
    slash = '/';
else
    slash = '\';
end

% make directory for saving output files
clockDate = clock;

if options.saveFGBG
    testRunDir = ['testRuns' slash 'testRun_' num2str(clockDate(1)) '-' num2str(clockDate(2)) '-' num2str(clockDate(3)) '-' num2str(clockDate(4)) '-' num2str(clockDate(5)) '-'...
        options.fileName '-' num2str(options.alphaBG) slash];
    if(exist(testRunDir,'dir') ~= 7)
        mkdir(testRunDir);
    end
end


numOfGrimsonFramesMin = options.numOfOverallModelFrames - options.numOfBackGroundFrames - options.startFrame + 1;

%pre-allocation
% modelStruct = [];
foreGroundMovie = zeros(size(mov,1),size(mov,2),numOfGrimsonFramesMin);
estimatedBackground = zeros(size(mov));
foreGroundMovieLogic = false(size(mov));
%============================================

%--------------------------------------------
% Initiallize figures position
%--------------------------------------------
if options.displayMode
    scnsize = get(0,'ScreenSize');
    
    h1 = figure(100);
    pos1 = [scnsize(3)/2,scnsize(4)/2+25,scnsize(3)/2-15,scnsize(4)/2-120];
    set(h1,'Position',pos1);
    
    h2 = figure(200);
    pos2 = [scnsize(3)/2,50,scnsize(3)/2-15,scnsize(4)/2-120];
    set(h2,'Position',pos2);
end
%============================================
if(options.profileMode)
    profile on;
end

%progress bar
if(options.waitBar)
    hWait = waitbar(0,'Please wait this might take a while');
end
%============================================

%--------------------------------------------
% Create the train data
%--------------------------------------------
%reshape video into a matrix- each col is a frame
movVectorStyle = reshape(mov,size(mov,1)*size(mov,2),size(mov,3));


%--------------------------------------------
% Cluster initial BG and set control pixels (randomly)
%--------------------------------------------
tic;

%cluster image to [k=options.numOfAreas] clusters (default is 4)
%taking basic bg - temporal median image of first 10 frames to cluster
InitBG=median(mov(:,:,1:10),3);
LblIm = kmeanidx( InitBG,options.numOfAreas );

%pick control pixels randomaly (just chooses pixels index randomly)
% pixRefIdxs = unidrnd(size(movVectorStyle,1),options.numOfRefPxls,options.numOfRefSets);

[ pixRefIdxs,pixAreaIdxs ] = GetRefPix( LblIm,options );
%============================================
pixRefIdxs=reshape(pixRefIdxs,[options.numOfRefPxls options.numOfAreas options.numOfRefSets ]);

%--------------------------------------------
% Model Creation- rami and grimson
%--------------------------------------------

% CHANGED - no. areas + no. estomators on each area
%-------
for kk=1:options.numOfRefSets% no. control sets (=estimators)
    modelStruct=[];
    for jj=1:options.numOfAreas %no. of areas
            % create the basis for estimation the whole movie (background modeling)
            % Gets parameters needed for creating optimal linear estimator
            modelStruct = [modelStruct modelCreation(movVectorStyle,options.startFrame,options.numOfBackGroundFrames,pixRefIdxs(:,jj,kk),pixAreaIdxs{jj})];
          
    end
    Models{kk}=modelStruct;
    clear modelStruct;
end

%CHANGED - This is only with no. of areas
%----------------------
% for jj=1:options.numOfAreas %no. of areas
%     % create the basis for estimation the whole movie (background modeling)
%     % Gets parameters needed for creating optimal linear estimator
%     modelStruct = [modelStruct modelCreation(movVectorStyle,options.startFrame,options.numOfBackGroundFrames,pixRefIdxs(:,jj),pixAreaIdxs{jj})];
%           
% end
%HERE IS ORIGINAL CODE
%----------------------
% for jj=1:options.numOfRefSets %no. estimators
%     % create the basis for estimation the whole movie (background modeling)
%     % Gets parameters needed for creating optimal linear estimator
%     modelStruct = [modelStruct modelCreation(movVectorStyle,options.startFrame,options.numOfBackGroundFrames,pixRefIdxs(:,jj))];
%           
% end
%----------------------


% create diff images

%------------
% Creates BG based on the first 'N' frames used for training.
%------------
for ii = options.startFrame + options.numOfBackGroundFrames:options.numOfOverallModelFrames
    if(options.waitBar)
        waitbar(ii / size(mov,3))
    end
    %Get background by using parameters to estimate it
    [estimatedBackground(:,:,ii), Models] = estimateImage(Models,movVectorStyle(:,ii),pixRefIdxs,pixAreaIdxs,size(mov,1),size(mov,2),options.alphaBG);
end
%diff movie- take numOfGrimsonFramesMin last frames
foreGroundMovie(:,:,1:numOfGrimsonFramesMin) = abs(mov(:,:,ii - numOfGrimsonFramesMin + 1:ii) - estimatedBackground(:,:,ii - numOfGrimsonFramesMin + 1:ii));
foreGroundMovieMean = mean(foreGroundMovie,3);
foreGroundMovieMoment = mean(foreGroundMovie.^2,3);
%============================================

%--------------------------------------------
% Linear Predictor- NEW- background estimation and FG
%--------------------------------------------
%loop which calculate background of each frame in the movie, starting at
%frame one later than the last frame used for buliding the models
for ii = options.numOfOverallModelFrames + 1:size(mov,3)
    if(options.waitBar)
        %wait bar
        waitbar(ii / (size(mov,3)-options.numOfOverallModelFrames))
    end
    
    %grimson model is increased from numOfGrimsonFramesMin to options.numOfGrimsonFramesMax
    numOfGrimsonFrames = min(options.numOfGrimsonFramesMax,numOfGrimsonFramesMin + ii - options.numOfOverallModelFrames);
    alphaModel = (numOfGrimsonFrames - 1) / numOfGrimsonFrames;
    
    %estimate background- rami style
    [estimatedBackground(:,:,ii), Models]  = estimateImage(Models,movVectorStyle(:,ii),pixRefIdxs,pixAreaIdxs,size(mov,1),size(mov,2),options.alphaBG);
    
    if options.progress
        disp(['Processing frame ' num2str(ii) '/' num2str(size(mov,3))]);
    end
    %--------------------------------------------
    % Find Thr via Grimson method
    %--------------------------------------------
    %diff image- take last frames only
    foreGroundFrame = abs(mov(:,:,ii) - estimatedBackground(:,:,ii));
    %add to mean and second moment
    foreGroundMovieMean = alphaModel * foreGroundMovieMean + (1 - alphaModel) * foreGroundFrame;
    foreGroundMovieMoment = alphaModel * foreGroundMovieMoment + (1 - alphaModel) * (foreGroundFrame .^ 2);
    %calculate grimson model
    grimsonStd = sqrt(foreGroundMovieMoment - foreGroundMovieMean.^2);
    % FG image is a logic image where all pixels are higher than 3 std of their std- NEW
    % method
    foreGroundMovieLogic(:,:,ii) = foreGroundFrame > max(3 * grimsonStd,15/255);
    %============================================
    
    % Plot the images
    if(options.displayMode)
        figure(100);
        subplot(3,1,1);
        imshow(estimatedBackground(:,:,ii));
        title(['Estimated Background- Spatial Prediction with frames ' num2str(options.startFrame) ' to ' num2str(options.startFrame + options.numOfBackGroundFrames - 1) ' with ' num2str(options.numOfRefPxls) ' Ref pxls']);
        subplot(3,1,2);
        imshow(mov(:,:,ii));
        title(['Real Image frame number ' num2str(ii)]);
        subplot(3,1,3);
        imshow(foreGroundMovieLogic(:,:,ii));
        title(['Diff Image frame number ' num2str(ii)]);
        saveas(gcf,[cd slash testRunDir slash 'frame' num2str(ii) '.fig']);
        close(gcf)
    end
end
%============================================
if(options.profileMode)
    profile off;
    profile viewer;
end

if(options.waitBar)
    %close progress bar
    close(hWait);
end
%============================================

%--------------------------------------------
% Results
%--------------------------------------------
results = options;
results.overallTime = toc;

if options.dispfinal
    disp('============================');
    disp(['Run time: ' num2str(results.overallTime) ' seconds']);
    disp(['Total Frames: ' num2str(size(foreGroundMovieLogic,3))]);
    disp(['Model Frames: ' num2str(options.numOfOverallModelFrames - options.startFrame + 1)]);
    disp(['Control pixels: ' num2str(options.numOfRefPxls)]);
    disp(['Number of Predictors: ' num2str(options.numOfRefSets)]);
    disp(['Used Grimson modeling with : ' num2str(numOfGrimsonFrames) ' Frames']);
    disp(['Alpha-BG: ' num2str(options.alphaBG)])
    disp('============================');
end
%============================================


%--------------------------------------------
% Scatter plot- works only when there is one pair of Ref pixels only
%--------------------------------------------
if(options.scatterMode)
    pixScatterIdxs = [unidrnd(size(estimatedBackground,1),2,1) unidrnd(size(estimatedBackground,2),2,1)];
    scatX = squeeze(estimatedBackground(pixScatterIdxs(1,1),pixScatterIdxs(1,2),:));
    scatY = squeeze(estimatedBackground(pixScatterIdxs(2,1),pixScatterIdxs(2,2),:));
    scatter(scatX,scatY);
    title('scatter plot- 2 pixels');
    xlabel(['pixel (' num2str(pixScatterIdxs(1,1)) ',' num2str(pixScatterIdxs(1,2)) ')']);
    ylabel(['pixel (' num2str(pixScatterIdxs(2,1)) ',' num2str(pixScatterIdxs(2,2)) ')']);
    saveas(gcf,[cd slash testRunDir slash 'scatterPlot.fig']);
    figure;
    imshow(estimatedBackground(:,:,options.numOfOverallModelFrames + 1));
    hold on;
    plot(pixScatterIdxs(1,2),pixScatterIdxs(1,1),'+r');
    plot(pixScatterIdxs(2,2),pixScatterIdxs(2,1),'ob');
    title(['frame number ' num2str(options.numOfOverallModelFrames + 1) ' - 2 pixels']);
    saveas(gcf,[cd slash testRunDir slash 'scatterPlotPxls.fig']);
end
%============================================



%--------------------------------------------
% Save & Play Movie
%--------------------------------------------
if options.saveFGBG %saves BG & FG as mat files - HUGE MATRIX!!!
    save([cd slash testRunDir slash 'foreGroundMovieLogic'],'foreGroundMovieLogic','-v7.3');
    save([cd slash testRunDir slash 'estimatedBackground'],'estimatedBackground','-v7.3');
    if(options.playMovieMode)
        implay(foreGroundMovieLogic);
        implay(estimatedBackground);
    end
    save([cd slash testRunDir slash 'results'],'results');

end
%============================================

end


