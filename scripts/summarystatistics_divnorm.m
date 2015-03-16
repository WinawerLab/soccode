%% Load images; compile statistics about them
catMeans.rvals = [0.25, 0.5, 1, 1.5, 2]; % 4 is currently missing on home laptop
catMeans.svals = [0.125, 0.25, 0.5, 0.75, 1, 2];
catMeans.avals = [0, 0.25, 0.5, 0.75, 1];
catMeans.evals = [1, 2, 3, 4];

catVars.rvals = [0.25, 0.5, 1, 1.5, 2]; % 4 is currently missing on home laptop
catVars.svals = [0.125, 0.25, 0.5, 0.75, 1, 2];
catVars.avals = [0, 0.25, 0.5, 0.75, 1];
catVars.evals = [1, 2, 3, 4];

filedir = fullfile(rootpath, 'data/preprocessing/2015-03-11');

%% Step one is to compile something that's as much like a single voxel's
% beta weight as possible - which is really averaging over frames
% and recording two things: the *mean*, and the *variance* of the relevant
% pixels in the circular aperture containing the image

% First create a mask, to prepare to grab the mean and variance in relevant region
mask = makeCircleMask(37.5, 90);

% We'll save our measurements in two big matrices, indexed by r, s, a, and
% e, and then the image number for that category
catMeans.values = zeros(length(catMeans.rvals), length(catMeans.svals), ...
                           length(catMeans.avals), length(catMeans.evals), 155);
catVars.values = zeros(length(catVars.rvals), length(catVars.svals), ...
                          length(catVars.avals), length(catVars.evals), 155);
% ^^^^ Pardon the magic number 155 for number of categories...

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
                    load(fullfile(filedir, name), 'preprocess');
                    imNumsToUse = preprocess.imNums;

                    nFrames = size(preprocess.bands, 2) / length(preprocess.imNums);
                    contrastIms = flatToStack(preprocess.contrast, nFrames);
                    relevantPixels = maskNd(contrastIms, mask);

                    frameMeans = mean(relevantPixels, 1);
                    catMeans.values(rIdx, sIdx, aIdx, eIdx, :) = squeeze(mean(frameMeans, 3)');

                    frameVars = var(relevantPixels, 1);
                    catVars.values(rIdx, sIdx, aIdx, eIdx, :) = squeeze(mean(frameVars, 3)');
                else
                    catMeans.values(rIdx, sIdx, aIdx, eIdx, :) = NaN;
                    catVars.values(rIdx, sIdx, aIdx, eIdx, :) = NaN;
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

