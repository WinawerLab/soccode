%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis: Quantifying properties of a response curve
% 
% - What are the 11 ways to quantify one of these response curves,
%   according to the dimensions of interest to us?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ndataset = 4;

areas = {'V1', 'V2', 'V3', 'hV4'};

for i = 1:length(areas)
    [imNumsToUse, betamnToUse{i}, voxNums{i}] = loadDataset(ndataset, areas{i});
    voxsummary{i} = struct();
end
%setupBetaFig()
%bar(betamnToUse(1,:),1);
%addXlabels(imNumsToUse);

figdir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figdir, 'dir')
    mkdir(figdir);
end
% TODO save figures too

%% Fetch labels... these will be necessary for picking out class indices
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
names = stimuliNames(imNumsToUse);

%% OK, honestly I do want the divnorms here, too!
divnormdir = fullfile(rootpath, 'data/preprocessing/2015-03-27');
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

%% Plot contrast response
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


%% Plot 
figure; hold on;
plot([voxsummary{1}.gratingPeak], [voxsummary{1}.patternTrough], 'go');
plot([voxsummary{4}.gratingPeak], [voxsummary{4}.patternTrough], 'mo');
plot(catMeans.gratingPeak(:), catMeans.patternTrough(:), 'bo');
plot(catVars.gratingPeak(:), catVars.patternTrough(:), 'co');
% tmp1 = catMeans.gratingPeak(3, 3, :, :);
% tmp2 = catMeans.patternTrough(3, 3, :, :);
% plot(tmp1(:), tmp2(:), 'bo');
% tmp1 = catVars.gratingPeak(3, 3, :, :);
% tmp2 = catVars.patternTrough(3, 3, :, :);
% plot(tmp1(:), tmp2(:), 'co');

ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating peak'); ylabel('Pattern trough')
title('Grating peak vs. pattern trough');
legend('V1', 'hV4', 'contrast im means', 'contrast im variances');

figure; hold on;
plot([voxsummary{1}.gratingPeak], [voxsummary{1}.patternPeak], 'go');
plot([voxsummary{4}.gratingPeak], [voxsummary{4}.patternPeak], 'mo');
plot(catMeans.gratingPeak(:), catMeans.patternPeak(:), 'bo');
plot(catVars.gratingPeak(:), catVars.patternPeak(:), 'co');
% tmp1 = catMeans.gratingPeak(3, 3, :, :);
% tmp2 = catMeans.patternPeak(3, 3, :, :);
% plot(tmp1(:), tmp2(:), 'bo');
% tmp1 = catVars.gratingPeak(3, 3, :, :);
% tmp2 = catVars.patternPeak(3, 3, :, :);
% plot(tmp1(:), tmp2(:), 'co');

ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating peak'); ylabel('Pattern peak')
title('Grating peak vs. pattern peak, V1 and hV4');
legend('V1', 'hV4', 'contrast im means', 'contrast im variances');


%% Focus on tooltips and colors here!
f=figure; hold all;

colorset = jet();
colorAssignments = cell(size(catMeans.gratingAvg));

for ii = 1:length(catMeans.rvals)
    colorIdx = floor((size(colorset,1)-1) * (ii/length(catMeans.rvals))) + 1;
    colorAssignments(ii, :, :, :, :) = {colorset(colorIdx, :)};
end
% for ii = 1:length(catMeans.svals)
%     colorIdx = floor((size(colorset,1)-1) * (ii/length(catMeans.svals))) + 1;
%     colorAssignments(:, ii, :, :, :) = {colorset(colorIdx, :)};
% end
% for ii = 1:length(catMeans.avals)
%     colorIdx = floor((size(colorset,1)-1) * (ii/length(catMeans.avals))) + 1;
%     colorAssignments(:, :, ii, :, :) = {colorset(colorIdx, :)};
% end
% for ii = 1:length(catMeans.evals)
%     colorIdx = floor((size(colorset,1)-1) * (ii/length(catMeans.evals))) + 1;
%     colorAssignments(:, :, :, ii, :) = {colorset(colorIdx, :)};
% end

% Show all:
scatter(catMeans.gratingAvg(:), catMeans.patternAvg(:), [], cell2mat(colorAssignments(:)));

% Show just a subset:
% gr = catMeans.gratingAvg(:, :, catMeans.avals==0, catMeans.evals==1);
% pat = catMeans.patternAvg(:, :, catMeans.avals==0, catMeans.evals==1);
% colors = colorAssignments(:, :, catMeans.avals==0, catMeans.evals==1);
% scatter(gr(:), pat(:), [], colors(:))

ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating average'); ylabel('Pattern average')
title('Grating vs. pattern, average comparison');
legend('contrast im means');

dcm_obj = datacursormode(f);
myplotter = @(sub, fhandle)(plotTwoBarSets(squeeze(catMeans.values(sub{:}, gratingSparse)),...
                                  squeeze(catMeans.values(sub{:}, patternSparse)),...
                                  'grating', 'pattern', fhandle));
indexInto = {catMeans.rvals, catMeans.svals, catMeans.avals, catMeans.evals};

barFig = figure;
set(dcm_obj,'UpdateFcn',subfigureTooltip('gr', 'pat', size(catMeans.gratingAvg), indexInto, myplotter, barFig));

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

%% Plot sparsity
figure;
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

%% Let's try to make grid-of-surface plots! This will be fun! =)

values = atan(catMeans.patternAvg ./ catMeans.gratingAvg);
range = [0 pi/2];

%values = catMeans.gratingAvg;
%range = [0 max(values(:))];

dim1vals = catMeans.rvals(3); dim1name = 'r';
dim2vals = catMeans.svals(3); dim2name = 's';
dim3vals = catMeans.avals; dim3name = 'a';
dim4vals = catMeans.evals; dim4name = 'e';

figure;

numRows = length(dim2vals);
numCols = length(dim1vals);
for row = 1:length(dim2vals)
    for col = 1:length(dim1vals)
        slice = squeeze(values(col, row, :, :));
        
        subplot(numRows, numCols, numCols*(row-1)+col)
        imagesc(squeeze(dim3vals), squeeze(dim4vals), slice')%, range);
            % Transpose so that rows become X and columns become Y
        xlabel(dim3name);
        ylabel(dim4name);
    end
end

colormap(cool);



















