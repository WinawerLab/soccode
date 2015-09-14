%% PREDICTIONS FOR June STIMULI:
% Make predictions, based on saved model-fit parameters,
% of ROI responses for 2015-06 stimuli

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

%% Info for plotting / arranging
% TODO: the following needs to be rephrased in terms of imnums
patterns_sparse = 1:5;
gratings_sparse = 6:10;
noisebars_sparse = 11:15;
waves_sparse = 16:21;
gratings_ori = [8, 22:24];
noisebars_ori = [13, 25:27];
waves_ori = [18, 28:30];
gratings_cross = [31, 32, 8, 33, 34, 10];
gratings_contrast = [35:36, 8, 37:38];
noisebars_contrast = [39:40, 13, 41:42];
waves_contrast = [43:44, 18, 45:46];
patterns_contrast = [47:48, 3, 49:50];

plotOrder = [patterns_sparse, gratings_sparse, noisebars_sparse, waves_sparse, ...
             gratings_ori, noisebars_ori, waves_ori ...
             gratings_cross, ...
             patterns_contrast, gratings_contrast, noisebars_contrast, waves_contrast];
         
plotNames = [repmat({'patterns_sparse'}, length(patterns_sparse), 1); ...
 repmat({'gratings_sparse'}, length(gratings_sparse), 1); ...
 repmat({'noisebars_sparse'}, length(noisebars_sparse), 1); ...
 repmat({'waves_sparse'}, length(waves_sparse), 1); ...
 ...
 repmat({'gratings_ori'}, length(gratings_ori), 1); ...
 repmat({'noisebars_ori'}, length(noisebars_ori), 1); ...
 repmat({'waves_ori'}, length(waves_ori), 1); ...
 ...
 repmat({'gratings_cross'}, length(gratings_cross), 1); ...
 ...
 repmat({'patterns_contrast'}, length(patterns_contrast), 1); ...
 repmat({'gratings_contrast'}, length(gratings_contrast), 1); ...
 repmat({'noisebars_contrast'}, length(noisebars_contrast), 1); ...
 repmat({'waves_contrast'}, length(waves_contrast), 1)];

%% Plot! (check titles, names)

figure; hold on;
bar(nanmean(predictionsOld(:, plotOrder), 1));
ylim([0, 2]);
title('V2, SOC')
if exist('plotNames', 'var'); addXlabels(1:length(plotNames), plotNames); end;
if saveFigures,
    %drawPublishAxis; % I don't remember how I got this to work with
    %addXlabels
    hgexport(gcf,fullfile(figDir, 'junData_SOCpred_V2.eps'));
end

figure; hold on;
bar(nanmean(predictionsNew(:, plotOrder), 1));
ylim([0, 2]);
title('V2, OTS')
if exist('plotNames', 'var'); addXlabels(1:length(plotNames), plotNames); end;
if saveFigures,
    %drawPublishAxis;
    hgexport(gcf,fullfile(figDir, 'junData_OTSpred_V2.eps'));
end

%% Same thing, but line plot
figure; hold all;
plot(nanmean(predictionsOld(:, plotOrder), 1), 'o-');
plot(nanmean(predictionsNew(:, plotOrder), 1), 'o-');
ylim([0, 2]);
title('V2')
legend('SOC', 'OTS');
if exist('plotNames', 'var'); addXlabels(1:length(plotNames), plotNames); end;
if saveFigures,
    %drawPublishAxis; % I don't remember how I got this to work with
    %addXlabels
    hgexport(gcf,fullfile(figDir, 'junData_pred_V2_line.eps'));
end

%% Load actual data!!
load('/Volumes/server/Projects/SOC/data/fMRI_CBI/wl_subj022_2015_06_19/GLMdenoised/betas.mat', 'betamn', 'betase', 'glmr2', 'roiNames');

%% Visualize GLM denoised data as function of stimulus and ROI
for roi = 1:length(roiNames)
    roiName = roiNames{roi};
    fH = figure; clf, set(fH, 'Color', 'w'); hold on;
    bar(betamn{roi}(plotOrder));
    errorbar(betamn{roi}(plotOrder), betase{roi}(plotOrder), '.k', 'LineWidth', 1)
    title(roiName)
    %    set(gca, 'YLim', [0 2], 'XTick', 1.5:3.5:12, 'YTick', 0:.5:2,  ...
    %        'XTickLabel', {'Gratings', 'Noisy Stripes', 'Waves', 'Patterns'})
    ylabel('Mean BOLD response')
    
    addXlabels(1:length(plotNames), plotNames);

    setfigurepos([500, 500, 1200, 600]);
    hgexport(fH, ['Images/betas_all_', roiName, '.eps'])
    saveas(fH,  ['Images/betas_all_', roiName, '.fig'])
    saveas(fH,  ['Images/betas_all_', roiName, '.png'])
end

%% Plot predictions on top of data!

roiName = 'V2';
roi = strInCellArray(roiName, roiNames);
data = betamn{roi}(plotOrder);
datase = betase{roi}(plotOrder);
predOld = nanmean(predictionsOld(:, plotOrder), 1);
predNew = nanmean(predictionsNew(:, plotOrder), 1);

scaleMe = mean(data(noisebars_sparse)) / mean(predOld(noisebars_sparse));
    % this is TOTALLY eyeballing; trying to match the noisebars category,
    % since it looks like we can do it very well

fH = figure; clf, set(fH, 'Color', 'w'); hold on;
bar(data);
errorbar(data, datase, '.k', 'LineWidth', 1);
plot(predOld * scaleMe, 'ro-');
plot(predNew * scaleMe, 'go-')

title(roiName)
%    set(gca, 'YLim', [0 2], 'XTick', 1.5:3.5:12, 'YTick', 0:.5:2,  ...
%        'XTickLabel', {'Gratings', 'Noisy Stripes', 'Waves', 'Patterns'})
ylabel('Mean BOLD response')

addXlabels(1:length(plotNames), plotNames);

setfigurepos([500, 500, 1200, 600]);
hgexport(fH, ['Images/past_predictions_', roiName, '.eps'])
saveas(fH,  ['Images/past_predictions_', roiName, '.fig'])
saveas(fH,  ['Images/past_predictions_', roiName, '.png'])
