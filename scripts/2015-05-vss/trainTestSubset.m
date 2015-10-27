%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exploration: Leaving out parts of the data in train vs. test:
%   - Leaving out certain classes
%   - k-fold cross-validation
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Choose a subset of images
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')

imNumsDataset = 70:225;

% Training/testing set imnums:
catTrain = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast'}; % omit naturalistic, gratings/patterns, and noise space/halves
imIdxTrain = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catTrain), imNumsDataset);
imNumsTrain = imNumsDataset(imIdxTrain);

catSparse = {'grating_sparse', 'pattern_sparse'}; % sparse gratings/patterns
imIdxSparse = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catSparse), imNumsDataset);
imNumsSparse = imNumsDataset(imIdxSparse);

catNat = {'non_geometric_small', 'scenes'}; % naturalistic
imIdxNat = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catNat), imNumsDataset);
imNumsNat = imNumsDataset(imIdxNat);

%% Acquire corresponding betamn
betamnIdxTrain = convertIndex(imNumsDataset, imNumsTrain);
betamnIdxSparse = convertIndex(imNumsDataset, imNumsSparse);
betamnIdxNat = convertIndex(imNumsDataset, imNumsNat);

voxNum = 78; % a V1 voxel with good SNR
betamnTrain = betamn(voxNum, betamnIdxTrain);
betamnSparse = betamn(voxNum, betamnIdxSparse);
betamnNat = betamn(voxNum, betamnIdxNat);

%% Acquire corresponding images
inputdir = 'data/preprocessing/2015-03-11';
r = 1;
s = 0.5;
a = 0;
e = 1;
[imAll, imFileName] = loadOneDivnormIm(inputdir, r, s, a, e);
imTrain = imAll(imIdxTrain, :, :);
imSparse = imAll(imIdxSparse, :, :);
imNat = imAll(imIdxNat, :, :);

%% Acquire the desired modelfun
modelfun = get_socmodel_original(90);

%% TRAINING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];
if ~exist(fullfile(rootpath, outputdir), 'dir')
    mkdir(fullfile(rootpath, outputdir));
end
    
% Fit the modelfun!
% results = modelfittingContrastIm(modelfun, betamnTrain, imTrain);
% results = modelfittingContrastIm(modelfun, [betamnTrain, betamnSparse], [imTrain; imSparse]);
results = modelfittingContrastIm(modelfun, [betamnTrain, betamnSparse, betamnNat], [imTrain; imSparse; imNat]);

results.voxNums = voxNum;
results.dataset = datasetNum;
results.voxNums = voxNum;
results.imNumsTrain = imNumsTrain; % Record what the fold was!
results.modelfun = 'get_socmodel_original(90)';
results.inputImages = fullfile(inputdir, imFileName);
results.r = r;
results.s = s;
results.a = a;
results.e = e;

save(fullfile(rootpath, outputdir, ...
    ['traintestsubset-results-trr-full-subj', ...
    num2str(datasetNum), '-vox', num2str(voxNum), '.mat']), 'results');
%    ['traintestsubset-results-omitnat-keepsparse-subj', ...
%    ['traintestsubset-results-omitnat-omitsparse-subj', ...

outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];
if ~exist(fullfile(rootpath, outputdir), 'dir')
    mkdir(fullfile(rootpath, outputdir));
end
    
% Fit the modelfun!
% results = modelfittingContrastIm(modelfun, betamnTrain, imTrain);
results = modelfittingContrastIm(modelfun, [betamnTrain, betamnSparse], [imTrain; imSparse]);
% results = modelfittingContrastIm(modelfun, [betamnTrain, betamnSparse, betamnNat], [imTrain; imSparse; imNat]);

results.voxNums = voxNum;
results.dataset = datasetNum;
results.voxNums = voxNum;
results.imNumsTrain = imNumsTrain; % Record what the fold was!
results.modelfun = 'get_socmodel_original(90)';
results.inputImages = fullfile(inputdir, imFileName);
results.r = r;
results.s = s;
results.a = a;
results.e = e;

save(fullfile(rootpath, outputdir, ...
    ['traintestsubset-results-trr-omitnat-keepsparse-subj', ...
    num2str(datasetNum), '-vox', num2str(voxNum), '.mat']), 'results');
outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];
if ~exist(fullfile(rootpath, outputdir), 'dir')
    mkdir(fullfile(rootpath, outputdir));
end
    
% Fit the modelfun!
results = modelfittingContrastIm(modelfun, betamnTrain, imTrain);
% results = modelfittingContrastIm(modelfun, [betamnTrain, betamnSparse], [imTrain; imSparse]);
% results = modelfittingContrastIm(modelfun, [betamnTrain, betamnSparse, betamnNat], [imTrain; imSparse; imNat]);

results.voxNums = voxNum;
results.dataset = datasetNum;
results.voxNums = voxNum;
results.imNumsTrain = imNumsTrain; % Record what the fold was!
results.modelfun = 'get_socmodel_original(90)';
results.inputImages = fullfile(inputdir, imFileName);
results.r = r;
results.s = s;
results.a = a;
results.e = e;

save(fullfile(rootpath, outputdir, ...
    ['traintestsubset-results-trr-omitnat-omitsparse-subj', ...
    num2str(datasetNum), '-vox', num2str(voxNum), '.mat']), 'results');

%% ANALYZE AND COMPARE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load existing fits and test

optmethod = 'trr-'; % 'trr-', or '' for levenberg-marquardt

load(fullfile(rootpath, 'data', 'modelfits', '2015-05-02', ...
    ['traintestsubset-results-', optmethod, 'omitnat-omitsparse-subj', num2str(datasetNum), '-vox', num2str(voxNum), '.mat']));
results_omitnatomitsparse = results;

load(fullfile(rootpath, 'data', 'modelfits', '2015-05-02', ...
    ['traintestsubset-results-', optmethod, 'omitnat-keepsparse-subj', num2str(datasetNum), '-vox', num2str(voxNum), '.mat']));
results_omitnatkeepsparse = results;

load(fullfile(rootpath, 'data', 'modelfits', '2015-05-02', ...
    ['traintestsubset-results-', optmethod, 'full-subj', num2str(datasetNum), '-vox', num2str(voxNum), '.mat']));
results_full = results;

predictions_omitnatomitsparse = predictResponses([imTrain; imSparse; imNat], results_omitnatomitsparse.params, modelfun);
predictions_omitnatomitsparse_sparse = predictResponses(imSparse, results_omitnatomitsparse.params, modelfun);

predictions_omitnatkeepsparse = predictResponses([imTrain; imSparse; imNat], results_omitnatkeepsparse.params, modelfun);
predictions_omitnatkeepsparse_nat = predictResponses(imNat, results_omitnatkeepsparse.params, modelfun);

predictions_full = predictResponses([imTrain; imSparse; imNat], results_full.params, modelfun);
predictions_full_nat = predictResponses(imNat, results_full.params, modelfun);
predictions_full_sparse = predictResponses(imSparse, results_full.params, modelfun);

[r2_omitnatkeepsparse, ~] = computeR2(predictions_omitnatkeepsparse, [betamnTrain, betamnSparse, betamnNat]);
[r2_omitnatkeepsparse_nat, ~] = computeR2(predictions_omitnatkeepsparse_nat, betamnNat);

[r2_omitnatomitsparse, ~] = computeR2(predictions_omitnatomitsparse, [betamnTrain, betamnSparse, betamnNat]);
[r2_omitnatomitsparse_sparse, ~] = computeR2(predictions_omitnatomitsparse_sparse, betamnSparse);

[r2_full, ~] = computeR2(predictions_full, [betamnTrain, betamnSparse, betamnNat]);
[r2_full_nat, ~] = computeR2(predictions_full_nat, betamnNat);
[r2_full_sparse, ~] = computeR2(predictions_full_sparse, betamnSparse);

%% 
display(results_omitnatomitsparse.params)
display(results_omitnatkeepsparse.params)
display(results_full.params)

%%
display(r2_omitnatomitsparse)
display(r2_omitnatkeepsparse)
display(r2_full)

%%
figure; hold on;
bar([betamnTrain, betamnSparse, betamnNat]);
plot(predictions_full, 'ro')
plot(predictions_omitnatkeepsparse, 'go')
plot(predictions_omitnatomitsparse, 'co')

sparsePlotIdx = convertIndex([imNumsTrain, imNumsSparse, imNumsNat], imNumsSparse);
plot(sparsePlotIdx, zeros(length(sparsePlotIdx)), 'mx');

natPlotIdx = convertIndex([imNumsTrain, imNumsSparse, imNumsNat], imNumsNat);
plot(natPlotIdx, zeros(length(natPlotIdx)), 'yx');

legend('', 'Full', '+ sparse, - naturalistic', '- sparse, - naturalistic', 'sparse', 'naturalistic');
