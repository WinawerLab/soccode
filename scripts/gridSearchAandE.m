%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Leave-out-out cross-validation for a given A and E
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gridSearchAandE(voxNum)
%% Dataset
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

%% Choose good voxels
betaSse = sum(betase, 2);
[y,voxNums] = sort(betaSse);

bestV1 = find(strcmp(roilabels(roi(voxNums)), 'V1')); % ugh, "find" has unsorted them
bestV2 = find(strcmp(roilabels(roi(voxNums)), 'V2'));
bestV3 = find(strcmp(roilabels(roi(voxNums)), 'V3'));

v1VoxNums = bestV1(11:20);
v2VoxNums = bestV2(11:20);
v3VoxNums = bestV3(11:20);
voxNums = [v1VoxNums, v2VoxNums, v3VoxNums]; % 30 voxels per brain

% DATASET 3:
% Best 10 voxels per area:
% voxNums = [31,42,59,71,72,77,81,83,89,90,10,19,22,29,30,33,35,36,38,47,1,3,7,8,9,12,15,16,18,20]
% Next best 10 per area:
% voxNums = [94,104,115,116,122,125,131,142,143,148,57,60,62,65,68,69,73,76,78,79,24,25,26,28,32,34,37,40,41,43]
%voxNums = 31; % For testing purposes

% DATASET 4:
% Best 10:
% voxNums = [8,47,69,89,101,140,167,181,182,184,15,40,56,106,112,117,131,142,178,180,9,29,41,45,51,65,84,86,88,91]
% Next best 10:
% voxNums = [185,207,215,217,220,243,248,257,279,281,191,193,212,213,226,245,250,251,256,266,95,103,104,107,120,128,138,141,144,157]

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

