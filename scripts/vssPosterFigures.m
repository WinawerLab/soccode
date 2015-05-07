%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% VSS Analysis, all in one place! Easy to run, easy to find! %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading the data!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% fMRI - which images
imNumsDataset = 70:225;
catToUse = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', ... % skip naturalistic ...
           'grating_sparse', 'pattern_sparse'}; % skip noise space/halves

% catToUse = {'pattern_space', 'pattern_central', 'grating_ori', ...
%            'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
%            'pattern_contrast', 'non_geometric_small', 'scenes', ...
%            'grating_sparse', 'pattern_sparse', 'noise_space', 'noise_grating_halves'};

load(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames');
       
imIdxToUse = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catToUse), imNumsDataset);
imNumsToUse = imNumsDataset(imIdxToUse);

%% fMRI - betamn, both datasets
datasetNums = [3, 4];

datasets = {};
for ii = 1:length(datasetNums)
    dataset = ['dataset', num2str(datasetNums(ii), '%02d'), '.mat'];
    load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
    
    betaIdxToUse = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);
    betamnToUse = betamn(:, betaIdxToUse);
    betaseToUse = betase(:, betaIdxToUse);
    
    datasets{ii}.vals = betamnToUse;
    datasets{ii}.errs = betaseToUse;
    datasets{ii}.roi = roi;
    datasets{ii}.roilabels = roilabels;
end

%% ECoG - which images
load(fullfile(rootpath, 'code', 'visualization', 'stimuliNamesEcog.mat'), 'stimuliNamesEcog');
imIdxToUseEcog = find(arrayfun(@(idx) strInCellArray(stimuliNamesEcog{idx}, catToUse), 1:length(stimuliNamesEcog)));

%% ECoG - electrode data, one dataset
datasets{3}.electrodes = [108 109 115 120 121 107];

[ecog_vals, ecog_errs] = loadEcogBroadband(datasets{3}.electrodes);
datasets{3}.vals = ecog_vals(:, imIdxToUseEcog);
datasets{3}.errs = ecog_errs(:, imIdxToUseEcog, :);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting empirical data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

setupBetaFig;
bar(datasets{1}.vals(1, :));
addXlabels(imNumsToUse, stimuliNames);

setupBetaFig;
bar(datasets{3}.vals(1, :));
addXlabels(imIdxToUseEcog, stimuliNamesEcog);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% View the ECoG images

ims = load(fullfile(rootpath, 'data', 'input', 'ecog_datasets', 'socforecog.mat'));

figure;
for ii = 1:size(ims.stimuli, 3)
    imshow(ims.stimuli(:,:,ii));
    title(ii);
    pause(0.5);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Category R2s
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Choose one canonical A and E
aOld = 0;
eOld = 1;

aNew = 0.5;
eNew = 4;

% avals = [0.25, 0.5, 0.75, 1];
% evals = [1, 2, 4, 8, 16]; 
% 
% for aNew = avals
%     for eNew = evals

categoryR2sOld = processGridSearchCategory(aOld, eOld);
categoryR2sNew = processGridSearchCategory(aNew, eNew);

figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(categoryR2sOld(categoryR2sOld > categoryR2sNew), categoryR2sNew(categoryR2sOld > categoryR2sNew), 'ro');
plot(categoryR2sOld(categoryR2sOld <= categoryR2sNew), categoryR2sNew(categoryR2sOld <= categoryR2sNew), 'go');
xlabel('Original'); ylabel('New');
title(['Category-specific R^2 ', num2str(aNew), ' ', num2str(eNew)]);

%     end
% end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Residuals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

oldResiduals = processGridSearchResiduals(aOld, eOld);
newResiduals = processGridSearchResiduals(aNew, eNew);

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
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-05');
voxNum = 9;
datasetNum = 3;
folder = ['vox', num2str(voxNum)];

filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename));
oldPredictions = results.concatPredictions;

filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename));
newPredictions = results.concatPredictions;

setupBetaFig;
bar(datasets{1}.vals(voxNum, :));
% plot(oldPredictions, 'ro');
% plot(newPredictions, 'go');
addXlabels(imNumsToUse, stimuliNames);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In-category means, two models
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

%% Recover ancient history
findVoxel = 31;
ancient = load('/Local/Users/olsson/Dropbox/Research/code/SOC-new/data/modelfits/2014-06-24/results_V1_all_R=1_S=0pt5.mat');
voxIdx = find(ancient.voxelFitIxs == findVoxel);
ancientParams = ancient.results.params(:, :, voxIdx);

folder = ['vox', num2str(findVoxel)];
filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
load(fullfile(dataloc, folder, filename));

oldPredictions = results.concatPredictions;
