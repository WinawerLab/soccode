%% Curve fit: Images
% Exploration of manual curve fitting for image input,
% divorcing myself entirely of Kendrick's code for the first time
% 2016-03-09

%% Load raw data
% 2015-06 data

% /Local/Users/olsson/Dropbox/Research/code/SOC-new

% Preprocessed stimuli:
load(fullfile(rootpath, 'data', 'preprocessing', '2015-09-13', 'gaborbandsJunstimuli_b45.mat'));

% fMRI data:
data = load_subj022_2015_06_19();

% 2015-06 data above: TODO, create other-SF gabors (it doesn't take that
%   long, by any measure)
% 2015-10 data: TODO, create Gabors (at several SF's)
% 2016-02 data: TODO, create Gabors (at several SF's)

%% Set up xdata (model input)
gaborIms = reshape(gabor.gaborFlat, 8100, 9, 50, 8); % px * frames * class * ori
gaborIms = permute(gaborIms, [1 4 2 3]); % put the classes to the back, in preparation to flatten the rest
                                           % is now px * ori * frames * class;
gaborData = reshape(gaborIms, [], 50); % verified to work using a "sum" check
gaborData = double(gaborData);

%% Set up ydata (model output)
whichRoi = 'RV1_2to4deg';
roiIdx = strInCellArray(whichRoi, data.roiNames);

[bestR2,bestVoxInRoi] = sort(data.glmr2{roiIdx}, 'descend');
nBestVox = 20;

voxData = data.voxBetamn{roiIdx}(bestVoxInRoi(1:nBestVox), :); % n voxels * 50 classes

%% Need a circular mask for some of the calculations
maskSize = 34;
mask = makeCircleMask(maskSize, 90);
mask = repmat(mask(:), 1, 8, 9);
gaborCircPix = maskNd(gaborTmp, mask);
gaborMeans = mean(gaborCircPix, 1);

%% Fit model using lsqcurvefit, to ONE voxel

% Basic linear
% myfn = @(params, gaborData)(params(1) * sum(gaborData,1)); % TODO: does this need the "size" correction?
% startPts = {1};
% lb = -10; ub = 10;

% With nonlinearilty
% myfn = @(params, gaborData)(params(1)/size(gaborData,1) * sum(gaborData.^params(2),1));
%       % TODO: exponent before or after?
% startPts = {1,1}; % {[1,1],[1,2],[2,1],[2,2]}; % these all give the same thing
% lb = [-100, 0]; ub = [100, 10];
% % yields (10.56, 0.19) on single voxel, with error 6.3886

% With later nonlinearity
% myfn = @(params, gaborData)(params(1) * sum(gaborData,1).^params(2));
% startPts = {[1,1]}; % {[1,1], [1,2], [2,1], [2,2]}; % seeding with [x,2] fails on the single-voxel demo 
% lb = [-100, 0]; ub = [100, 10];
% % yields (0.48, 0.19) on single voxel, with error 6.6197
 
% With SOC, outer nonlinearity
myfn = @(params, gaborData)(params(1) * sum(bsxfun(@minus,gaborData,params(3)*gaborMeans).^2,1).^params(2));
startPts = {[1,1,0.8]};
lb = [-100, 0, 0]; ub = [100, 10, 2];
% % TODO it gets stuck at 1.5, 0.0871, 1 if 1 is the upper bound, tries to
% go for 2 if 2 is the upper bound...

% With SOC, inner nonlinearity
%myfn = @(params, gaborData)(params(1)/size(gaborData,1) * sum(bsxfun(@minus,gaborData,params(3)*gaborMeans).^params(2),1));
%startPts = {[1,1,0.8]};

fitData = voxData(10,:); % one voxel
%fitData = data.roiBetamn{roiIdx}; % region average
fitData = double(fitData);

params = cell(1,length(startPts));
for s = 1:length(startPts)
    params{s} = lsqcurvefit(myfn,startPts{s},gaborData,fitData,lb,ub);
end

preds = cellfun(@(x)(myfn(x,gaborData)), params, 'UniformOutput', false);
[bestErr,bestIdx] = min(cellfun(@(x)(sqrt(sum((x-fitData).^2))), preds));
pred = preds{bestIdx};

setupBetaFig;
plotWithColors(fitData, data.plotOrder, data.plotNames, data.catColors)
plot(pred(:, data.plotOrder), 'ro');
title(num2str(bestErr));

%% Why does "outer nonlinearity" seem to be driving the c parameter all the way up?
gaborTmp = reshape(gabor.gaborFlat, 90, 90, 9, 50, 8); % px * frames * class * ori
gaborTmp = permute(gaborTmp, [1 2 5 3 4]); % put the classes to the back, in preparation to flatten the rest
                                           % is now px * ori * frames * class;

tmp = squeeze(mean(gaborIms, 2));
                                           
whichIm = 10; % hella not plausible
thisIm = gaborTmp(:,:,1,1,whichIm);
meanSquare = ones(90,90)*gaborMeans(whichIm);
meanTwo = ones(90,90)*mean(thisIm(:));
range = [min(thisIm(:)), max(thisIm(:))];

figure; imshow([thisIm, meanSquare, meanTwo, thisIm-meanSquare, thisIm-meanTwo], range);
    % TODO RESTART HERE, the problem is that meanSquare is over the whole
    % category
                                           
                                           
                                           
