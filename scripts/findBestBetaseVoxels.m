%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exploration of dataset: What's the distribution of beta mn?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dataset
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

betaSse = sum(betase, 2);

%% Choose good voxels
nvox = 20;
[y,voxNums] = sort(betaSse);

bestV1 = find(strcmp(roilabels(roi(voxNums)), 'V1'));
bestV2 = find(strcmp(roilabels(roi(voxNums)), 'V2'));
bestV3 = find(strcmp(roilabels(roi(voxNums)), 'V3'));
% not planning to use V3A/B, or hV4

%% The top 50 in each area seem pretty good:
figure; hist(y(bestV1(1:20))); title('Top 50 in V1') 
figure; hist(y(bestV2(1:20))); title('Top 50 in V2')
figure; hist(y(bestV3(1:20))); title('Top 50 in V3')