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

%% Quantifying contrast response
% We'll average the lowest three patterns and the highest three patterns

patternContrast = find(strcmp(names, 'pattern_contrast'));

for area = 1:length(areas)
    for voxIdx = 1:length(voxNums{area})
        voxsummary{area}(voxIdx).lowContrast = mean(betamnToUse{area}(voxIdx, patternContrast(1:3)));
        voxsummary{area}(voxIdx).highContrast = mean(betamnToUse{area}(voxIdx, patternContrast(end-3:end)));
    end
end

% Plot it!!
figure; hold on;
plot([voxsummary{2}.lowContrast], [voxsummary{2}.highContrast], 'go');
plot([voxsummary{3}.lowContrast], [voxsummary{3}.highContrast], 'mo');
axis([-2, 5, -2, 5]); axis('square');
xlabel('Low contrast response'); ylabel('High contrast response')
legend('V1', 'hV4');
title('Contrast response in V1, hV4');

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

% Plot it!!
figure; hold on;
plot([voxsummary{1}.gratingPeak], [voxsummary{1}.patternTrough], 'go');
plot([voxsummary{4}.gratingPeak], [voxsummary{4}.patternTrough], 'mo');
ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating peak'); ylabel('Pattern trough')
title('Grating peak vs. pattern trough, V1 and hV4');
legend('V1', 'hV4');

% Plot it!!
figure; hold on;
plot([voxsummary{1}.gratingAvg], [voxsummary{1}.patternAvg], 'go');
plot([voxsummary{4}.gratingAvg], [voxsummary{4}.patternAvg], 'mo');
ezplot('x', 'r');
axis([0, 5, 0, 5]); axis('square');
xlabel('Grating average'); ylabel('Pattern average')
title('Grating vs. pattern, average comparison');

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
figure;

subplot(2, 2, 1); hist([voxsummary{1}.sparsityPeakIdxGrating], 1:5); title('Peak grating sparsity, V1');
subplot(2, 2, 3); hist([voxsummary{1}.sparsityPeakIdxPattern], 1:5); title('Peak pattern sparsity, V1');

subplot(2, 2, 2); hist([voxsummary{4}.sparsityPeakIdxGrating], 1:5); title('Peak grating sparsity, hV4');
subplot(2, 2, 4); hist([voxsummary{4}.sparsityPeakIdxPattern], 1:5); title('Peak pattern sparsity, hV4');

