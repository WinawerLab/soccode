%% PREDICTIONS FOR ARBITRARY STIMULI:
% Make predictions, based on saved model-fit parameters,
% of ROI responses for arbitrary stimuli that were not necesasrily
% shown in the experiment the parameters are drawn from

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
inputDir = fullfile('data', 'preprocessing', '2015-09-13');

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

%voxNums = [167,44,100,308,172,17,171,84,101,16,...
%            77,71,92,86,58,67,78,179,469,40]; % Twenty V1 voxels

voxNums = [94,200,619,190,105,204,191,309,274,746, ...
    90,243,472,152,322,473,566,254,457,314]; % Twenty V2 voxels
        
predictionsOld = NaN*ones(length(voxNums), size(imToUse, 1));
predictionsNew = NaN*ones(length(voxNums), size(imToUse, 1));

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
    predictionsOld(voxIdx, :) = mean(predictions, 1);
    
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
    predictionsNew(voxIdx, :) = mean(predictions, 1);
end

%% Plot! (check titles, names)

% TODO: the following is repeated from visualizeGlmResults, and
% needs to be rephrased in terms of imnums
patterns_sparse = 1:5;
gratings_sparse = 6:10;
noisebars_sparse = 11:15;
waves_sparse = 16:21;
gratings_ori = [8, 22:24];
noisebars_ori = [13, 25:27];
waves_ori = [18, 28:30];
gratings_cross = 31:34;
gratings_contrast = [35:36, 8, 37:38];
noisebars_contrast = [39:40, 13, 41:42];
waves_contrast = [43:44, 18, 45:46];
patterns_contrast = [47:48, 3, 49:50];
predPlotOrder = [patterns_sparse, gratings_sparse, noisebars_sparse, waves_sparse, ...
             gratings_ori, noisebars_ori, waves_ori ...
             gratings_cross, ...
             patterns_contrast, gratings_contrast, noisebars_contrast, waves_contrast];

figure; hold on;
bar(nanmean(predictionsOld(:, predPlotOrder), 1));
ylim([0, 2]);
title('V2, SOC')
if exist('plotNames', 'var'); addXlabels(1:length(plotNames), plotNames); end;
if saveFigures,
    %drawPublishAxis; % I don't remember how I got this to work with
    %addXlabels
    hgexport(gcf,fullfile(figDir, 'junData_SOCpred_V2.eps'));
end

figure; hold on;
bar(nanmean(predictionsNew(:, predPlotOrder), 1));
ylim([0, 2]);
title('V2, OTS')
if exist('plotNames', 'var'); addXlabels(1:length(plotNames), plotNames); end;
if saveFigures,
    %drawPublishAxis;
    hgexport(gcf,fullfile(figDir, 'junData_OTSpred_V2.eps'));
end

%% Same thing, but line plot
figure; hold all;
plot(nanmean(predictionsOld(:, predPlotOrder), 1), 'o-');
plot(nanmean(predictionsNew(:, predPlotOrder), 1), 'o-');
ylim([0, 2]);
title('V2')
legend('SOC', 'OTS');
if exist('plotNames', 'var'); addXlabels(1:length(plotNames), plotNames); end;
if saveFigures,
    %drawPublishAxis; % I don't remember how I got this to work with
    %addXlabels
    hgexport(gcf,fullfile(figDir, 'junData_pred_V2_line.eps'));
end