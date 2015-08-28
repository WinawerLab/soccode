%% PREDICTIONS FOR ARBITRARY STIMULI:
% Make predictions, based on saved model-fit parameters,
% of ROI responses for arbitrary stimuli that were not shown

% (Code excised and tidied from vssPosterFigures.m)

%% Create figs directory
figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

saveFigures = true;

%% Define parameters
aOld = 0;
eOld = 1;

aNew = 0.75;
eNew = 8;

r = 1;
s = 0.5;

dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');

%% Get the new stimuli
inputDir = fullfile('data', 'preprocessing', '2015-05-09');

inputFile = ['newstimuli_r', strrep(num2str(r), '.', 'pt'),...
    '_s', strrep(num2str(s), '.', 'pt'),...
    '_a', strrep(num2str(aOld), '.', 'pt'),...
    '_e', strrep(num2str(eOld), '.', 'pt'), '.mat'];
load(fullfile(rootpath, inputDir, inputFile), 'preprocess');

imStack = flatToStack(preprocess.contrast, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

modelfun = get_socmodel_original(90);


%% Reuse old model fits for the new predictions

datasetNum = 4;

voxNums = [167,44,100,308,172,17,171,84,101,16,...
            77,71,92,86,58,67,78,179,469,40]; % Twenty V1 voxels
        
predictionsAprOld1_4 = NaN*ones(length(voxNums), size(imToUse, 1));
predictionsAprNew1_4 = NaN*ones(length(voxNums), size(imToUse, 1));

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];
    
    % Old
    try
        filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
        load(fullfile(dataloc, folder, filename), 'results');
    catch
        disp('oops, one of the files was not found')
        continue;
    end
    
    predictions = zeros(length(results.foldImNums), size(imToUse, 1));
    for fold = 1:length(results.foldImNums)
        params = results.foldResults(fold).params;
        predictions(fold, :) = predictResponses(imToUse, params, modelfun);
    end
    predictionsAprOld1_4(voxIdx, :) = mean(predictions, 1);
    
    % New
    try
        filename = ['aegridsearch-a', num2str(aNew), '-e', num2str(eNew), '-subj', num2str(datasetNum), '.mat'];
        load(fullfile(dataloc, folder, filename), 'results');
    catch
        disp('oops, one of the files was not found')
        continue;
    end
    
    predictions = zeros(length(results.foldImNums), size(imToUse, 1));
    for fold = 1:length(results.foldImNums)
        params = results.foldResults(fold).params;
        predictions(fold, :) = predictResponses(imToUse, params, modelfun);
    end
    predictionsAprNew1_4(voxIdx, :) = mean(predictions, 1);
end

%% Plot!
figure; hold on;
bar([nanmean(predictionsAprOld1_4(1:20, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), nanmean(predictionsAprOld1_4(1:10, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), nanmean(predictionsAprOld1_4(1:10, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), nanmean(predictionsAprOld1_4(1:10, 10:12), 1)], 'c');
ylim([0, 2]);
title('V1, SOC')
if saveFigures,
    drawPublishAxis;
    hgexport(gcf,fullfile(figDir, 'aprData_SOCpred_V1.eps'));
end

figure; hold on;
bar([nanmean(predictionsAprNew1_4(1:20, 1:3), 1), zeros(1, 9)], 'b');
bar([zeros(1,3), nanmean(predictionsAprNew1_4(1:10, 4:6), 1), zeros(1,6)], 'g');
bar([zeros(1,6), nanmean(predictionsAprNew1_4(1:10, 7:9), 1), zeros(1,3)], 'r');
bar([zeros(1,9), nanmean(predictionsAprNew1_4(1:10, 10:12), 1)], 'c');
ylim([0, 2]);
title('V1, OTS')
if saveFigures,
    drawPublishAxis;
    hgexport(gcf,fullfile(figDir, 'aprData_OTSpred_V1.eps'));
end


