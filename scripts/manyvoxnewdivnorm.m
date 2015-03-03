%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Effect of orientation-tuned surround suppression
% 
% - Generate new fits for *twenty* good voxels on new contrast images at
%   *two* parameterizations; this is for dataset 4 which has no loadable
%   params
%
%   Experiment run 2015-03-02
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Dataset
datasetNum = 4;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames
betaIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);

%% Voxels
% Pick the twenty least-noisy voxels, then filter for V1 or V2 or V3
nvox = 20;
[y,i] = sort(sum(betase,1));
voxNums = i(1:20);
voxNums = voxNums(logical(strcmp(roilabels(roi(voxNums)), 'V1') + strcmp(roilabels(roi(voxNums)), 'V2') + strcmp(roilabels(roi(voxNums)), 'V3')));
betamnToUse = betamn(voxNums, betaIdx);

%% Model
% Create a Kendrick-style socmodel
modelfun = get_socmodel_original(90);

%% Fitting 
inputdir = fullfile(rootpath, 'data/preprocessing/2014-12-04');
outputdir = fullfile(rootpath, ['data/modelfits/', datestr(now,'yyyy-mm-dd')]);

for t = [0, 100];

    % Load and resize preprocessed contrast images
    name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
    load(fullfile(inputdir, name));
    imStack = flatToStack(contrastNeighbors, 9);
    imPxv = stackToPxv(imStack);
    imToUse = permute(imPxv, [2 1 3]);
        % Permute because old fitting code expects C * (X*Y) * F, not (X*Y) * C * F

    % Fit the modelfun!
    results = modelfittingContrastIm(modelfun, betamnToUse, imToUse);
    results.tvalue = t;

    if ~exist(outputdir, 'dir')
        mkdir(outputdir);
    end

    save(fullfile(outputdir, ['neighbordivnorm-results-subj', num2str(datasetNum), '-t', strrep(num2str(t), '.', 'pt'), '-twentyvoxels.mat']), 'results')

end