function [estimatedBackground, Models] = estimateImage(Models,frame,pixRefIdxs,pixAreaIdxs,rowAmount,colAmount,alphaBG)
%===============================================================
% module:
% ------
% estimateImage.m
%
% project:
% -------
% Foreground Detection- Vision 2013
%
% Description:
% -----------
% This function predict a given frame's background by the linear estimator
%
% Inputs:
% ------
% as modelStruct with fields:
% xMean- col vector, every element is the mean of a pixel x in time
% covXY- cov matrix x-y
% covYY- cov matix y, not a cell. it's the matrix
% yMean- col vecotr- mean of 'numOfBackGroundFrames' of refPxls
%
% frame- a given frame- to estimate background
% pixRefIdxs- control pixels, by their values the estimation of the whole frame
%             is done, can be a matrix- every col is a pair
% pixAreaIdxs- a cell array, each cell holds the  indices of pixels in matching area of control set pixels
% rowAmount- amount of rows in original movie
% colAmount- amount of cols in original movie
% alphaBG- parameter for updating the model
%
% Outputs:
% -------
% estimatedBackground-  background estimation- by linear estimation of
% pixRefIdxs
% modelStruct- updated model
%
% Authors: Itay kezurer & Yaniv Tocker
% Copyright 2012-2013 The Hageges
% Revision: 1.0 Date: 7/04/2013 16:35
% -1.1 4/11/14 17:00: update the model% Revision History 
%-----------------
%
% 1 - 31.1.18 - each [pixRefIdx] is a control pixel set which corresponds only to
%               a certain area of the image and only pixels of same area should be
%               estimated by it.
%             - pixAreaIdxs- a cell array, each cell holds the  indices of 
%                            pixels in matching area of control set pixels
% 2- 1.2.18 - added options to choose no. predictors created for clusters
%
%=============================================================== 


% CHANGED - no. areas & no. predictors
%---------------------------

numSets=size(pixRefIdxs,3); %no. control sets
numAreas=size(pixRefIdxs,2); %no. areas
%pre-allocate
estimatedMat = zeros(rowAmount*colAmount,numSets);
estimatedBackground = zeros(rowAmount,colAmount);
xEstimated=zeros(rowAmount*colAmount,1);

for kk=1:numSets % runs on control pixel set
    %an image is created for each of the control sets.
    
    modelStruct=Models{kk};
    for ii=1:numAreas %run on areas

        %update model parameters - for each cluster
        % (changed xmean and covXY rows to take specific indices)
        modelStruct(ii).xMean = alphaBG * modelStruct(ii).xMean + (1-alphaBG) * frame(pixAreaIdxs{ii});
        modelStruct(ii).yMean = alphaBG * modelStruct(ii).yMean + (1-alphaBG) * frame(pixRefIdxs(:,ii,kk));
        modelStruct(ii).covXY = alphaBG * modelStruct(ii).covXY + (1-alphaBG) * (frame(pixAreaIdxs{ii}) - modelStruct(ii).xMean) * (frame(pixRefIdxs(:,ii,kk)) - modelStruct(ii).yMean)' ;
        modelStruct(ii).covYY = alphaBG * modelStruct(ii).covYY + (1-alphaBG) * (frame(pixRefIdxs(:,ii,kk)) - modelStruct(ii).yMean) * (frame(pixRefIdxs(:,ii,kk)) - modelStruct(ii).yMean)' ;

        %yValue- values of pixRefIdxs in the given frame
        yValue(:,ii) = frame(pixRefIdxs(:,ii,kk));    %col vector

        %estimation of the whole image
        xEstimated(pixAreaIdxs{ii}) = modelStruct(ii).xMean + modelStruct(ii).covXY*pinv(modelStruct(ii).covYY)*(yValue(:,ii) - modelStruct(ii).yMean);

        %ref pixels - doun't change their value
        xEstimated(pixRefIdxs(:,ii,kk)) = frame(pixRefIdxs(:,ii,kk));

        %every col is an estimated BG image
    %     testBG=reshape(xEstimated,rowAmount,colAmount);
    %     imshow(testBG);
    end
    Models{kk}=modelStruct; %return updated model for each cluster of a specific control set 
    % to Models cell array
    estimatedMat(:,kk) = xEstimated;
end


% up to here we have [numSets] estimated images as columns in 'estimatedMat.mat'.
% now we need to choose for each pixel which value to take - the most
% consistent one.

%--------------------------------------------
% Check which estimation is better
%--------------------------------------------

if(numSets ~= 1) %if more than 1 estimator is used
    %     diff2To1 = reshape(estimatedStruct(2).estimatedBackground - estimatedStruct(1).estimatedBackground,rowAmount*colAmount,1);
    %     diff3To1 = reshape(estimatedStruct(3).estimatedBackground - estimatedStruct(1).estimatedBackground,rowAmount*colAmount,1);
    %     diff3To2 = reshape(estimatedStruct(3).estimatedBackground - estimatedStruct(2).estimatedBackground,rowAmount*colAmount,1);
%     diff2To1 = abs(estimatedMat(:,2)-estimatedMat(:,1));
%     diff3To1 = abs(estimatedMat(:,3)-estimatedMat(:,1));
%     diff3To2 = abs(estimatedMat(:,3)-estimatedMat(:,2));
%     diffMat = [diff2To1 diff3To2 diff3To1];
%     [~, colToTake] = min(diffMat,[],2);
%     linIdxInMat = sub2ind(size(diffMat), 1:size(diffMat, 1), colToTake');
%     estimatedBackground = reshape(estimatedMat(linIdxInMat),rowAmount,colAmount);
    
%   taking median value - to ignore outliers
    estimatedBackground = reshape(median(estimatedMat,2),rowAmount,colAmount);
else
    estimatedBackground = reshape(estimatedMat,rowAmount,colAmount);
end

%============================================




% -----------------
% CHANGES - build image as mosaic from diffrent prediction areas
% -----------------

% %pre-allocate
% estimatedBackground = zeros(rowAmount,colAmount);
% estimatedMat = zeros(rowAmount*colAmount,1);
% xEstimated=zeros(rowAmount*colAmount,1);
% 
% for ii=1:size(pixRefIdxs,2) %number of areas the image was divided into
%     
%     %update model parameters - for each cluster
%     % (changed xmean and covXY rows to take specific indices)
%     modelStruct(ii).xMean = alphaBG * modelStruct(ii).xMean + (1-alphaBG) * frame(pixAreaIdxs{ii});
%     modelStruct(ii).yMean = alphaBG * modelStruct(ii).yMean + (1-alphaBG) * frame(pixRefIdxs(:,ii));
%     modelStruct(ii).covXY = alphaBG * modelStruct(ii).covXY + (1-alphaBG) * (frame(pixAreaIdxs{ii}) - modelStruct(ii).xMean) * (frame(pixRefIdxs(:,ii)) - modelStruct(ii).yMean)' ;
%     modelStruct(ii).covYY = alphaBG * modelStruct(ii).covYY + (1-alphaBG) * (frame(pixRefIdxs(:,ii)) - modelStruct(ii).yMean) * (frame(pixRefIdxs(:,ii)) - modelStruct(ii).yMean)' ;
%     
%     %yValue- values of pixRefIdxs in the given frame
%     yValue(:,ii) = frame(pixRefIdxs(:,ii));    %col vector
%     
%     %estimation of the whole image
%     xEstimated(pixAreaIdxs{ii}) = modelStruct(ii).xMean + modelStruct(ii).covXY*pinv(modelStruct(ii).covYY)*(yValue(:,ii) - modelStruct(ii).yMean);
%     
%     %ref pixels - doun't change their value
%     xEstimated(pixRefIdxs(:,ii)) = frame(pixRefIdxs(:,ii));
%     
%     %every col is an estimated BG image
% %     testBG=reshape(xEstimated,rowAmount,colAmount);
% %     imshow(testBG);
% end
% 
% estimatedMat= xEstimated;
% estimatedBackground = reshape(estimatedMat,rowAmount,colAmount);



%USED ONLY WITH MORE THAN 1 CONTROL PIXEL SETS (a several options for
% predicted values)!
%
% -----------------
% Original Code
% -----------------
% %pre-allocate
% % estimatedBackground = zeros(rowAmount,colAmount);
% estimatedMat = zeros(rowAmount*colAmount,size(pixRefIdxs,2));
% 
% for ii=1:size(pixRefIdxs,2) %runs on number of estimators
%     %update model parameters
%     modelStruct(ii).xMean = alphaBG * modelStruct(ii).xMean + (1-alphaBG) * frame;
%     modelStruct(ii).yMean = alphaBG * modelStruct(ii).yMean + (1-alphaBG) * frame(pixRefIdxs(:,ii));
%     modelStruct(ii).covXY = alphaBG * modelStruct(ii).covXY + (1-alphaBG) * (frame - modelStruct(ii).xMean) * (frame(pixRefIdxs(:,ii)) - modelStruct(ii).yMean)' ;
%     modelStruct(ii).covYY = alphaBG * modelStruct(ii).covYY + (1-alphaBG) * (frame(pixRefIdxs(:,ii)) - modelStruct(ii).yMean) * (frame(pixRefIdxs(:,ii)) - modelStruct(ii).yMean)' ;
% 
%     
%     %yValue- values of pixRefIdxs in the given frame
%     yValue = frame(pixRefIdxs(:,ii));    %col vector
%     
%     %estimation of the whole image
%     xEstimated = modelStruct(ii).xMean + modelStruct(ii).covXY*pinv(modelStruct(ii).covYY)*(yValue - modelStruct(ii).yMean);
%     
%     %ref pixels - doun't change their value
%     xEstimated(pixRefIdxs(:,ii)) = frame(pixRefIdxs(:,ii));
%     
%     %every col is an estimated BG image
%     estimatedMat(:,ii) = xEstimated;    
% end

%--------------------------------------------
% Check which estimation is better
%--------------------------------------------
%there is an assumption that there are only 3 estimations
% if(size(pixRefIdxs,2) ~= 1) %if more than 1 estimator is used
%     %     diff2To1 = reshape(estimatedStruct(2).estimatedBackground - estimatedStruct(1).estimatedBackground,rowAmount*colAmount,1);
%     %     diff3To1 = reshape(estimatedStruct(3).estimatedBackground - estimatedStruct(1).estimatedBackground,rowAmount*colAmount,1);
%     %     diff3To2 = reshape(estimatedStruct(3).estimatedBackground - estimatedStruct(2).estimatedBackground,rowAmount*colAmount,1);
%     diff2To1 = abs(estimatedMat(:,2)-estimatedMat(:,1));
%     diff3To1 = abs(estimatedMat(:,3)-estimatedMat(:,1));
%     diff3To2 = abs(estimatedMat(:,3)-estimatedMat(:,2));
%     diffMat = [diff2To1 diff3To2 diff3To1];
%     [~, colToTake] = min(diffMat,[],2);
%     linIdxInMat = sub2ind(size(diffMat), 1:size(diffMat, 1), colToTake');
%     estimatedBackground = reshape(estimatedMat(linIdxInMat),rowAmount,colAmount);
% else
%     estimatedBackground = reshape(estimatedMat,rowAmount,colAmount);
% end

%============================================

end