% visualizegaborenergy
%
% Load and view a subset of images from soc experiments

% Load the images
imFile = fullfile(rootpath, 'data', 'input', 'stimuli.mat');
imNums = [70:173 175:225];
imStack = loadImages(imFile, imNums);
exemplarsPerClass = size(imStack,4);
numClasses = size(imStack,3);

% Resize and pad images
outputSz = 150; padSz = 30;
imStack = resizeStack(imStack, outputSz, padSz);

% Flatten images into vectors and image classes x examplars into exemplars
imFlat = stackToFlat(imStack);

% Compute Gabor filter outputs
numor = 8;
numph = 2;
gaborFlat = gaborenergy(imFlat, numor, numph);
gaborStack = flatToStack(gaborFlat, exemplarsPerClass);

gaborStackMeanOverOri = mean(gaborStack, 5);

%% Visualize images and gabor outputs
figure; colormap gray;
gaborlim = [min(gaborStackMeanOverOri(:)) max(gaborStackMeanOverOri(:))];

% First create a mask, to prepare to grab the mean and variance in relevant region
mask = makeCircleMask(37.5, 90);
gaborStackMeanOriPix = squeeze(mean(maskNd(gaborStackMean, mask),1));

for ii = 1:numClasses
    subplot(2,2,1)
    imagesc(imStack(:,:,ii,1), [-.5 .5]);
    axis image off
    title(ii)
    
    subplot(2,2,2)
    imagesc(gaborStackMeanOverOri(:,:,ii,1), gaborlim);
    axis image off
    title(ii)
    
    subplot(2,1,2); cla
    plot(sort(gaborStackMeanOriPix(:))); hold on;
    plot([1 numel(gaborStackMeanOriPix)], [1 1]*gaborStackMeanOriPix(ii), 'r-')
    pause(.3)
end


