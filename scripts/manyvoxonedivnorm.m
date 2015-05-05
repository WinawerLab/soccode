%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Effect of orientation-tuned surround suppression
% 
% - Generate new fits for *twenty* good voxels on new contrast images at
%   just one parameterization
% - Compare with old fits, from existing contrast images
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dataset
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames
betaIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);

%% Voxels
% Pick the twenty least-noisy voxels, then filter for V1 or V2 or V3
nvox = 20;
[y,i] = sort(sum(betase,1));
voxNums = i(1:20);
voxNums = voxNums(logical(strcmp(roilabels(roi(voxNums)), 'V1') + strcmp(roilabels(roi(voxNums)), 'V2') + strcmp(roilabels(roi(voxNums)), 'V3')));
betamnToUse = betamn(voxNums, betaIdx);

%% Model
% Create a Kendrick-style socmodel
modelfun = get_socmodel_original(90);

%% Fitting 
inputdir = 'data/preprocessing/2014-12-04';
outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];

t = 100;

% Load and resize preprocessed contrast images
imFilename = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
load(fullfile(rootpath, inputdir, imFilename));
imStack = flatToStack(contrastNeighbors, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);
    % Permute because old fitting code expects C * (X*Y) * F, not (X*Y) * C * F

% Fit the modelfun!
results = modelfittingContrastIm(modelfun, betamnToUse, imToUse);
results.tvalue = t;

if ~exist(fullfile(rootpath, outputdir), 'dir')
    mkdir(fullfile(rootpath, outputdir));
end

save(fullfile(rootpath, outputdir, ['neighbordivnorm-results-subj', num2str(datasetNum), '-t', strrep(num2str(t), '.', 'pt'), '-twentyvoxels.mat']), 'results')

%% Load the new fits
t = 100;
load(fullfile(rootpath, 'data/modelfits/2014-12-04', ['neighbordivnorm-results-subj', num2str(datasetNum), '-t', strrep(num2str(t), '.', 'pt'), '-twentyvoxels.mat']), 'results');
    
%% Load the very old previous fits, from the old directory

rois = {'V1', 'V2', 'V3', 'hV4'};
resultsByRoi = cell(1, numel(rois));
for roiIdx = 1:numel(rois)
    whichRoi = rois{roiIdx};    
%    voxelFitIxs = find(roi == find(strcmp(roilabels, whichRoi)));
    
    filenameResults = ['2014-06-24/results_', whichRoi, '_all_R=1_S=0pt5.mat'];
    display(['Loading ', filenameResults]);
    loaded = load(fullfile(rootpath, 'data/modelfits/', filenameResults), 'results', 'voxelFitIxs', 'modelfun');
    resultsByRoi{roiIdx} = loaded;
end


%% Get old results
oldParams = [];
oldPerformance = [];
for i = 1:length(voxNums)
    roiname = roilabels(roi(voxNums(i)));
    thisRoi = resultsByRoi{find(ismember(rois, roiname))};
    thisIdx = find(thisRoi.voxelFitIxs == voxNums(i));
    oldParams(:, :, i) = thisRoi.results.params(:, :, thisIdx);
    oldPerformance = [oldPerformance, thisRoi.results.trainperformance(thisIdx)];
end

newParams = results{1}.params;
newPerformance = results{1}.trainperformance;

% Plot that!
figure; hold on; bar(newPerformance, 'r'); bar(oldPerformance, 'b');
legend('new model, orientation-tuned surround', 'old model, pointwise DN')

%% How does c change?
% TODO this doesn't work now, bleh
cparams = [squeeze(oldParams(:,6,:)), squeeze(newParams(:,6,:))];
figure; hold all;
for i = 1:size(cparams, 1)
    plot(cparams(i,:));
end
% ... eh. Some of these c values are a little wonky.


%% Model predictions
oldPredictions = [];
for i = 1:size(oldParams, 3)
    params = oldParams(:, :, i);
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    modelPredictionsAvg = mean(modelPredictionsByFrame, 2);
    oldPredictions(:, i) = modelPredictionsAvg;
end

newPredictions = [];
for i = 1:size(newParams, 3)
    params = newParams(:, :, i);
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    modelPredictionsAvg = mean(modelPredictionsByFrame, 2);
    newPredictions(:, i) = modelPredictionsAvg;
end

%% Where do they differ most?
diff = mean(newPredictions-oldPredictions, 2);
setupBetaFig; bar(diff); addXlabels(imNumsToUse, stimuliNames);

%% Plot with betamns