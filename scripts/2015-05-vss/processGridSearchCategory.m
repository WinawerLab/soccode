%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Process the results for the grid search on a and e:
%   - Load data for multiple a and e values, and compare *on the specific
%   categories*!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [categoryR2s, categoryPredictions] = processGridSearchCategory(a, e, datasetNum, voxNums)

%% R^2 on *only* the classes in question?

%% Prepare the data
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');

imNumsCat = [176, 177, 178, 179, 180, 181, 182, 183, 85, 184];

%%
categoryR2s = ones(1, length(voxNums));
categoryR2s = categoryR2s * NaN;

categoryPredictions = ones(length(imNumsCat), length(voxNums));
categoryPredictions = categoryPredictions * NaN;

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

    filename = ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat'];
    try
        % Get the saved cross-validated parameters
        % (This might fail. If it does, it's no problem at all.)
        load(fullfile(dataloc, folder, filename));
    catch
        continue;
    end

    idxCat = convertIndex(results.imNumsToUse, imNumsCat);
    
    predCat = results.concatPredictions(idxCat);
    categoryPredictions(:, voxIdx) = predCat;
    
    useThisMean = mean(results.betamnToUse);
    categoryR2s(voxIdx) = computeR2(predCat, results.betamnToUse(:, idxCat), useThisMean);
end
end

