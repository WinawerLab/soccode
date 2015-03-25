%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing: Generate and save gabor bands (no divisive normalization)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the images
imFile = fullfile('data', 'input', 'stimuli.mat');
imNumsToUse = [70:173 175:225];
imStack = loadImages(fullfile(rootpath, imFile), imNumsToUse);
exemplarsPerClass = size(imStack,4);
numClasses = size(imStack,3);

% Resize and pad images
outputSz = 150; padSz = 30;
imStack = resizeStack(imStack, outputSz, padSz);

% Flatten images into vectors and image classes x examplars into exemplars
imFlat = stackToFlat(imStack);

%% Create output dir
outputdir = fullfile(rootpath, 'data', 'preprocessing', datestr(now,'yyyy-mm-dd'));
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

%% Create gabor images at different bandwidths
bandwidths = [0.125, 0.25, 0.5, 1, 1.5, 2] * 37.5*(180/150);

numor = 8;
numph = 2;

for b = bandwidths
    tic;
    gabor = {};
    gabor.bandwidth = b;
    gabor.numor = numor;
    gabor.numph = numph;
    gabor.function = 'gaborenergy';
    gabor.inputImages = imFile;
    gabor.imNums = imNumsToUse;
    gabor.nFrames = exemplarsPerClass;
    
    gabor.gaborFlat = gaborenergy(imFlat, numor, numph, b);

    name = ['gaborbands_b', strrep(num2str(b), '.', 'pt'), '.mat'];
                    
    save(fullfile(outputdir, name), 'gabor');
    toc;
    
end