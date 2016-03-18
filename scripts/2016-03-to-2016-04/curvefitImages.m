%% Curve fit: Images
% Exploration of manual curve fitting for image input,
% divorcing myself entirely of Kendrick's code for the first time
% 2016-03-09

%% Load raw data
% 2015-06 data
load(fullfile(rootpath, 'data', 'preprocessing', '2015-09-13', 'gaborbandsJunstimuli_b45.mat'));
load(fullfile(rootpath, 'data', 'fMRI_CBI', 'wl_subj022_2015_06_19', 'GLMdenoised', 'roiBetas.mat'));
% 2015-06 data above: TODO, create other-SF gabors (it doesn't take that
%   long, by any measure)
% 2015-10 data: TODO, create Gabors (at several SF's)
% 2016-02 data: TODO, create Gabors (at several SF's)

%% Set up xdata (model input)
gaborData = reshape(gabor.gaborFlat, 8100, 9, 50, 8); % px * frames * class * ori
gaborData = permute(gaborData, [1 2 4 3]); % put the classes to the back, in preparation to flatten the rest
gaborData = reshape(gaborData, [], 50); % verified to work using a "sum" check
gaborData = double(gaborData);

%% Set up ydata (model output)
whichRoi = 'V1'; 
roiIdx = strInCellArray(whichRoi, roiBetas.roiNames);

[bestR2,bestVoxInRoi] = sort(roiBetas.glmr2{roiIdx}, 'descend');
nBestVox = 20;

voxData = double(roiBetas.voxBetamn{roiIdx}(bestVoxInRoi(1:nBestVox), :)); % n voxels * 50 classes

% and we need names... ok, fine
tmp = load_subj022_2015_06_19();

%% Fit model using lsqcurvefit

myfn = @(params, gaborData)(params(1) * sum(gaborData,1));

whichVox = 10;
startPt = 1;
lb = -10; ub = 10;
params = lsqcurvefit(myfn,startPt,gaborData,voxData(whichVox,:),lb,ub);

pred = myfn(params,gaborData);

setupBetaFig;
plotWithColors(voxData(whichVox,:), tmp.plotOrder, tmp.plotNames, tmp.catColors)
plot(pred(:, tmp.plotOrder), 'ro');