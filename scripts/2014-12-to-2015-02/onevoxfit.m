%% Experiment - How long does model fitting work on *one* voxel with a memoized
% gabor model?
% ANSWER: very, very long

%% Acquire a dataset
dataset = 'dataset03.mat';
load(fullfile(rootpath, ['data/fmri_datasets/', dataset]),'betamn','betase');
% betamn is 1323 voxels * 156 betamn values

%% Which images are in the dataset?
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames
    
%% Pick a demo voxel
voxNum = 33;
fh = setupBetaFig();
bar(betamn(voxNum, :));

%% Extract the relevant voxel and images
betamnIdx = convertIndex(imNumsDataset, imNumsToUse);
betamnToUse = betamn(voxNum, betamnIdx);

%% Load and resize raw images
imFile = fullfile(rootpath, 'data/input/stimuli.mat');   
imStack = loadImages(imFile, imNumsToUse);
imStack = resizeStack(imStack, 150, 30);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

%% Make a memgabor
memgabor = get_gaborenergy_memoized();
memdiv = get_divnormpointwise_memoized();

%% Create a memoized socmodel
socmodel_memoized_handle = get_socmodel_memgabdiv(memgabor, memdiv);

%% Do modelfitting
modelfittingRawIm(socmodel_memoized_handle, betamnToUse, imToUse);
% This takes VERY VERY long


