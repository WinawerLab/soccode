%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing: Extract pixel means and pixel variances within the
% stimulus aperture of a generated set of images, and save for future
% reference.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load preprocessed images; compile statistics about them
rvals = [0.25, 0.5, 1, 1.5, 2, 4];
svals = [0.125, 0.25, 0.5, 0.75, 1, 2];
avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 3, 4, 8, 12, 16];

catMeans.rvals = rvals;
catMeans.svals = svals;
catMeans.avals = avals;
catMeans.evals = evals;

catVars.rvals = rvals;
catVars.svals = svals;
catVars.avals = avals;
catVars.evals = evals;

bandMeans.rvals = rvals;
bandMeans.svals = svals;
bandMeans.avals = avals;
bandMeans.evals = evals;

bandVars.rvals = rvals;
bandVars.svals = svals;
bandVars.avals = avals;
bandVars.evals = evals;

filedir = fullfile(rootpath, 'data/preprocessing/2015-03-11');

%% Step one is to compile something that's as much like a single voxel's
% beta weight as possible - which is really averaging over frames
% and recording two things: the *mean*, and the *variance* of the relevant
% pixels in the circular aperture containing the image

% First create a mask, to prepare to grab the mean and variance in relevant region
maskSize = 34;
mask = makeCircleMask(maskSize, 90); % Smaller mask, misses the edges; only correct for the 90x90 images

catMeans.maskSize = maskSize;
catVars.maskSize = maskSize;
bandMeans.maskSize = maskSize;
bandVars.maskSize = maskSize;

% We'll save our measurements in big matrices, indexed by r, s, a, and
% e, and then the image number for that category
nImages = 155;
nBands = 8;
catMeans.values = zeros(length(catMeans.rvals), length(catMeans.svals), ...
                        length(catMeans.avals), length(catMeans.evals), nImages);
catVars.values = zeros(length(catVars.rvals), length(catVars.svals), ...
                       length(catVars.avals), length(catVars.evals), nImages);
                      
bandMeans.values = zeros(length(bandMeans.rvals), length(bandMeans.svals), ...
                         length(bandMeans.avals), length(bandMeans.evals), nImages, nBands);
bandVars.values = zeros(length(bandVars.rvals), length(bandVars.svals), ...
                         length(bandVars.avals), length(bandVars.evals), nImages, nBands);


% Now go imageset-by-imageset and get two measurements per image category

for rIdx = 1:length(catMeans.rvals)
    for sIdx = 1:length(catMeans.svals)
        for aIdx = 1:length(catMeans.avals)
            for eIdx = 1:length(catMeans.evals)
                name = ['divnormbands_r', strrep(num2str(catMeans.rvals(rIdx)), '.', 'pt'),...
                                    '_s', strrep(num2str(catMeans.svals(sIdx)), '.', 'pt'),...
                                    '_a', strrep(num2str(catMeans.avals(aIdx)), '.', 'pt'),...
                                    '_e', strrep(num2str(catMeans.evals(eIdx)), '.', 'pt'), '.mat'];
                
                if(exist(fullfile(filedir, name), 'file'))
                    %tic;
                    load(fullfile(filedir, name), 'preprocess');
                    imNumsToUse = preprocess.imNums;
                    nFrames = size(preprocess.bands, 2) / length(preprocess.imNums);
                    
                    % Process the contrast images
                    contrastIms = flatToStack(preprocess.contrast, nFrames);
                    relevantPixels = maskNd(contrastIms, mask);

                    frameMeans = mean(relevantPixels, 1);
                    catMeans.values(rIdx, sIdx, aIdx, eIdx, :) = squeeze(mean(frameMeans, 3)');

                    frameVars = var(relevantPixels, 1);
                    catVars.values(rIdx, sIdx, aIdx, eIdx, :) = squeeze(mean(frameVars, 3)');
                    
                    % Process the bands
                    bandIms = flatToStack(preprocess.bands, nFrames);
                    relevantPixels = maskNd(bandIms, mask);

                    frameMeans = mean(relevantPixels, 1);
                    bandMeans.values(rIdx, sIdx, aIdx, eIdx, :, :) = squeeze(mean(frameMeans, 3));

                    frameVars = var(relevantPixels, 1);
                    bandMeans.values(rIdx, sIdx, aIdx, eIdx, :, :) = squeeze(mean(frameVars, 3));
                    %toc;
                    %Takes about 5 seconds per file to load and process
                else
                    catMeans.values(rIdx, sIdx, aIdx, eIdx, :) = NaN;
                    catVars.values(rIdx, sIdx, aIdx, eIdx, :) = NaN;
                    bandMeans.values(rIdx, sIdx, aIdx, eIdx, :, :) = NaN;
                    bandVars.values(rIdx, sIdx, aIdx, eIdx, :, :) = NaN;
                end
            end
        end
    end
end

%% That took a little while to generate, so let's save it
outputdir = fullfile(rootpath, ['data/preprocessing/', datestr(now,'yyyy-mm-dd')]);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

save(fullfile(outputdir, 'divnormcatmeans.mat'), 'catMeans');
save(fullfile(outputdir, 'divnormcatvars.mat'), 'catVars');
save(fullfile(outputdir, 'divnormbandmeans.mat'), 'catMeans');
save(fullfile(outputdir, 'divnormbandvars.mat'), 'catVars');

