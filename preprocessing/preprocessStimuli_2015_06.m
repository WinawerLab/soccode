%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing: Generate and save bands and DN images for new stimuli
% from June 2015
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the images
imFile = fullfile('data', 'stimuli', 'stimuli-2015-06-19.mat');
load(fullfile(rootpath, imFile), 'stimuli');

imStack = stimuli.imStack;
exemplarsPerClass = size(imStack,4);
numClasses = size(imStack,3);

% Resize and pad images
outputSz = 150; padSz = 30;
imStack = resizeStack(imStack, outputSz, padSz);
% I believe this is correct, even though these come from 800x800 instead of
% 400x400 images like the 2015-04-06 images, because the display
% resolution was the same originally for both, so the analyzing filter
% should still be correct

% Flatten images into vectors and image classes x examplars into exemplars
imFlat = stackToFlat(imStack);

%% Create output dir
outputdir = fullfile(rootpath, 'data', 'preprocessing', datestr(now,'yyyy-mm-dd'));
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

%% Create gabor images at one bandwidth
bandwidth = 37.5*(180/150);

numor = 8;
numph = 2;

tic;
gabor = {};
gabor.bandwidth = bandwidth;
gabor.numor = numor;
gabor.numph = numph;
gabor.function = 'gaborenergy';
gabor.inputImages = imFile;
gabor.imNums = stimuli.imNums; % imNums may become an outdated formalism... but for now it's still working
gabor.nFrames = exemplarsPerClass;

gabor.gaborFlat = gaborenergy(imFlat, numor, numph, bandwidth);

outputFile = ['gaborbandsNewstimuli_b', strrep(num2str(bandwidth), '.', 'pt'), '.mat'];

save(fullfile(outputdir, outputFile), 'gabor');
toc;

%% Use the gabor images
inputDir = fullfile('data', 'preprocessing', '2015-09-13');
inputFile = 'gaborbandsNewstimuli_b45.mat';
load(fullfile(rootpath, inputDir, inputFile), 'gabor');

r = 1;
s = 0.5;
avals = [0, 0.75]; %[0, 0.25, 0.5, 0.75, 1];
evals = [1, 8]; %[1, 2, 4, 8, 16];

for a = avals
    for e = evals
        if (a == 0) && (e > 1)
            continue;
        end
        
        disp(['a=', num2str(a), ' and e=', num2str(e)])
        preprocess = {};
        preprocess.bands = divnormneighbors2(gabor.gaborFlat, r, s, a, e);
        preprocess.contrast = sum(preprocess.bands, 3);
        preprocess.r = r;
        preprocess.s = s;
        preprocess.a = a;
        preprocess.e = e;
        preprocess.function = 'divnormneighbors2(gabor.gaborFlat, r, s, a, e)';
        preprocess.inputImages = inputFile;
        preprocess.imNums = gabor.imNums;
        preprocess.nFrames = gabor.nFrames; % number of frames per category in this dataset

        inputFile = ['newstimuli_r', strrep(num2str(r), '.', 'pt'),...
                            '_s', strrep(num2str(s), '.', 'pt'),...
                            '_a', strrep(num2str(a), '.', 'pt'),...
                            '_e', strrep(num2str(e), '.', 'pt'), '.mat'];
        save(fullfile(outputdir, inputFile), 'preprocess');
    end
end
