% visualizegaborenergy
%
% Load and view a subset of images from soc experiments

%% Load the images
imFile = fullfile(rootpath, 'data', 'input', 'stimuli.mat');
imNumsToUse = [70:173 175:225];
imStack = loadImages(imFile, imNumsToUse);
exemplarsPerClass = size(imStack,4);
numClasses = size(imStack,3);

% Resize and pad images
outputSz = 150; padSz = 30;
imStack = resizeStack(imStack, outputSz, padSz);

%% Re-compute gabors
% Flatten images into vectors and image classes x examplars into exemplars
imFlat = stackToFlat(imStack);

% Compute Gabor filter outputs
numor = 8;
numph = 2;
gaborFlat = gaborenergy(imFlat, numor, numph);

%% Alternately, load pre-computed images

% Choose from [0.125, 0.25, 0.5, 1, 1.5, 2], bigger is more cycles
coeffs = [0.5, 1]; 

gaborStack = {};
for c = 1:length(coeffs)
    cpfov = coeffs(c) * 37.5*(180/150);
    filename = ['gaborbands_b', strrep(num2str(cpfov), '.', 'pt'), '.mat'];
    inputfile = fullfile('data', 'preprocessing', '2015-03-24', filename);
    load(fullfile(rootpath, inputfile), 'gabor');
    gaborStack{c} = flatToStack(gabor.gaborFlat, exemplarsPerClass);
end

%% Option 0: take mean over ori of one of the gaborstacks
coeff = 0.5;
gaborStackMeanOverOri = mean(gaborStack{coeffs == coeff}, 5);

%% Option 2: combine gabor stacks
gaborStackResize = {};
resizeTo = 90;

overallSum = zeros(size(gaborStack{coeffs == 1}));

coeffs = [0.5, 1];
for c = 1:length(coeffs)
    resizeFactor = 90 / size(gaborStack{c}, 1);
    gaborStackResize{c} = upsamplematrix(gaborStack{c}, [resizeFactor, resizeFactor, 1, 1, 1], [], 0, 'nearest');
    overallSum = overallSum + gaborStackResize{c}/resizeFactor;
end

%% Option 2a: Use overall mean:
% (is this even working?)
% gaborStackMeanOverOri = mean(overallSum, 5);

%% Option 1: Use just a single resized small stack:
coeff = 1;
gaborStackMeanOverOri = mean(gaborStackResize{coeffs == coeff}, 5);

%% Acquire the indexes for sparse gratings and patterns
load(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames')
names = stimuliNames(imNumsToUse);
gratingSparse = find(strcmp(names, 'grating_sparse'));
patternSparse = find(strcmp(names, 'pattern_sparse'));

%% Visualize images and gabor outputs
figure; colormap gray;
gaborlim = [min(gaborStackMeanOverOri(:)) max(gaborStackMeanOverOri(:))];

% First create a mask, to prepare to grab the mean and variance in relevant region
mask = makeCircleMask(34, 90); % Smaller mask, misses the edges; only correct for the 90x90 images
gaborStackMeanOriPix = squeeze(mean(maskNd(gaborStackMeanOverOri, mask), 1));
gaborStackMeanOriVar = squeeze(var(maskNd(gaborStackMeanOverOri, mask), 1));

%for ii = 1:numClasses
for ii = repmat([gratingSparse, patternSparse], 1, 4)
    subplot(3,2,1)
    imagesc(imStack(:,:,ii,1), [-.5 .5]);
    axis image off
    title(ii)
    
    subplot(3,2,2)
    imagesc(gaborStackMeanOverOri(:,:,ii,1), gaborlim);
    axis image off
    title(ii)
    
    subplot(3,1,2); cla
    plot(sort(gaborStackMeanOriPix(:))); hold on;
    plot([1 numel(gaborStackMeanOriPix)], [1 1]*gaborStackMeanOriPix(ii), 'r-') % ignores frame dimension
    title('Means')
    
    subplot(3,1,3); cla
    plot(sort(gaborStackMeanOriVar(:))); hold on;
    plot([1 numel(gaborStackMeanOriVar)], [1 1]*gaborStackMeanOriVar(ii), 'r-')
    title('Variances')
    
    pause;
end

%% Wait, why is 106 variance so high?
figure;
im = gaborStackMeanOverOri(:, :, 106, 1);
subplot(2, 2, 1); imshow(im);
subplot(2, 2, 2); hold on; hist(im(mask)); xlim([0 0.2]); plot(mean(im(mask)), 0, 'rx'); hold off;
title(var(im(mask)));

im = gaborStackMeanOverOri(:, :, 107, 1);
subplot(2, 2, 3); imshow(im);
subplot(2, 2, 4); hold on; hist(im(mask)); xlim([0 0.2]); plot(mean(im(mask)), 0, 'rx'); hold off;
title(var(im(mask)));

%% Create red/blue plots

