%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Leave-out-out cross-validation for a given A and E
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gridSearchAandE(datasetNum, voxNum)
%% Dataset
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

%% Choose good voxels
v1Vox = find(strcmp(roilabels(roi), 'V1'));
v2Vox = find(strcmp(roilabels(roi), 'V2'));
v3Vox = find(strcmp(roilabels(roi), 'V3'));

betaSse = sum(betase, 2);
[y,bestV1idx] = sort(betaSse(v1Vox));
[y,bestV2idx] = sort(betaSse(v2Vox));
[y,bestV3idx] = sort(betaSse(v3Vox));

v1VoxNums = v1Vox(bestV1idx(1:10));
v2VoxNums = v2Vox(bestV2idx(1:10));
v3VoxNums = v3Vox(bestV3idx(1:10));
voxNums = [v1VoxNums, v2VoxNums, v3VoxNums]; % 30 voxels per brain


voxNums = voxNum; % conversion to function
display(['voxNum: ', num2str(voxNum)])

%% Choose a subset of images / betas
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
imNumsDataset = 70:225;

catToUse = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', 'grating_sparse', 'pattern_sparse'}; % omit naturalistic and noise space/halves
datasetIdxToUse = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catToUse), imNumsDataset);

imNumsToUse = imNumsDataset(datasetIdxToUse);
betamnToUse = betamn(voxNums, datasetIdxToUse);

%% Acquire the desired modelfun
modelfun = get_socmodel_original(90);

%% Select the canonical folds - randomly, but reusably
% NOTE - unless the random seed is re-initialized, this will do the same
% thing every time!
nFolds = 10;
shuffledImNums = imNumsToUse(randperm(length(imNumsToUse)));
foldImNums = cell(1, nFolds);

for fold = 1:nFolds
    start = round(length(shuffledImNums)/nFolds * (fold-1)) + 1;
    stop = round(length(shuffledImNums)/nFolds * (fold));
    foldImNums{fold} = shuffledImNums(start:stop);
end

%% Set up the inputs and outputs for model fitting
r = 1;
s = 0.5;
avals = 0; %[0, 0.5];
evals = 1; %[1, 4];
%avals = [0, 0.25, 0.5, 0.75, 1];
%evals = [1, 2, 3, 4, 8, 12, 16];
%evals = [1, 2, 4, 8, 16]; % This will be 4*5 + 1 = 21 combinations in the grid

inputdir = 'data/preprocessing/2015-03-11';
outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd'), '/vox', num2str(voxNum)];
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
        [imAll, imFileName, imNumsLoad] = loadOneDivnormIm(inputdir, r, s, a, e);

        %% Set up a results struct
        results.voxNums = voxNums;
        results.dataset = datasetNum;
        results.modelfun = 'get_socmodel_original(90)';
        results.inputImages = fullfile(inputdir, imFileName);
        results.r = r;
        results.s = s;
        results.a = a;
        results.e = e;
        results.foldImNums = foldImNums;
        results.foldResults = struct([]); % struct arrays ftw
        
        % Added later, retroactively supplied in existing data:
        results.imNumsDataset = imNumsDataset;
        results.catToUse = catToUse;
        results.datasetIdxToUse = datasetIdxToUse;
        results.imNumsToUse = imNumsToUse;
        results.betamnToUse = betamn(voxNums, datasetIdxToUse);
        
        %% Run all 10 folds of this a/e
        for fold = 1:nFolds
            allFolds = 1:nFolds;
            trainFolds = allFolds ~= fold;
            imNumsTrain = [foldImNums{trainFolds}];
            imNumsTest = foldImNums{fold};
            
            imTrain = imAll(convertIndex(imNumsLoad, imNumsTrain), :, :);
            imTest = imAll(convertIndex(imNumsLoad, imNumsTest), :, :);
            
            betamnTrain = betamn(voxNums, convertIndex(imNumsDataset, imNumsTrain));
            betamnTest = betamn(voxNums, convertIndex(imNumsDataset, imNumsTest));
            
            tempResults = modelfittingContrastIm(modelfun, betamnTrain, imTrain);
            results.foldResults(fold).params = tempResults.params;
            results.foldResults(fold).foldNumber = fold;
            results.foldResults(fold).imNumsTrain = imNumsTrain;
            results.foldResults(fold).imNumsTest = imNumsTest;
            
            predictions = predictResponses(imTest, results.foldResults(fold).params, modelfun);
            useThisMean = mean(betamnToUse);    
            [r2test, ~, ss_res, ss_tot] = computeR2(predictions, betamnTest, useThisMean);
            
            results.foldResults(fold).predictions = predictions;
            results.foldResults(fold).r2test = r2test;
            results.foldResults(fold).ss_res = ss_res;
            results.foldResults(fold).ss_tot = ss_tot;
        end
        
        %% Concatenate the cross-validated results (and get a *useful* R2!)
        results.concatPredictions = zeros(length(betamnToUse));
        for fold = 1:nFolds
            imNumsTest = foldImNums{fold};
            results.concatPredictions(convertIndex(imNumsToUse, imNumsTest)) = results.foldResults(fold).predictions;
        end
        results.concatR2 = computeR2(results.concatPredictions, betamnToUse);
        
        %% Here's another way that I hope computes the same thing
        accumSSres = 0;
        accumSStot = 0;
        for fold = 1:nFolds
            accumSSres = accumSSres + results.foldResults(fold).ss_res;
            accumSStot = accumSStot + results.foldResults(fold).ss_tot;
        end
        results.accumR2 = 1 - accumSSres / accumSStot;
        
        %% Save every a and e with its model fit and x-val R^2
        save(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), ...
        'results');
    end
end

end % end function

