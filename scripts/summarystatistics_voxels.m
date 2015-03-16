%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis: Quantifying properties of a response curve
% 
% - What are the 11 ways to quantify one of these response curves,
%   according to the dimensions of interest to us?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ndataset = 3;

areas = {'V1', 'V2', 'V3', 'hV4'};

for i = 1:length(areas)
    [imNumsToUse, betamnToUse{i}, voxNums{i}] = loadDataset(ndataset, areas{i});
    voxsummary{i} = struct();
end
%setupBetaFig()
%bar(betamnToUse(1,:),1);
%addXlabels(imNumsToUse);

%% Fetch labels... these will be necessary for picking out class indices
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
names = stimuliNames(imNumsToUse);

%% OK, honestly I do want the divnorms here, too!
divnormdir = fullfile(rootpath, 'data/preprocessing/2015-03-15');
load(fullfile(divnormdir, 'divnormcatmeans.mat'), 'catMeans');
load(fullfile(divnormdir, 'divnormcatvars.mat'), 'catVars');

%% Quantifying contrast response
% We'll average the lowest three patterns and the highest three patterns

patternContrast = find(strcmp(names, 'pattern_contrast'));

for area = 1:length(areas)
    for voxIdx = 1:length(voxNums{area})
        voxsummary{area}(voxIdx).lowContrast = mean(betamnToUse{area}(voxIdx, patternContrast(1:3)));
        voxsummary{area}(voxIdx).highContrast = mean(betamnToUse{area}(voxIdx, patternContrast(end-3:end)));
    end
end

catMeans.lowContrast = mean(catMeans.values(:, :, :, :, patternContrast(1:3)), 5);
catMeans.highContrast = mean(catMeans.values(:, :, :, :, patternContrast(end-3:end)), 5);

catVars.lowContrast = mean(catVars.values(:, :, :, :, patternContrast(1:3)), 5);
catVars.highContrast = mean(catVars.values(:, :, :, :, patternContrast(end-3:end)), 5);

%% Plot it!!
figure; hold on;
plot([voxsummary{2}.lowContrast], [voxsummary{2}.highContrast], 'go');
plot([voxsummary{3}.lowContrast], [voxsummary{3}.highContrast], 'mo');
plot(catMeans.lowContrast(:), catMeans.highContrast(:), 'bo');
plot(catVars.lowContrast(:), catVars.highContrast(:), 'co');
% tmp1 = catMeans.lowContrast(3, 3, :, :);
% tmp2 = catMeans.highContrast(3, 3, :, :);
% plot(tmp1(:), tmp2(:), 'bo');
% tmp1 = catVars.lowContrast(3, 3, :, :);
% tmp2 = catVars.highContrast(3, 3, :, :);
% plot(tmp1(:), tmp2(:), 'co');

axis([-2, 5, -2, 5]); axis('square');
xlabel('Low contrast response'); ylabel('High contrast response')
legend('V1', 'hV4', 'contrast im means', 'contrast im variances');
title('Contrast response, in voxels and in contrast images');

%% Quantifying straight vs. curvy!
gratingSparse = find(strcmp(names, 'grating_sparse'));
patternSparse = find(strcmp(names, 'pattern_sparse'));

for area = 1:length(areas)
    for voxIdx = 1:length(voxNums{area})
        voxsummary{area}(voxIdx).gratingAvg = mean(betamnToUse{area}(voxIdx, gratingSparse));
        voxsummary{area}(voxIdx).gratingPeak = max(betamnToUse{area}(voxIdx, gratingSparse));
        voxsummary{area}(voxIdx).gratingTrough = min(betamnToUse{area}(voxIdx, gratingSparse));

        voxsummary{area}(voxIdx).patternAvg = mean(betamnToUse{area}(voxIdx, patternSparse));
        voxsummary{area}(voxIdx).patternPeak = max(betamnToUse{area}(voxIdx, patternSparse));
        voxsummary{area}(voxIdx).patternTrough = min(betamnToUse{area}(voxIdx, patternSparse));
    end
end

catMeans.gratingAvg = mean(catMeans.values(:, :, :, :, gratingSparse), 5);
catMeans.gratingPeak = max(catMeans.values(:, :, :, :, gratingSparse), [], 5);
catMeans.gratingTrough = min(catMeans.values(:, :, :, :, gratingSparse), [], 5);
catMeans.patternAvg = mean(catMeans.values(:, :, :, :, patternSparse), 5);
catMeans.patternPeak = max(catMeans.values(:, :, :, :, patternSparse), [], 5);
catMeans.patternTrough = min(catMeans.values(:, :, :, :, patternSparse), [], 5);

catVars.gratingAvg = mean(catVars.values(:, :, :, :, gratingSparse), 5);
catVars.gratingPeak = max(catVars.values(:, :, :, :, gratingSparse), [], 5);
catVars.gratingTrough = min(catVars.values(:, :, :, :, gratingSparse), [], 5);
catVars.patternAvg = mean(catVars.values(:, :, :, :, patternSparse), 5);
catVars.patternPeak = max(catVars.values(:, :, :, :, patternSparse), [], 5);
catVars.patternTrough = min(catVars.values(:, :, :, :, patternSparse), [], 5);

figure; hold on;
plot([voxsummary{1}.gratingPeak], [voxsummary{1}.patternTrough], 'go');
plot([voxsummary{4}.gratingPeak], [voxsummary{4}.patternTrough], 'mo');
%plot(catMeans.gratingPeak(:), catMeans.patternTrough(:), 'bo');
%plot(catVars.gratingPeak(:), catVars.patternTrough(:), 'co');
tmp1 = catMeans.gratingPeak(3, 3, :, :);
tmp2 = catMeans.patternTrough(3, 3, :, :);
plot(tmp1(:), tmp2(:), 'bo');
tmp1 = catVars.gratingPeak(3, 3, :, :);
tmp2 = catVars.patternTrough(3, 3, :, :);
plot(tmp1(:), tmp2(:), 'co');

ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating peak'); ylabel('Pattern trough')
title('Grating peak vs. pattern trough');
legend('V1', 'hV4', 'contrast im means', 'contrast im variances');

figure; hold on;
plot([voxsummary{1}.gratingPeak], [voxsummary{1}.patternPeak], 'go');
plot([voxsummary{4}.gratingPeak], [voxsummary{4}.patternPeak], 'mo');
%plot(catMeans.gratingPeak(:), catMeans.patternPeak(:), 'bo');
%plot(catVars.gratingPeak(:), catVars.patternPeak(:), 'co');
tmp1 = catMeans.gratingPeak(3, 3, :, :);
tmp2 = catMeans.patternPeak(3, 3, :, :);
plot(tmp1(:), tmp2(:), 'bo');
tmp1 = catVars.gratingPeak(3, 3, :, :);
tmp2 = catVars.patternPeak(3, 3, :, :);
plot(tmp1(:), tmp2(:), 'co');

ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating peak'); ylabel('Pattern peak')
title('Grating peak vs. pattern peak, V1 and hV4');
legend('V1', 'hV4', 'contrast im means', 'contrast im variances');

figure; hold on;
plot([voxsummary{1}.gratingAvg], [voxsummary{1}.patternAvg], 'go');
plot([voxsummary{4}.gratingAvg], [voxsummary{4}.patternAvg], 'mo');
%plot(catMeans.gratingAvg(:), catMeans.patternAvg(:), 'bo');
%plot(catVars.gratingAvg(:), catVars.patternAvg(:), 'co');
tmp1 = catMeans.gratingAvg(3, 3, :, :);
tmp2 = catMeans.patternAvg(3, 3, :, :);
plot(tmp1(:), tmp2(:), 'bo');
tmp1 = catVars.gratingAvg(3, 3, :, :);
tmp2 = catVars.patternAvg(3, 3, :, :);
plot(tmp1(:), tmp2(:), 'co');

ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating average'); ylabel('Pattern average')
title('Grating vs. pattern, average comparison');
legend('V1', 'hV4', 'contrast im means', 'contrast im variances');

%% Quantifying sparsity: which bin has the peak sparsity?
gratingSparse = find(strcmp(names, 'grating_sparse'));
patternSparse = find(strcmp(names, 'pattern_sparse'));

for area = 1:length(areas)
    for voxIdx = 1:length(voxNums{area})
        [~, idx] = max(betamnToUse{area}(voxIdx, gratingSparse));
        voxsummary{area}(voxIdx).sparsityPeakIdxGrating = idx;
        
        [~, idx] = max(betamnToUse{area}(voxIdx, patternSparse));
        voxsummary{area}(voxIdx).sparsityPeakIdxPattern = idx;
    end
end

[~, idx] = max(catMeans.values(:, :, :, :, gratingSparse), [], 5);
catMeans.sparsityPeakIdxGrating = idx;
[~, idx] = max(catMeans.values(:, :, :, :, patternSparse), [], 5);
catMeans.sparsityPeakIdxPattern = idx;

[~, idx] = max(catVars.values(:, :, :, :, gratingSparse), [], 5);
catVars.sparsityPeakIdxGrating = idx;
[~, idx] = max(catVars.values(:, :, :, :, patternSparse), [], 5);
catVars.sparsityPeakIdxPattern = idx;

figure;

% Make plots
subplot(2, 4, 1); hist([voxsummary{1}.sparsityPeakIdxGrating], 1:5); title(['Peak grating sparsity,', 10, 'V1']);
subplot(2, 4, 5); hist([voxsummary{1}.sparsityPeakIdxPattern], 1:5); title(['Peak pattern sparsity,', 10, 'V1']);

subplot(2, 4, 2); hist([voxsummary{4}.sparsityPeakIdxGrating], 1:5); title(['Peak grating sparsity,', 10, 'hV4']);
subplot(2, 4, 6); hist([voxsummary{4}.sparsityPeakIdxPattern], 1:5); title(['Peak pattern sparsity,', 10, 'hV4']);

subplot(2, 4, 3); hist(catMeans.sparsityPeakIdxGrating(:), 1:5); title(['Peak grating sparsity,', 10, 'im means']);
subplot(2, 4, 7); hist(catMeans.sparsityPeakIdxPattern(:), 1:5); title(['Peak pattern sparsity,', 10, 'im means']);

subplot(2, 4, 4); hist(catVars.sparsityPeakIdxGrating(:), 1:5); title(['Peak grating sparsity,', 10, 'im vars']);
subplot(2, 4, 8); hist(catVars.sparsityPeakIdxPattern(:), 1:5); title(['Peak pattern sparsity,', 10, 'im vars']);
% tmp = catMeans.sparsityPeakIdxGrating(3, 3, :, :);
% subplot(2, 4, 3); hist(tmp(:), 1:5); title(['Peak grating sparsity,', 10, 'im means']);
% tmp = catMeans.sparsityPeakIdxPattern(3, 3, :, :);
% subplot(2, 4, 7); hist(tmp(:), 1:5); title(['Peak pattern sparsity,', 10, 'im means']);
% 
% tmp = catVars.sparsityPeakIdxGrating(3, 3, :, :);
% subplot(2, 4, 4); hist(tmp(:), 1:5); title(['Peak grating sparsity,', 10, 'im vars']);
% tmp = catVars.sparsityPeakIdxPattern(3, 3, :, :);
% subplot(2, 4, 8); hist(tmp(:), 1:5); title(['Peak pattern sparsity,', 10, 'im vars']);

