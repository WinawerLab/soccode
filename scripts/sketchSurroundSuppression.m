%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sketch: how to think of different surround suppression schemes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% The pieces to set up for myself!
% 1. Load the images
% 2. Create gabors of the new images if they don't exist already (I think
% they don't)
% 3. Make the stupidest possible graph

%% Load the images and the gabor version
imfile = fullfile(rootpath, 'data', 'stimuli', 'stimuli-2015-06-19.mat');
load(imfile, 'stimuli');

gaborfile = fullfile(rootpath, 'data', 'preprocessing', '2015-09-13', 'gaborbandsNewstimuli_b45.mat');
load(gaborfile, 'gabor');
gaborStack = flatToStack(gabor.gaborFlat, 9);

load(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames');
%% Make a very dumb graph
mask = makeCircleMask(34, 90);
masked = maskNd(gaborStack, mask);
masked = reshape(permute(masked, [2 1 3 4]), size(masked, 2), []);

means = mean(masked, 2);
setupBetaFig(); bar(means); addXlabels(stimuliNames(gabor.imNums)); title('Means');

vars = var(masked, [], 2);
setupBetaFig(); bar(vars); addXlabels(stimuliNames(gabor.imNums)); title('Vars');

setupBetaFig(); bar(vars./means); addXlabels(stimuliNames(gabor.imNums)); title('Vars over Means');

%% Set up params and figure
% r = 1;
% s = 0.5;
% e = 4;
% avals = [1, 0];
% 
% setupBetaFig()
% 
% %% Produce plots
% for a = avals
%     rstr = strrep(num2str(r), '.', 'pt');
%     sstr = strrep(num2str(s), '.', 'pt');
%     astr = strrep(num2str(a), '.', 'pt');
%     estr = strrep(num2str(e), '.', 'pt');
% 
%     file = ['divnormbands_r', rstr, '_s', sstr, '_a', astr, '_e', estr];
%     load(fullfile(rootpath, '/data/preprocessing/2015-03-11/', file));
% 
%     nFrames = 9;
%     bands = flatToStack(preprocess.bands, nFrames);
% 
%     %% Grab subset of images
%     gratingNums = 176:180; gratingIdx = 1:5;
%     patternNums = 181:184; patternIdx = 6:9;
% 
%     gratingIms = bands(:, :, convertIndex(preprocess.imNums, gratingNums), 1, :);
%     patternIms = bands(:, :, convertIndex(preprocess.imNums, patternNums), 1, :);
%     allIms = cat(3, gratingIms, patternIms);
% 
%     %% Create a mask, to prepare to grab the mean and variance within this region
%     mask = makeCircleMask(34, 90);
% 
%     %% Plot images
%     figure;
% 
%     numIms = size(allIms, 3); % number of image types
%     numBands = size(allIms, 5); % number of bands
% 
%     for imIdx = 1:numIms
%         for bandIdx = 1:numBands
%             subplot(numIms, numBands, (imIdx-1)*numBands + bandIdx);
% 
%             im = allIms(:, :, imIdx, :, bandIdx);
%             imshow(im, [0 1]);
% 
%             pixels = im(mask);
%             title([num2str(mean(pixels(:))), 10, num2str(var(pixels(:)))]);
%         end
%     end
%     set(gca,'LooseInset',get(gca,'TightInset'))
%     setfigurepos(2);
% end;
