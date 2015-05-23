%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% VSS Analysis, all in one place! Easy to run, easy to find! %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading the data!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create figs directory
figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% fMRI - which images
imNumsDataset = 70:225;
catToUse = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', ... % skip naturalistic ...
           'grating_sparse', 'pattern_sparse'}; % skip noise space/halves

load(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames');
       
imIdxToUse = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catToUse), imNumsDataset);
imNumsToUse = imNumsDataset(imIdxToUse);

%% fMRI - betamn, both datasets
betaIdxToUse = convertIndex(imNumsDataset, imNumsToUse);

datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
betamnToUse_3 = betamn(:, betaIdxToUse);
betaseToUse_3 = betase(:, betaIdxToUse);
betamn_3 = betamn;
betase_3 = betase;
roi_3 = roi;
roilabels_3 = roilabels;

datasetNum = 4;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
betamn_4 = betamn;
betase_4 = betase;
betamnToUse_4 = betamn(:, betaIdxToUse);
betaseToUse_4 = betase(:, betaIdxToUse);
roi_4 = roi;
roilabels_4 = roilabels;

clear('betamn', 'betase', 'roi', 'roilabels')

%% Which voxels are of interest:
% DATASET 3
v1Vox_3 = find(strcmp(roilabels_3(roi_3), 'V1'));
v2Vox_3 = find(strcmp(roilabels_3(roi_3), 'V2'));
v3Vox_3 = find(strcmp(roilabels_3(roi_3), 'V3'));

betaSse_3 = sum(betase_3, 2);
[y,bestV1idx_3] = sort(betaSse_3(v1Vox_3));
[y,bestV2idx_3] = sort(betaSse_3(v2Vox_3));
[y,bestV3idx_3] = sort(betaSse_3(v3Vox_3));

% Subj 3 batch 1:
v1VoxNums1_3 = v1Vox_3(bestV1idx_3(1:10));
v2VoxNums1_3 = v2Vox_3(bestV2idx_3(1:10));
v3VoxNums1_3 = v3Vox_3(bestV3idx_3(1:10));
% [509,198,181,83,97,183,353,82,339,359,367,366,518,210,310,227,779,459,786,111,959,851,953,859,861,949,781,965,694,856];

% Subj 3 batch 2 - NOT RUN GRIDSEARCH YET as of 5/8
v1VoxNums2_3 = v1Vox_3(bestV1idx_3(11:20));
v2VoxNums2_3 = v2Vox_3(bestV2idx_3(11:20));
v3VoxNums2_3 = v3Vox_3(bestV3idx_3(11:20));
% [318,327,317,302,308,319,188,834,297,40,221,239,791,784,499,206,118,668,585,801,917,857,957,852,1043,1045,701,756,669,761];

% DATASET 4
v1Vox_4 = find(strcmp(roilabels_4(roi_4), 'V1'));
v2Vox_4 = find(strcmp(roilabels_4(roi_4), 'V2'));
v3Vox_4 = find(strcmp(roilabels_4(roi_4), 'V3'));

betaSse_4 = sum(betase_4, 2);
[y,bestV1idx_4] = sort(betaSse_4(v1Vox_4));
[y,bestV2idx_4] = sort(betaSse_4(v2Vox_4));
[y,bestV3idx_4] = sort(betaSse_4(v3Vox_4));

% Subj 4 batch 1:
v1VoxNums1_4 = v1Vox_4(bestV1idx_4(1:10));
v2VoxNums1_4 = v2Vox_4(bestV2idx_4(1:10));
v3VoxNums1_4 = v3Vox_4(bestV3idx_4(1:10));
% [167,44,100,308,172,17,171,84,101,16,94,200,619,190,105,204,191,309,274,746,205,954,390,106,315,797,795,389,327,482];

% Subj 4 batch 2:
v1VoxNums2_4 = v1Vox_4(bestV1idx_4(11:20));
v2VoxNums2_4 = v2Vox_4(bestV2idx_4(11:20));
v3VoxNums2_4 = v3Vox_4(bestV3idx_4(11:20));
% [77,71,92,86,58,67,78,179,469,40,90,243,472,152,322,473,566,254,457,314,196,567,201,747,561,754,198,99,924,203];

%% ECoG - which images
load(fullfile(rootpath, 'code', 'visualization', 'stimuliNamesEcog.mat'), 'stimuliNamesEcog');
imIdxToUseEcog = find(arrayfun(@(idx) strInCellArray(stimuliNamesEcog{idx}, catToUse), 1:length(stimuliNamesEcog)));

%% ECoG - electrode data, one dataset
electrodes = [108 109 115 120 121 107];

[ecog_vals, ecog_errs] = loadEcogBroadband(electrodes);
ecogValsToUse = ecog_vals(:, imIdxToUseEcog);
ecogErrsToUse = ecog_errs(:, imIdxToUseEcog, :);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example voxel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exV1idx = 7; % aka 353

setupBetaFig;
bar(betamnToUse_3(v1VoxNums1_3(exV1idx), :));
%addXlabels(imNumsToUse, stimuliNames);
errorbar(1:108, betamnToUse_3(v1VoxNums1_3(exV1idx), :), betaseToUse_3(v1VoxNums1_3(exV1idx), :), '.');

% TODO: no, should be leaveoneout!!
% load(fullfile(rootpath, 'data', 'modelfits', '2015-05-12', 'subj3-vox353', 'xval-a0-e1-subj3-nfolds10.mat'), 'results');

load(fullfile(rootpath, 'data', 'modelfits', '2015-05-13', 'subj3-vox353', 'xval-a0-e1-subj3-nfolds108.mat'), 'results');
resultsOld = results;
plot(resultsOld.concatPredictions(1:108), 'r.-');
disp(computeR2(resultsOld.concatPredictions, betamnToUse_3(v1VoxNums1_3(exV1idx), :)));

load(fullfile(rootpath, 'data', 'modelfits', '2015-05-13', 'subj3-vox353', 'xval-a0.75-e8-subj3-nfolds108.mat'), 'results');
resultsNew = results;
plot(resultsNew.concatPredictions(1:108), 'g.-');
disp(computeR2(resultsNew.concatPredictions, betamnToUse_3(v1VoxNums1_3(exV1idx), :)));

drawPublishAxis;
hgexport(gcf,fullfile(figDir, ['bars_exampleV1vox_data.eps']));

%% Zoom in to the classes in question
figure; hold on;
bar(betamnToUse_3(v1VoxNums1_3(exV1idx), convertIndex(imNumsToUse, imNumsCat)));
errorbar(1:length(imNumsCat), betamnToUse_3(v1VoxNums1_3(exV1idx), convertIndex(imNumsToUse, imNumsCat)), ...
    betaseToUse_3(v1VoxNums1_3(exV1idx), convertIndex(imNumsToUse, imNumsCat)), '.');

plot(1:5, resultsOld.concatPredictions(convertIndex(imNumsToUse, imNumsCat(1:5))), 'r.-');
plot(6:10, resultsOld.concatPredictions(convertIndex(imNumsToUse, imNumsCat(6:10))), 'r.-');

plot(1:5, resultsNew.concatPredictions(convertIndex(imNumsToUse, imNumsCat(1:5))), 'g.-');
plot(6:10, resultsNew.concatPredictions(convertIndex(imNumsToUse, imNumsCat(6:10))), 'g.-');

drawPublishAxis;
hgexport(gcf,fullfile(figDir, ['bars_exampleV1vox_categories.eps']));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Images out to EPS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imNumsCat = [176, 177, 178, 179, 180, 181, 182, 183, 85, 184];
imStackCat = loadImages(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), imNumsCat);

%%
figure;
for ii = 1:length(imNumsCat)
    for f = 1:9
        imshow(imStackCat(:, :, ii, f), [0, 255]);
        hgexport(gcf,fullfile(figDir, ['im_', num2str(imNumsCat(ii)), '_frame_', num2str(f), '.eps']));
    end
end

%%
load(fullfile(rootpath, 'data', 'input', 'stimuli_2015_04_06.mat'), 'stimuli');
figure;
for ii = 1:size(stimuli.imStack, 3)
    for f = 1:size(stimuli.imStack, 4)
        disp(ii)
        disp(f)
        imshow(stimuli.imStack(:, :, ii, f), [0, 255]);
        hgexport(gcf,fullfile(figDir, ['imApr_', num2str(ii), '_frame_', num2str(f), '.eps']));
    end
end

%%
load(fullfile(rootpath, 'data', 'input', 'stimuli_2015_04_06.mat'), 'stimuli');
figure;
for ii = 1:size(stimuli.imStack, 3)
    for f = 1:size(stimuli.imStack, 4)
        disp(ii)
        disp(f)
        imshow(stimuli.imStack(300:500, 300:500, ii, f), [0, 255]);
        hgexport(gcf,fullfile(figDir, ['thumbApr_', num2str(ii), '_frame_', num2str(f), '.eps']));
    end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Red bars, blue bars - data!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DATASET 3
voxels = betamnToUse_3([v1VoxNums1_3, v1VoxNums2_3], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V1 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj3_V1.eps'));

voxels = betamnToUse_3([v2VoxNums1_3, v2VoxNums2_3], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V2 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj3_V2.eps'));

voxels = betamnToUse_3([v3VoxNums1_3, v3VoxNums2_3], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V3 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj3_V3.eps'));

voxels = betamnToUse_3([v1VoxNums1_3, v1VoxNums2_3, v2VoxNums1_3, v2VoxNums2_3, v3VoxNums1_3, v3VoxNums2_3], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V1+V2+V3 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj3_V123.eps'));

%% DATASET 4
voxels = betamnToUse_4([v1VoxNums1_4, v1VoxNums2_4], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V1 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj4_V1.eps'));

voxels = betamnToUse_4([v2VoxNums1_4, v2VoxNums2_4], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V2 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj4_V2.eps'));

voxels = betamnToUse_4([v3VoxNums1_4, v3VoxNums2_4], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V3 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj4_V3.eps'));

voxels = betamnToUse_4([v1VoxNums1_4, v1VoxNums2_4, v2VoxNums1_4, v2VoxNums2_4, v3VoxNums1_4, v3VoxNums2_4], convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V1+V2+V3 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_subj4_V123.eps'));

%% ECOG
imIdxCatEcog = [69, 70, 71, 72, 73, 74, 75, 76, 77, 78];
channels = ecogValsToUse(:, convertIndex(imIdxToUseEcog, imIdxCatEcog));
figure; hold on;
bar([mean(channels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(channels(:, 6:10), 1)], 'b');
ylim([0, 1]);
title('ECoG data, all channels')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_data_ecog_allchannels.eps'));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Red bars, blue bars - predictions!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

aOld = 0;
eOld = 1;

aNew = 0.75;
eNew = 8;

dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');


%% Dataset 3!
datasetNum = 3;
voxNums = [v1VoxNums1_3, v2VoxNums1_3, v3VoxNums1_3];
predictionsOld1_3 = zeros(length(voxNums), size(betamnToUse_3, 2));
predictionsNew1_3 = zeros(length(voxNums), size(betamnToUse_3, 2));

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

    filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    predictionsOld1_3(voxIdx, :) = results.concatPredictions;
    
    filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    predictionsNew1_3(voxIdx, :) = results.concatPredictions;
end


voxels = predictionsOld1_3(1:10, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V1 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj3_V1.eps'));

voxels = predictionsOld1_3(11:20, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V2 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj3_V2.eps'));

voxels = predictionsOld1_3(21:30, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V3 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj3_V3.eps'));

voxels = predictionsOld1_3(:, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V1+V2+V3 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj3_V123.eps'));

voxels = predictionsNew1_3(1:10, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V1 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj3_V1.eps'));

voxels = predictionsNew1_3(11:20, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V2 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj3_V2.eps'));

voxels = predictionsNew1_3(21:30, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V3 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj3_V3.eps'));

voxels = predictionsNew1_3(:, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 3, V1+V2+V3 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj3_V123.eps'));



%% DATASET 4!

datasetNum = 4;
voxNums = [v1VoxNums1_4, v2VoxNums1_4, v3VoxNums1_4];
predictionsOld1_4 = zeros(length(voxNums), size(betamnToUse_4, 2));
predictionsNew1_4 = zeros(length(voxNums), size(betamnToUse_4, 2));

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);  
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

    try
    filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    predictionsOld1_4(voxIdx, :) = results.concatPredictions;
    
    filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    predictionsNew1_4(voxIdx, :) = results.concatPredictions;
    catch
        disp('oops, one of the files was not found')
    end
end

voxels = predictionsOld1_4(1:10, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V1 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj4_V1.eps'));

voxels = predictionsOld1_4(11:20, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V2 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj4_V2.eps'));

voxels = predictionsOld1_4(21:30, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V3 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj4_V3.eps'));

voxels = predictionsOld1_4(:, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V1+V2+V3 voxel OLD predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_SOCpred_subj4_V123.eps'));

voxels = predictionsNew1_4(1:10, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V1 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj4_V1.eps'));

voxels = predictionsNew1_4(11:20, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V2 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj4_V2.eps'));

voxels = predictionsNew1_4(21:30, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V3 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj4_V3.eps'));

voxels = predictionsNew1_4(:, convertIndex(imNumsToUse, imNumsCat));
figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
ylim([-0.5, 2]);
title('Dataset 4, V1+V2+V3 voxel NEW predictions')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_OTSpred_subj4_V123.eps'));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Red bars, blue bars - both data AND predictions!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DATASET 3
% V1
voxels = betamnToUse_3(v1VoxNums1_3, convertIndex(imNumsToUse, imNumsCat));
preds = predictionsOld1_3(1:10, convertIndex(imNumsToUse, imNumsCat));
semvox = sqrt(var(voxels, 1)) ./ sqrt(size(voxels, 2));
sempreds = sqrt(var(preds, 1)) ./ sqrt(size(preds, 2));

figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
errorbar(1:10, mean(voxels, 1), semvox, 'c.');

plot(1:5, mean(preds(:,1:5), 1), 'g.-');
plot(6:10, mean(preds(:,6:10), 1), 'g.-');
%errorbar(1:5, mean(preds(:,1:5), 1), sempreds(1:5), 'g.-')
%errorbar(6:10, mean(preds(:,6:10), 1), sempreds(6:10), 'g.-')

ylim([-0.5, 2]);
title('Dataset 3, V1 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_dataPlusSOC_subj3_V1.eps'));

% V2
voxels = betamnToUse_3(v2VoxNums1_3, convertIndex(imNumsToUse, imNumsCat));
preds = predictionsOld1_3(11:20, convertIndex(imNumsToUse, imNumsCat));
semvox = sqrt(var(voxels, 1)) ./ sqrt(size(voxels, 2));
sempreds = sqrt(var(preds, 1)) ./ sqrt(size(preds, 2));

figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
errorbar(1:10, mean(voxels, 1), semvox, 'c.');

plot(1:5, mean(preds(:,1:5), 1), 'g.-');
plot(6:10, mean(preds(:,6:10), 1), 'g.-');
%errorbar(1:5, mean(preds(:,1:5), 1), sempreds(1:5), 'g.-')
%errorbar(6:10, mean(preds(:,6:10), 1), sempreds(6:10), 'g.-')

ylim([-0.5, 2]);
title('Dataset 3, V2 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_dataPlusSOC_subj3_V2.eps'));

% V3
voxels = betamnToUse_3(v3VoxNums1_3, convertIndex(imNumsToUse, imNumsCat));
preds = predictionsOld1_3(21:30, convertIndex(imNumsToUse, imNumsCat));
semvox = sqrt(var(voxels, 1)) ./ sqrt(size(voxels, 2));
sempreds = sqrt(var(preds, 1)) ./ sqrt(size(preds, 2));

figure; hold on;
bar([mean(voxels(:, 1:5), 1), zeros(1, 5)], 'r');
bar([zeros(1,5), mean(voxels(:, 6:10), 1)], 'b');
errorbar(1:10, mean(voxels, 1), semvox, 'c.');

plot(1:5, mean(preds(:,1:5), 1), 'g.-');
plot(6:10, mean(preds(:,6:10), 1), 'g.-');
%errorbar(1:5, mean(preds(:,1:5), 1), sempreds(1:5), 'g.-')
%errorbar(6:10, mean(preds(:,6:10), 1), sempreds(6:10), 'g.-')

ylim([-0.5, 2]);
title('Dataset 3, V3 voxel data')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'redblue_dataPlusSOC_subj3_V3.eps'));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Every-image summary of real, predictions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dataset 3
setupBetaFig;
bar(mean(betamnToUse_3(v1VoxNums1_3, :), 1));
plot(mean(predictionsOld1_3(1:10, :), 1), 'ro');
plot(mean(predictionsNew1_3(1:10, :), 1), 'go');
addXlabels(imNumsToUse, stimuliNames, false);
title('V1, dataset 3')
legend('Data', 'Old model', 'New model')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'bar_dataVsModel_subj3_V1.eps'));

setupBetaFig;
bar(mean(betamnToUse_3(v2VoxNums1_3, :), 1));
plot(mean(predictionsOld1_3(11:20, :), 1), 'ro');
plot(mean(predictionsNew1_3(11:20, :), 1), 'go');
addXlabels(imNumsToUse, stimuliNames);
title('V2, dataset 3')
legend('Data', 'Old model', 'New model')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'bar_dataVsModel_subj3_V2.eps'));

setupBetaFig;
bar(mean(betamnToUse_3(v3VoxNums1_3, :), 1));
plot(mean(predictionsOld1_3(21:30, :), 1), 'ro');
plot(mean(predictionsNew1_3(21:30, :), 1), 'go');
addXlabels(imNumsToUse, stimuliNames);
title('V3, dataset 3')
legend('Data', 'Old model', 'New model')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'bar_dataVsModel_subj3_V3.eps'));

%% Dataset 4
setupBetaFig;
bar(mean(betamnToUse_4(v1VoxNums1_4, :), 1));
plot(mean(predictionsOld1_4(1:10, :), 1), 'ro');
plot(mean(predictionsNew1_4(1:10, :), 1), 'go');
addXlabels(imNumsToUse, stimuliNames);
title('V1, dataset 4')
legend('Data', 'Old model', 'New model')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'bar_dataVsModel_subj4_V1.eps'));

setupBetaFig;
bar(mean(betamnToUse_4(v2VoxNums1_4, :), 1));
plot(mean(predictionsOld1_4(11:20, :), 1), 'ro');
plot(mean(predictionsNew1_4(11:20, :), 1), 'go');
addXlabels(imNumsToUse, stimuliNames);
title('V2, dataset 4')
legend('Data', 'Old model', 'New model')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'bar_dataVsModel_subj4_V2.eps'));

setupBetaFig;
bar(mean(betamnToUse_4(v3VoxNums1_4, :), 1));
plot(mean(predictionsOld1_4(21:30, :), 1), 'ro');
plot(mean(predictionsNew1_4(21:30, :), 1), 'go');
addXlabels(imNumsToUse, stimuliNames);
title('V3, dataset 4')
legend('Data', 'Old model', 'New model')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'bar_dataVsModel_subj4_V3.eps'));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New stimuli! Woo! 2015-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 1;
s = 0.5;
inputDir = fullfile('data', 'preprocessing', '2015-05-09');

inputFile = ['newstimuli_r', strrep(num2str(r), '.', 'pt'),...
                    '_s', strrep(num2str(s), '.', 'pt'),...
                    '_a', strrep(num2str(aOld), '.', 'pt'),...
                    '_e', strrep(num2str(eOld), '.', 'pt'), '.mat'];
load(fullfile(rootpath, inputDir, inputFile), 'preprocess');

imStack = flatToStack(preprocess.contrast, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

modelfun = get_socmodel_original(90);


% Reuse the old model fits for the new predictions
datasetNum = 4;
voxNums = [v1VoxNums1_4, v2VoxNums1_4, v3VoxNums1_4];
predictionsAprOld1_4 = NaN*ones(length(voxNums), size(imToUse, 1));
predictionsAprNew1_4 = NaN*ones(length(voxNums), size(imToUse, 1));

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);  
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

    % Old
    try
        filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
        load(fullfile(dataloc, folder, filename), 'results');
    catch
        disp('oops, one of the files was not found')
        continue;
    end
    
    predictions = zeros(length(results.foldImNums), size(imToUse, 1));    
    for fold = 1:length(results.foldImNums)
        params = results.foldResults(fold).params;
        predictions(fold, :) = predictResponses(imToUse, params, modelfun);
    end
    predictionsAprOld1_4(voxIdx, :) = mean(predictions, 1);
    
    % New
    try
        filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
        load(fullfile(dataloc, folder, filename), 'results');
    catch
        disp('oops, one of the files was not found')
        continue;
    end
    
    predictions = zeros(length(results.foldImNums), size(imToUse, 1));    
    for fold = 1:length(results.foldImNums)
        params = results.foldResults(fold).params;
        predictions(fold, :) = predictResponses(imToUse, params, modelfun);
    end
    predictionsAprNew1_4(voxIdx, :) = mean(predictions, 1);
end

%% Plot the predictions - NEW model
figure; hold on;
bar([nanmean(predictionsAprNew1_4(1:10, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), nanmean(predictionsAprNew1_4(1:10, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), nanmean(predictionsAprNew1_4(1:10, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), nanmean(predictionsAprNew1_4(1:10, 10:12), 1)], 'c');
ylim([0, 2]);
title('V1')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_OTSpred_V1.eps'));

figure; hold on;
plot(1:3, mean(predictionsAprNew1_4(11:20, 1:3), 1), 'b.-');
plot(4:6, mean(predictionsAprNew1_4(11:20, 4:6), 1), 'g.-');
plot(7:9, mean(predictionsAprNew1_4(11:20, 7:9), 1), 'r.-');
plot(10:12, mean(predictionsAprNew1_4(11:20, 10:12), 1), 'c.-');
ylim([0, 2]);
title('V2')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_OTSpred_V2.eps'));

figure; hold on;
bar([mean(predictionsAprNew1_4(21:30, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), mean(predictionsAprNew1_4(21:30, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), mean(predictionsAprNew1_4(21:30, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), mean(predictionsAprNew1_4(21:30, 10:12), 1)], 'c');
ylim([0, 2]);
title('V3')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_OTSpred_V3.eps'));

figure; hold on;
bar([nanmean(predictionsAprNew1_4(:, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), nanmean(predictionsAprNew1_4(:, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), nanmean(predictionsAprNew1_4(:, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), nanmean(predictionsAprNew1_4(:, 10:12), 1)], 'c');
ylim([0, 2]);
title('V1+V2+V3')
hgexport(gcf,fullfile(figDir, 'aprData_OTSpred_V123.eps'));

%% Plot the predictions - OLD model
figure; hold on;
bar([nanmean(predictionsAprOld1_4(1:10, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), nanmean(predictionsAprOld1_4(1:10, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), nanmean(predictionsAprOld1_4(1:10, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), nanmean(predictionsAprOld1_4(1:10, 10:12), 1)], 'c');
ylim([0, 2]);
title('V1')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_SOCpred_V1.eps'));

figure; hold on;
bar([mean(predictionsAprOld1_4(11:20, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), mean(predictionsAprOld1_4(11:20, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), mean(predictionsAprOld1_4(11:20, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), mean(predictionsAprOld1_4(11:20, 10:12), 1)], 'c');
ylim([0, 2]);
title('V2')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_SOCpred_V2.eps'));

figure; hold on;
bar([mean(predictionsAprOld1_4(21:30, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), mean(predictionsAprOld1_4(21:30, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), mean(predictionsAprOld1_4(21:30, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), mean(predictionsAprOld1_4(21:30, 10:12), 1)], 'c');
ylim([0, 2]);
title('V3')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_SOCpred_V3.eps'));

figure; hold on;
bar([nanmean(predictionsAprOld1_4(:, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), nanmean(predictionsAprOld1_4(:, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), nanmean(predictionsAprOld1_4(:, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), nanmean(predictionsAprOld1_4(:, 10:12), 1)], 'c');
ylim([0, 2]);
title('V1+V2+V3')
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'aprData_SOCpred_V123.eps'));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% View the ECoG images

ims = load(fullfile(rootpath, 'data', 'input', 'ecog_datasets', 'socforecog.mat'));

figure;
for ii = 69:78
    imshow(ims.stimuli(:,:,ii));
    title(ii);
    pause(0.5);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Overall R2s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Subject 3
datasetNum = 3;
voxNums = [v1VoxNums1_3, v2VoxNums1_3, v3VoxNums1_3];
r2old = zeros(1, length(voxNums));
r2new = zeros(1, length(voxNums));
for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

    filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    r2old(voxIdx) = results.accumR2;
    
    filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    r2new(voxIdx) = results.accumR2;
end

%%
figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(r2old(r2old > r2new), r2new(r2old > r2new), 'r.');
plot(r2old(r2old <= r2new), r2new(r2old <= r2new), 'g.');
xlabel('Original'); ylabel('New');
title('V1, V2, V3 model fit improvement, dataset3');
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'r2scatter_subj3_V123_origin.eps'));

%% Subject 4
datasetNum = 4;
voxNums = [v1VoxNums1_4, v2VoxNums1_4, v3VoxNums1_4];
voxNums(voxNums == 100) = []; % known missing
r2old = zeros(1, length(voxNums));
r2new = zeros(1, length(voxNums));
for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

    filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    r2old(voxIdx) = results.accumR2;
    
    filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
    load(fullfile(dataloc, folder, filename), 'results');    
    r2new(voxIdx) = results.accumR2;
end

%%
figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(r2old(r2old > r2new), r2new(r2old > r2new), 'rx');
plot(r2old(r2old <= r2new), r2new(r2old <= r2new), 'gx');
xlabel('Original'); ylabel('New');
title('V1, V2, V3 model fit improvement, dataset4');
drawPublishAxis;
hgexport(gcf,fullfile(figDir, 'r2scatter_subj4_V123.eps'));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Category R2s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% DATASET 3
[categoryR2sOld, categoryPredictionsOld] = processGridSearchCategory(aOld, eOld, 3, [v1VoxNums1_3, v2VoxNums1_3, v3VoxNums1_3]);
[categoryR2sNew, categoryPredictionsNew] = processGridSearchCategory(aNew, eNew, 3, [v1VoxNums1_3, v2VoxNums1_3, v3VoxNums1_3]);

catMeansOld = mean(categoryPredictionsOld, 2);
catMeansNew = mean(categoryPredictionsNew, 2);

figure; hold on;
plot([catMeansOld(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOld(6:10)], 'bo-');

plot([catMeansNew(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNew(6:10)], 'co-');
title('Old vs. new avg');

% V1
catMeansOldV1 = mean(categoryPredictionsOld(:, 1:10), 2);
catMeansNewV1 = mean(categoryPredictionsNew(:, 1:10), 2);

figure; hold on;
plot([catMeansOldV1(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOldV1(6:10)], 'bo-');

plot([catMeansNewV1(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNewV1(6:10)], 'co-');
title('Old vs. new avg, V1 only');

% V2
catMeansOldV2 = mean(categoryPredictionsOld(:, 11:20), 2);
catMeansNewV2 = mean(categoryPredictionsNew(:, 11:20), 2);

figure; hold on;
plot([catMeansOldV2(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOldV2(6:10)], 'bo-');

plot([catMeansNewV2(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNewV2(6:10)], 'co-');
title('Old vs. new avg, V2 only');

% V3
catMeansOldV3 = mean(categoryPredictionsOld(:, 21:30), 2);
catMeansNewV3 = mean(categoryPredictionsNew(:, 21:30), 2);

figure; hold on;
plot([catMeansOldV1(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOldV1(6:10)], 'bo-');

plot([catMeansNewV3(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNewV3(6:10)], 'co-');
title('Old vs. new avg, V3 only');

%%
figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(categoryR2sOld(categoryR2sOld > categoryR2sNew), categoryR2sNew(categoryR2sOld > categoryR2sNew), 'ro');
plot(categoryR2sOld(categoryR2sOld <= categoryR2sNew), categoryR2sNew(categoryR2sOld <= categoryR2sNew), 'go');
xlabel('Original'); ylabel('New');
title(['Category-specific R^2 in subject 3', num2str(aNew), ' ', num2str(eNew)]);

%% Predictions difference
avgDiff = nanmean(categoryPredictionsNew - categoryPredictionsOld, 2);
figure; hold on;
bar([avgDiff(1:5); zeros(5,1)], 'r');
bar([zeros(5,1); avgDiff(6:10)], 'b');


%% DATASET 4    
[categoryR2sOld, categoryPredictionsOld] = processGridSearchCategory(aOld, eOld, 4, [v1VoxNums1_4, v2VoxNums1_4, v3VoxNums1_4]);
[categoryR2sNew, categoryPredictionsNew] = processGridSearchCategory(aNew, eNew, 4, [v1VoxNums1_4, v2VoxNums1_4, v3VoxNums1_4]);

catMeansOld = nanmean(categoryPredictionsOld, 2);
catMeansNew = nanmean(categoryPredictionsNew, 2);

figure; hold on;
plot([catMeansOld(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOld(6:10)], 'bo-');

plot([catMeansNew(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNew(6:10)], 'co-');
title('Old vs. new avg');

% V1
catMeansOldV1 = nanmean(categoryPredictionsOld(:, 1:10), 2);
catMeansNewV1 = nanmean(categoryPredictionsNew(:, 1:10), 2);

figure; hold on;
plot([catMeansOldV1(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOldV1(6:10)], 'bo-');

plot([catMeansNewV1(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNewV1(6:10)], 'co-');
title('Old vs. new avg, V1 only');

% V2
catMeansOldV2 = mean(categoryPredictionsOld(:, 11:20), 2);
catMeansNewV2 = mean(categoryPredictionsNew(:, 11:20), 2);

figure; hold on;
plot([catMeansOldV2(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOldV2(6:10)], 'bo-');

plot([catMeansNewV2(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNewV2(6:10)], 'co-');
title('Old vs. new avg, V2 only');

% V3
catMeansOldV3 = mean(categoryPredictionsOld(:, 21:30), 2);
catMeansNewV3 = mean(categoryPredictionsNew(:, 21:30), 2);

figure; hold on;
plot([catMeansOldV1(1:5); zeros(5,1)], 'ro-');
plot([zeros(5,1); catMeansOldV1(6:10)], 'bo-');

plot([catMeansNewV3(1:5); zeros(5,1)], 'mo-');
plot([zeros(5,1); catMeansNewV3(6:10)], 'co-');
title('Old vs. new avg, V3 only');

%%
figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(categoryR2sOld(categoryR2sOld > categoryR2sNew), categoryR2sNew(categoryR2sOld > categoryR2sNew), 'ro');
plot(categoryR2sOld(categoryR2sOld <= categoryR2sNew), categoryR2sNew(categoryR2sOld <= categoryR2sNew), 'go');
xlabel('Original'); ylabel('New');
title(['Category-specific R^2 in subject 4', num2str(aNew), ' ', num2str(eNew)]);

%% Predictions difference
avgDiff = nanmean(categoryPredictionsNew - categoryPredictionsOld, 2);
figure; hold on;
bar([avgDiff(1:5); zeros(5,1)], 'r');
bar([zeros(5,1); avgDiff(6:10)], 'b');


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Residuals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oldResiduals = processGridSearchResiduals(aOld, eOld, 3, voxNums3_1);
newResiduals = processGridSearchResiduals(aNew, eNew, 3, voxNums3_1);

setupBetaFig;
bar(nanmean(oldResiduals, 2));
addXlabels(imNumsToUse, stimuliNames);
title('Old residuals, avg')

setupBetaFig;
bar(nanmean(newResiduals, 2));
addXlabels(imNumsToUse, stimuliNames);
title('New residuals, avg')

setupBetaFig;
change = nanmean(newResiduals - oldResiduals, 2);
bar(change);
addXlabels(imNumsToUse, stimuliNames);
title('Average of difference between residuals')

betterOrWorse = bsxfun(@times, -1*sign(oldResiduals), (newResiduals - oldResiduals)); 
setupBetaFig;
bar(nanmean(betterOrWorse, 2));
addXlabels(imNumsToUse, stimuliNames);
title('Better? Or worse?')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot cross-validated predictions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-07');
voxNum = 198;
datasetNum = 3;
folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename));
oldPredictions = results.concatPredictions;

filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename));
newPredictions = results.concatPredictions;

setupBetaFig;
bar(results.betamnToUse);
plot(oldPredictions, 'ro-');
plot(newPredictions, 'go-');
addXlabels(imNumsToUse, stimuliNames);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In-category means, two models - OUTDATED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-05');
datasetNum = 3;

voxNums = [31,42,59,71,72,77,81,83,89,90,10,19,22,29,30,33,35,36,38,47,1,3,7,8,9,12,15,16,18,20];

imNumsDataset = 70:225;
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
catTrain = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', 'grating_sparse', 'pattern_sparse'}; % omit naturalistic and noise space/halves
idxTrain = find(arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catTrain), imNumsDataset));

imNumsCat = [176, 177, 178, 179, 180, 181, 182, 183, 85, 184];
idxCat = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsCat);

dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
betamnTrain = betamn(voxNums, idxTrain);
betamnCat = betamn(voxNums, idxCat);

oldPredictions = NaN*ones(length(voxNums), length(idxTrain));
newPredictions = NaN*ones(length(voxNums), length(idxTrain));

catPredictionsOld = NaN*ones(length(voxNums), length(idxCat));
catPredictionsNew = NaN*ones(length(voxNums), length(idxCat));
for voxIdx = 1:length(voxNums);
    voxNum = voxNums(voxIdx);
    folder = ['vox', num2str(voxNum)];

    filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
    try
        load(fullfile(dataloc, folder, filename));
    catch
        continue;
    end
    oldPredictions(voxIdx, :) = results.concatPredictions;

    filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
    try
        load(fullfile(dataloc, folder, filename));
    catch
        continue;
    end
    newPredictions(voxIdx, :) = results.concatPredictions;
    
    subIdxCat = arrayfun(@(x) find(idxTrain == x,1,'first'), idxCat);
    
    catPredictionsOld(voxIdx, :) = oldPredictions(voxIdx, subIdxCat);
    catPredictionsNew(voxIdx, :) = newPredictions(voxIdx, subIdxCat);
end

%%
oldAvg = nanmean(catPredictionsOld, 1);
newAvg = nanmean(catPredictionsNew, 1);

figure; hold on;
bar([oldAvg(1:5), zeros(1, 5)], 'r');
bar([zeros(1,5), oldAvg(6:10)], 'b');
title('Old')

figure; hold on;
bar([newAvg(1:5), zeros(1, 5)], 'r');
bar([zeros(1,5), newAvg(6:10)], 'b');
title('New')


%%

setupBetaFig;
bar(datasets{1}.vals(voxNum, :));
% plot(oldPredictions, 'ro');
% plot(newPredictions, 'go');
addXlabels(imNumsDataset(idxTrain), stimuliNames);

%%
setupBetaFig;
bar(mean(betamnTrain, 1));
plot(nanmean(oldPredictions, 1), 'ro');
plot(nanmean(newPredictions, 1), 'go');
addXlabels(imNumsDataset(idxTrain), stimuliNames);

