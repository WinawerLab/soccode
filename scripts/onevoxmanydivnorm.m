%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Effect of orientation-tuned surround suppression
% 
% - Generate new fits for *one* voxel, on *several* new contrast images
% - Compare with old fits, from existing contrast images
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Acquire dataset
dataset = 'dataset03.mat';
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase');
% betamn is 1323 voxels * 156 betamn values

%% Which images are in the dataset?
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames

%% Pick a demo voxel
voxNum = 33;
fh = setupBetaFig();
bar(betamn(voxNum, :));
addXlabels(imNumsToUse);

%% Extract the relevant voxel and images
betamnIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);
betamnToUse = betamn(voxNum, betamnIdx);

%% Create a Kendrick-style socmodel
modelfun = get_socmodel_original(90);

%% Fitting
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');

outputdir = fullfile(rootpath, ['data/modelfits/', datestr(now,'yyyy-mm-dd')]);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

T = [0 0.001 0.1 1.0 10.0 100.0 1000.0];
results = cell(1, length(t));

for i = 1:length(T);
    if i == 1
        continue
    end
    t = T(i);
    
    % Load and resize preprocessed contrast images
    name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
    load(fullfile(inputdir, name));
    imStack = flatToStack(contrastNeighbors, 9);
    imPxv = stackToPxv(imStack);
    imToUse = permute(imPxv, [2 1 3]);
    
    % Fit the modelfun!
    results{i} = modelfittingContrastIm(modelfun, betamnToUse, imToUse);
    results{i}.tvalue = t;
    results{i}.voxel = voxNum;
    
    save(fullfile(outputdir, 'neighbordivnorm-results.mat'), 'results')
end

%% Load existing fits
load(fullfile(rootpath, 'data/modelfits/2014-12-04/neighbordivnorm-results-subj3vox33-save.mat'), 'results');

%% Get ready to visualize one of the fits
i = 7;
params = results{i}.params;
T = [0 0.001 0.1 1.0 10.0 100.0 1000.0];
t = T(i);

%% Load and resize preprocessed contrast images for this t, again
name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');
load(fullfile(inputdir, name));
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

addXlabels(imNumsToUse);