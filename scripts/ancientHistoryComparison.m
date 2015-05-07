%% Recover ancient history - are the *input images* the same?
findVoxel = 31;
ancientResults = load(fullfile(rootpath, 'data', 'modelfits', '2014-06-24', 'results_V1_all_R=1_S=0pt5.mat'));
%  findVoxel = 30;
%  ancientResults = load(fullfile(rootpath, 'data', 'modelfits', '2014-06-24', 'results_V2_all_R=1_S=0pt5.mat'));
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
ancientPredictions = predictResponses(ancientIms(results.datasetIdxToUse, :, :), ancientParams, modelfun);
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