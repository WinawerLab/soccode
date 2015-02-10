%% Acquire dataset
dataset = 'dataset03.mat';
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

% betamn is 1323 voxels * 156 betamn values

%% Which images are in the dataset?
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames
betaIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);

%% Pick the twenty least-noisy voxels, then filter for V1 or V2 or V3
nvox = 20;
[y,i] = sort(sum(betase,1));
voxNums = i(1:20);

voxNums = voxNums(logical(strcmp(roilabels(roi(voxNums)), 'V1') + strcmp(roilabels(roi(voxNums)), 'V2') + strcmp(roilabels(roi(voxNums)), 'V3')));

%% Create a Kendrick-style socmodel
curr = cd('/Local/Users/olsson/Dropbox/Research/code/SOC/soccode');
modelfun = soc_getmodelfun(90);
cd(curr);

%% Extract the relevant voxels and images
betamnToUse = betamn(voxNums, betaIdx);

%% Set up input and output directory
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');

outputdir = fullfile(rootpath, ['data/modelfits/', datestr(now,'yyyy-mm-dd')]);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

%% Cycle through contrast images
%T = [0 0.001 0.1 1.0 10.0 100.0 1000.0];
T = 100;
results = cell(1, length(T));

for i = 1:length(T);
    t = T(i);

    % Load and resize preprocessed contrast images
    name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
    load(fullfile(inputdir, name));
    imStack = flatToStack(contrastNeighbors, 9);
    imPxv = stackToPxv(imStack);
    imToUse = permute(imPxv, [2 1 3]);

    % Fit the modelfun!
    results{i} = modelfittingContrastIm(modelfun, betamnToUse, imToUse);
    results{i}.tvalue = t;

    save(fullfile(outputdir, 'neighbordivnorm-results-twentyvoxels.mat'), 'results')
end


%% Now let's load their existing fits! Rather than fit them again. Yay.
rois = {'V1', 'V2', 'V3', 'hV4'};
resultsByRoi = cell(1, numel(rois));
for roiIdx = 1:numel(rois)
    whichRoi = rois{roiIdx};
    
    voxelFitIxs = find(roi == find(strcmp(roilabels, whichRoi)));
    
    curr = cd('/Local/Users/olsson/Dropbox/Research/code/SOC/');
    filenameResults = ['results_', whichRoi, '_all_R=', strrep(num2str(1), '.', 'pt'), '_S=', strrep(num2str(0.5), '.', 'pt'), '.mat'];
    display(['Loading ', filenameResults]);
    loaded = load(fullfile('data/model_fit_results', filenameResults), 'results', 'voxelFitIxs', 'modelfun');
    resultsByRoi{roiIdx} = loaded;
    
    cd(curr);
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

%% Average failure, before?
for roiIdx = 1:numel(rois)
    vis_averagefailure(modelPredictionsByRoi{roiIdx}, betamn, resultsByRoi{roiIdx}.voxelFitIxs, ...
        betamnPredictIxs, stimuli.index(whichStimuliPredict), rois{roiIdx});
end

%% Average failure, after?
