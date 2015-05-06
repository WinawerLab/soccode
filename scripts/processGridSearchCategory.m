%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Process the results for the grid search on a and e:
%   - Load data for multiple a and e values, and compare *on the specific
%   categories*!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function categoryR2s = processGridSearchCategory(a, e)

%% R^2 on *only* the classes in question?

%% Prepare the data
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-05');
datasetNum = 3;

voxNums = [31,42,59,71,72,77,81,83,89,90,10,19,22,29,30,33,35,36,38,47,1,3,7,8,9,12,15,16,18,20];
           %94,104,115,116,122,125,131,142,143,148,57,60,62,65,68,69,73,76,78,79,24,25,26,28,32,34,37,40,41,43];

imNumsDataset = 70:225;

load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
catTrain = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', 'grating_sparse', 'pattern_sparse'}; % omit naturalistic and noise space/halves
idxTrain = find(arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catTrain), imNumsDataset));

imNumsCat = [176, 177, 178,  179, 180, 181, 182, 183, 85, 184];
idxCat = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsCat);

dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
betamnTrain = betamn(voxNums, idxTrain);
betamnCat = betamn(voxNums, idxCat);


%%
categoryR2s = ones(1, length(voxNums));
categoryR2s = categoryR2s * NaN;

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['vox', num2str(voxNum)];
    

    filename = ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat'];
    try
        % Get the saved cross-validated parameters
        % (This might fail. If it does, it's no problem at all.)
        load(fullfile(dataloc, folder, filename));
    catch
        continue;
    end

    subIdxCat = arrayfun(@(x) find(idxTrain == x,1,'first'), idxCat);
    
    predCat = results.concatPredictions(subIdxCat);
    useThisMean = mean(betamnTrain(voxIdx, :));
    categoryR2s(voxIdx) = computeR2(predCat, betamnCat(voxIdx, :), useThisMean);
end

save('categoryR2s.mat', 'categoryR2s');
end

