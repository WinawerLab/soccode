%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Effect of orientation-tuned surround suppression
% 
% - Generate new fits for *twenty* good voxels on new contrast images at
%   *two* parameterizations; this is for dataset 4 which had no loadable
%   params at the time so had to be freshly generated
%
%   Experiment run 2015-03-02
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dataset
datasetNum = 4;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames
betaIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);

%% Voxels
% Pick the twenty least-noisy voxels, then filter for V1 or V2 or V3
nvox = 20;
[y,i] = sort(sum(betase,1)); % NOTE: this is, regrettably, COMPLETELY wrong. should be dimension 2. arghrwjkl;asjkl;bfdsghg.
voxNums = i(1:20);
voxNums = voxNums(logical(strcmp(roilabels(roi(voxNums)), 'V1') + strcmp(roilabels(roi(voxNums)), 'V2') + strcmp(roilabels(roi(voxNums)), 'V3')));
betamnToUse = betamn(voxNums, betaIdx);

%% Model
% Create a Kendrick-style socmodel
modelfun = get_socmodel_original(90);

%% Fitting 
inputdir = 'data/preprocessing/2014-12-04';
outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];

for t = [0, 100];
    % Load and resize preprocessed contrast images
    imFilename = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
    load(fullfile(rootpath, inputdir, imFilename));
    imStack = flatToStack(contrastNeighbors, 9);
    imPxv = stackToPxv(imStack);
    imToUse = permute(imPxv, [2 1 3]);
        % Permute because old fitting code expects C * (X*Y) * F, not (X*Y) * C * F

    % Fit the modelfun!
    results = modelfittingContrastIm(modelfun, betamnToUse, imToUse);

    if ~exist(fullfile(rootpath, outputdir), 'dir')
        mkdir(fullfile(rootpath, outputdir));
    end
    
    % Save useful metadata
    results.dataset = datasetNum;
    results.voxNums = voxNums;
    results.imNums = imNumsToUse;
    results.modelfun = 'get_socmodel_original(90)';
    results.inputImages = fullfile(inputdir, imFilename);
    results.r = 1;
    results.s = 0.5;
    results.t = t;

    save(fullfile(rootpath, outputdir, ['neighbordivnorm-results-subj', num2str(datasetNum), '-t', strrep(num2str(t), '.', 'pt'), '-twentyvoxels.mat']), 'results')

end

%% Load the fits
t = 0;
load(fullfile(rootpath, 'data/modelfits/2015-03-03', ['neighbordivnorm-results-subj', num2str(datasetNum), '-t', strrep(num2str(t), '.', 'pt'), '-twentyvoxels.mat']), 'results');
results0 = results;

t = 100;
load(fullfile(rootpath, 'data/modelfits/2015-03-03', ['neighbordivnorm-results-subj', num2str(datasetNum), '-t', strrep(num2str(t), '.', 'pt'), '-twentyvoxels.mat']), 'results');
results100 = results;

clear results; % so I don't accidentally use it without knowing which it is

%% Plot performance
figure; hold on;
bar(results100.trainperformance, 'r');
bar(results0.trainperformance, 'b');
legend('new model, orientation-tuned surround', 'old model, pointwise DN')

%% Create model predictions, t = 0
t = 0;
imFilename = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');
load(fullfile(inputdir, imFilename));
imStack = flatToStack(contrastNeighbors, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

t0Predictions = [];
for i = 1:size(results0.params, 3)
    params = results0.params(:, :, i);
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    modelPredictionsAvg = mean(modelPredictionsByFrame, 2);
    t0Predictions(:, i) = modelPredictionsAvg;
end

%% Create model predictions, t = 100
t = 100;
imFilename = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');
load(fullfile(inputdir, imFilename));
imStack = flatToStack(contrastNeighbors, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

t100Predictions = [];
for i = 1:size(results100.params, 3)
    params = results100.params(:, :, i);
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    modelPredictionsAvg = mean(modelPredictionsByFrame, 2);
    t100Predictions(:, i) = modelPredictionsAvg;
end

%% Now show them!

voxIdx = 4;
voxNum = voxNums(voxIdx);
setupBetaFig()
bar(betamnToUse(voxIdx,:),1);
plot(t0Predictions(:,voxIdx),'ro','LineWidth',3);
plot(t100Predictions(:,voxIdx),'go','LineWidth',3);

ylabel('BOLD signal (% change)');
title('Data and model fit');

addXlabels(imNumsToUse);