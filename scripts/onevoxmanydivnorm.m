%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Effect of orientation-tuned surround suppression
% 
% - Generate new fits for *one* voxel, on *several* new contrast images
% - Compare with old fits, from existing contrast images
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Acquire dataset
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase');
% betamn is 1323 voxels * 156 betamn values

%% Which images are in the dataset?
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames

%% Pick a demo voxel
voxNum = 33;
fh = setupBetaFig();
bar(betamn(voxNum, :));
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
addXlabels(imNumsToUse, stimuliNames);

%% Extract the relevant voxel and images
betamnIdx = convertIndex(imNumsDataset, imNumsToUse);
betamnToUse = betamn(voxNum, betamnIdx);

%% Create a Kendrick-style socmodel
modelfun = get_socmodel_original(90);

%% Fitting
inputdir = 'data/preprocessing/2014-12-04';

outputdir = ['data/modelfits/', datestr(now,'yyyy-mm-dd')];
if ~exist(fullfile(rootpath, outputdir), 'dir')
    mkdir(fullfile(rootpath, outputdir));
end

T = [0 0.001 0.1 1.0 10.0 100.0 1000.0];
results = cell(1, length(T));

for i = 1:length(T);
    if i == 1
        continue
    end
    t = T(i);
    
    % Load and resize preprocessed contrast images
    imFilename = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
    load(fullfile(rootpath, inputdir, imFilename));
    imStack = flatToStack(contrastNeighbors, 9);
    imPxv = stackToPxv(imStack);
    imToUse = permute(imPxv, [2 1 3]);
    
    % Fit the modelfun!
    results{i} = modelfittingContrastIm(modelfun, betamnToUse, imToUse);
    results{i}.voxNums = voxNum;
    results{i}.dataset = datasetNum;
    results{i}.voxNums = voxNum;
    results{i}.imNums = imNumsToUse;
    results{i}.modelfun = 'get_socmodel_original(90)';
    results{i}.inputImages = fullfile(inputdir, imFilename);
    results{i}.r = 1;
    results{i}.s = 0.5;
    results{i}.t = t;
    
    save(fullfile(rootpath, outputdir, ['neighbordivnorm-results-subj', num2str(datasetNum), '-vox', num2str(voxNum), '.mat']), 'results')
end

%% Load existing fits
load(fullfile(rootpath, 'data/modelfits/2014-12-04/neighbordivnorm-results-subj3vox33-save.mat'), 'results');

%% Get ready to visualize one of the fits
i = 7;
params = results{i}.params;
T = [0 0.001 0.1 1.0 10.0 100.0 1000.0];
t = T(i);

%% Load and resize preprocessed contrast images for this t, again
imFilename = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');
load(fullfile(inputdir, imFilename));
imStack = flatToStack(contrastNeighbors, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

%% Compute actual results here
modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
for frame=1:size(imToUse,3)
    modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
end
modelPredictionsAvg = mean(modelPredictionsByFrame, 2);

%% Now show them!

setupBetaFig()
bar(betamnToUse,1);
plot(modelPredictionsAvg,'ro','LineWidth',3);

ylabel('BOLD signal (% change)');
title('Data and model fit');

addXlabels(imNumsToUse, stimuliNames);