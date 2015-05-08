%% Recover ancient history - are the *input images* the same?
findVoxel = 31;
ancientResults = load(fullfile(rootpath, 'data', 'modelfits', '2014-06-24', 'results_V1_all_R=1_S=0pt5.mat'));
% findVoxel = 30;
% ancientResults = load(fullfile(rootpath, 'data', 'modelfits', '2014-06-24', 'results_V2_all_R=1_S=0pt5.mat'));
voxIdx = find(ancientResults.voxelFitIxs == findVoxel);
ancientParams = ancientResults.results.params(:, :, voxIdx);

%ancientIms = load(fullfile(rootpath, 'data', 'preprocessing', '2014-07-08', 'stimuli_preprocess_R=1_S=0pt5.mat'));
load(fullfile(rootpath, 'data', 'preprocessing', '2014-12-04', 'contrastNeighbors0.mat'), 'contrastNeighbors');
ancientIms = contrastNeighbors;
imStack = flatToStack(preprocess.contrast, 9);
imPxv = stackToPxv(imStack);
ancientIms = permute(imPxv, [2 1 3]);

aOld = 0;
eOld = 1;
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-05');
%dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07'); % get the indexing right!
folder = ['vox', num2str(findVoxel)];
filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename), 'results');
load(fullfile(rootpath, results.inputImages), 'preprocess');
oldIms = preprocess.contrast;
imStack = flatToStack(preprocess.contrast, 9);
imPxv = stackToPxv(imStack);
oldIms = permute(imPxv, [2 1 3]);

assert(sum(sum(sum(oldIms - ancientIms))) < eps)

%% Predictions
modelfun = get_socmodel_original(90);
ancientPredictions = predictResponses(ancientIms(convertIndex(preprocess.imNums, results.imNumsToUse), :, :), ancientParams, modelfun);
oldPredictions = results.concatPredictions;

%% Plot predictions
setupBetaFig;
bar(results.betamnToUse);
plot(ancientPredictions, 'co-');
plot(oldPredictions, 'ro-');
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
addXlabels(results.imNumsToUse, stimuliNames);
legend('Betas', 'Ancient Fit', 'Modern Fit, a=0')

%% View params
disp('Ancient params:')
disp(ancientParams)
disp('New params:')
for ii = 1:length(results.foldResults)
    disp(results.foldResults(ii).params)
end

%% Get the fixed *fit*, problem is gone!
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07');
folder = ['vox', num2str(findVoxel)];
filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename), 'results');


%% Get new fits on old and new image sets
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07');

fullDatasetIdx = convertIndex(results.imNumsDataset, preprocess.imNums);

redoFitFullSet = modelfittingContrastIm(modelfun, betamn(findVoxel, fullDatasetIdx), ...
    ancientIms);
save(fullfile(dataloc, 'redoFitFullSet.mat'), 'redoFitFullSet');

redoFitPartSet = modelfittingContrastIm(modelfun, betamn(findVoxel, results.datasetIdxToUse), ...
    ancientIms(convertIndex(preprocess.imNums, results.imNumsToUse), :, :));
save(fullfile(dataloc, 'redoFitPartSet.mat'), 'redoFitPartSet');

%% Visualize
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07');
load(fullfile(dataloc, 'redoFitFullSet.mat'), 'redoFitFullSet'); % whoah, c is really weird here?
load(fullfile(dataloc, 'redoFitPartSet.mat'), 'redoFitPartSet');

redoFullPredictions = predictResponses(ancientIms, redoFitFullSet.params, modelfun);
redoPartPredictions = predictResponses(ancientIms, redoFitPartSet.params, modelfun);

setupBetaFig;
bar(betamn(findVoxel, fullDatasetIdx));
plot(redoFullPredictions, 'co-');
plot(redoPartPredictions, 'mo-');
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
addXlabels(preprocess.imNums, stimuliNames);
legend('Betas', 'Predictions on full dataset', 'Predictions on partial dataset')

%% Visualize all the old, wrongly-indexed, cross-validated *parameters*, but evaluated on the right images

dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-05');

folder = ['vox', num2str(findVoxel)];
filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename), 'results');

for ii = 1:length(results.folds)
    redoPredictions = predictResponses(ancientIms(convertIndex(preprocess.imNums, results.imNumsToUse), :, :), ...
        results.foldResults(ii).params, modelfun);
    setupBetaFig;
    bar(betamn(findVoxel, results.datasetIdxToUse));
    plot(redoPredictions, 'go-');
    addXlabels(preprocess.imNums, stimuliNames);
    legend('Betas', ['Predictions on fold ', num2str(ii)])
end
    
%% Get new NEW fits
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07');

r = 1;
s = 0.5;
aNew = 0.5;
eNew = 4;

[imAll, imFileName, imNumsLoad] = loadOneDivnormIm(inputdir, r, s, aNew, eNew);

redoFitFullAE = modelfittingContrastIm(modelfun, betamn(findVoxel, fullDatasetIdx), ...
    imAll);
save(fullfile(dataloc, 'redoFitFull_a0.5_e4.mat'), 'redoFitFullAE');

redoFitPartAE = modelfittingContrastIm(modelfun, betamn(findVoxel, results.datasetIdxToUse), ...
    imAll(convertIndex(imNumsLoad, results.imNumsToUse), :, :));
save(fullfile(dataloc, 'redoFitPart_a0.5_e4.mat'), 'redoFitPartAE');

%% Visualize all the fits: 
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07');
load(fullfile(dataloc, 'redoFitFullSet.mat'), 'redoFitFullSet');
load(fullfile(dataloc, 'redoFitFull_a0.5_e4.mat'), 'redoFitFullAE');
load(fullfile(dataloc, 'redoFitPartSet.mat'), 'redoFitPartSet');
load(fullfile(dataloc, 'redoFitPart_a0.5_e4.mat'), 'redoFitPartAE');

redoFullOrigPredictions = predictResponses(ancientIms, redoFitFullSet.params, modelfun);
redoFullAEPredictions = predictResponses(ancientIms, redoFitFullAE.params, modelfun);

redoPartOrigPredictions = predictResponses(ancientIms, redoFitPartSet.params, modelfun);
redoPartAEPredictions = predictResponses(ancientIms, redoFitPartAE.params, modelfun);

setupBetaFig;
bar(betamn(findVoxel, fullDatasetIdx));
plot(redoFullOrigPredictions, 'bo-');
plot(redoFullAEPredictions, 'ro-');

plot(redoPartOrigPredictions, 'co-');
plot(redoPartAEPredictions, 'mo-');

load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
addXlabels(preprocess.imNums, stimuliNames);
legend('Betas', 'Predictions on full dataset, ORIG', 'Predictions on full dataset, NEW', ...
   'Predictions on partial dataset, ORIG', 'Predictions on partial dataset, NEW');