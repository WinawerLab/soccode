%% How much orientation tuning do voxels have?

% Subj 3, top twenty voxels in V1 with best betase
whichVoxs = [509,198,181,83,97,183,353,82,339,359,318,327,317,302,308,319,188,834,297,40];
[imNumsToUse, betamnToUse, voxNums] = loadDataset(3, whichVoxs);

% Just the ori stimuli
catToUse = {'grating_ori'};
load(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames');

imNumsDataset = 70:225;
imIdxOri = arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catToUse), imNumsDataset);
imNumsOri = imNumsDataset(imIdxOri);

betamnOri = betamnToUse(:, convertIndex(imNumsToUse, imNumsOri));

%% Plot orientation tuning
figure; bar(betamnOri(20, :)); title('One specific voxel');

%% Align the best one at the front, rotate the rest around
[y, maxIdx] = max(betamnOri, [], 2);

shiftBeta = betamnOri;
for row = 1:size(shiftBeta, 1)
    shiftBeta(row, :) = circshift(shiftBeta(row, :), [0, -maxIdx(row)+1]);
end

figure; bar(mean(shiftBeta, 1)); title('Systematically shifted')

%% Compare to random shifts
scrambleme = shiftBeta(:, 2:end);
for row = 1:size(scrambleme, 1)
    origRow = scrambleme(row, :);
    scrambleme(row, :) = origRow(randperm(length(origRow)));
end

scrambleBeta = [shiftBeta(:, 1), scrambleme];

figure; bar(mean(scrambleBeta, 1)); title('Randomly permuted')