%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Grid search a and e, across voxels
%   - Run multiple a and e values, and compare best R^2 with each
%   - Do this for a variety of voxels and save the results
%   - Use cross-validated R^2 for the comparison
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dataset
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

%% Choose good voxels
betaSse = sum(betase, 2);
[y,voxNums] = sort(betaSse);

bestV1 = find(strcmp(roilabels(roi(voxNums)), 'V1'));
bestV2 = find(strcmp(roilabels(roi(voxNums)), 'V2'));
bestV3 = find(strcmp(roilabels(roi(voxNums)), 'V3'));

v1VoxNums = bestV1(1:20);
v2VoxNums = bestV2(1:20);
v3VoxNums = bestV3(1:20);
%voxNums = [v1VoxNums, v2VoxNums, v3VoxNums];
voxNums = 31; % TODO do all voxels!

%% Choose a subset of images
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
imNumsDataset = 70:225;

catToUse = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', 'grating_sparse', 'pattern_sparse'}; % omit naturalistic and noise space/halves
imIdxToUse = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catToUse), imNumsDataset);
imNumsToUse = imNumsDataset(imIdxToUse);

%% Load betas
betamnIdxToUse = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);
betamnToUse = betamn(voxNums, betamnIdxToUse);

%% Acquire the desired modelfun
modelfun = get_socmodel_original(90);

%% Select the canonical folds - randomly, but reusably
nFolds = 10;
shuffled = randperm(length(imNumsToUse));
folds = cell(1, nFolds);

for fold = 1:nFolds
    start = round(length(shuffled)/nFolds * (fold-1)) + 1;
    stop = round(length(shuffled)/nFolds * (fold));
    folds{fold} = shuffled(start:stop);
end

%% Set up the inputs and outputs for model fitting
r = 1;
s = 0.5;
avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 3, 4, 8, 12, 16];

inputdir = 'data/preprocessing/2015-03-11';
outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];
if ~exist(fullfile(rootpath, outputdir), 'dir')
    mkdir(fullfile(rootpath, outputdir));
end

%% Loop over a and e values and run folds
for a = avals
    for e = evals
        %% Skip the extra avals
        if (a == 0) && (e > 1)
            continue;
        end
        
        %% Load the images
        [imAll, imFileName] = loadOneDivnormIm(inputdir, r, s, a, e);
        
        %% Set up a results struct
        results.voxNums = voxNums;
        results.dataset = datasetNum;
        results.modelfun = 'get_socmodel_original(90)';
        results.inputImages = fullfile(inputdir, imFileName);
        results.r = r;
        results.s = s;
        results.a = a;
        results.e = e;
        results.folds = folds;
        results.foldResults = struct([]); % struct arrays ftw
        
        %% Run all 10 folds of this a/e
        for fold = 1:nFolds
            allFolds = 1:nFolds;
            trainFolds = allFolds ~= fold;
            idxTrain = [folds{trainFolds}];
            idxTest = folds{fold};
            
            imTrain = imAll(idxTrain, :, :); % todo tenfold here
            imTest = imAll(idxTest, :, :);
            
            betamnTrain = betamnToUse(:, idxTrain);
            betamnTest = betamnToUse(:, idxTest);
            
            results.foldResults(fold) = modelfittingContrastIm(modelfun, betamnTrain, imTrain);
            results.foldResults(fold).foldNumber = fold;
            results.foldResults(fold).imNumsTrain = imNumsToUse(idxTrain);
            results.foldResults(fold).imNumsTest = imNumsToUse(idxTest);
            
            predictions = predictResponses(imTest, results.foldResults(fold).params, modelfun);           
            [r2test, ~] = computeR2(predictions, betamnTest);            
            results.foldResults(fold).r2test = r2test;
        end
        
        %% Estimate average xval r^2
        results.xvalr2 = mean([results.foldResults.r2test]);

        %% Save every a and e with its model fit and x-val R^2
        save(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), ...
        'results');
    end
end

