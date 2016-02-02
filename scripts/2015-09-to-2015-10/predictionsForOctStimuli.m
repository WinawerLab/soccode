%% PREDICTIONS FOR Oct STIMULI:
% Make predictions, based on saved model-fit parameters,
% of ROI responses for 2015-10 stimuli

% WARNING - as far as I can tell, this file was never really updated from 
% predictionsForJuneStimuli, so IGNORE THIS FILE.

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

% TODO: check that jun stimuli is right
inputFile = ['junstimuli_r', strrep(num2str(r), '.', 'pt'),...
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

fitRois = {'V1', 'V2'};

voxNums = {};
voxNums{1} = [167,44,100,308,172,17,171,84,101,16,...
            77,71,92,86,58,67,78,179,469,40]; % Twenty V1 voxels

voxNums{2} = [94,200,619,190,105,204,191,309,274,746, ...
    90,243,472,152,322,473,566,254,457,314]; % Twenty V2 voxels

for roi = 1:length(fitRois)
    predictionsOld{roi} = NaN*ones(length(voxNums{roi}), size(imToUse, 1));
    predictionsNew{roi} = NaN*ones(length(voxNums{roi}), size(imToUse, 1));

    for voxIdx = 1:length(voxNums{roi})
        voxNum = voxNums{roi}(voxIdx);
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
        predictionsOld{roi}(voxIdx, :) = mean(predictions, 1);

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
        predictionsNew{roi}(voxIdx, :) = mean(predictions, 1);
    end
end

%% Info for plotting / arranging
[plotOrder, plotNames, catColors] = getOctPlotInfo();

%% Plot! (check titles, names)

for roi = 1:length(fitRois)
    figure; hold on;
    plotWithColors(nanmean(predictionsOld{roi}, 1), plotOrder, plotNames, catColors);
    ylim([0, 2]);
    title([fitRois{roi}, ', SOC'])
    if saveFigures,
        %drawPublishAxis; % I don't remember how I got this to work with
        %addXlabels
        hgexport(gcf,fullfile(figDir, ['junData_SOCpred_', fitRois{roi}, '.eps']));
    end

    figure; hold on;
    plotWithColors(nanmean(predictionsNew{roi}, 1), plotOrder, plotNames, catColors);
    ylim([0, 2]);
    title([fitRois{roi}, ', OTS'])
    if exist('plotNames', 'var'); addXlabels(plotNames); end;
    if saveFigures,
        %drawPublishAxis;
        hgexport(gcf,fullfile(figDir, ['junData_OTSpred_', fitRois{roi}, '.eps']));
    end
end
%% Same thing, but line plot
for roi = 1:length(fitRois)
    figure; hold all;
    plot(nanmean(predictionsOld{roi}(:, plotOrder), 1), 'o-');
    plot(nanmean(predictionsNew{roi}(:, plotOrder), 1), 'o-');
    ylim([0, 2]);
    title(fitRois{roi})
    legend('SOC', 'OTS');
    if exist('plotNames', 'var'); addXlabels(plotNames); end;
    if saveFigures,
        %drawPublishAxis; % I don't remember how I got this to work with
        %addXlabels
        hgexport(gcf,fullfile(figDir, ['junData_pred_', fitRois{roi}, '_line.eps']));
    end
end

%% Load actual data!!
load('/Volumes/server/Projects/SOC/data/fMRI_CBI/wl_subj022_2015_06_19/GLMdenoised/betas.mat', 'betamn', 'betase', 'glmr2', 'roiNames');

%% Plot predictions on top of data!

for fitRoi = 1:length(fitRois)
    roiName = fitRois{fitRoi};
    roi = strInCellArray(roiName, roiNames);
    data = betamn{roi}(plotOrder);
    datase = betase{roi}(plotOrder);
    predOld = nanmean(predictionsOld{fitRoi}(:, plotOrder), 1);
    predNew = nanmean(predictionsNew{fitRoi}(:, plotOrder), 1);

    noisebars_sparse = 11:15;
    scaleMe = mean(data(noisebars_sparse)) / mean(predOld(noisebars_sparse));
        % this is TOTALLY eyeballing; trying to match the noisebars category,
        % since it looks like we can do it very well

    fH = figure; clf, set(fH, 'Color', 'w'); hold on;
    plotWithColors(data, plotOrder, plotNames, catColors);
    plotWithColors(betamn{roi}, plotOrder, plotNames, catColors);
    
    errorbar(data, datase, '.k', 'LineWidth', 1);
    %plot(predOld * scaleMe, 'ro-');
    plot(predNew * scaleMe, 'gx-', 'LineWidth', 2);

    title(roiName)
    %    set(gca, 'YLim', [0 2], 'XTick', 1.5:3.5:12, 'YTick', 0:.5:2,  ...
    %        'XTickLabel', {'Gratings', 'Noisy Stripes', 'Waves', 'Patterns'})
    ylabel('Mean BOLD response')


    setfigurepos([500, 500, 1200, 600]);
    hgexport(fH, fullfile(figDir, ['past_predictions_', roiName, '.eps']))
    saveas(fH, fullfile(figDir, ['past_predictions_', roiName, '.fig']))
    saveas(fH, fullfile(figDir, ['past_predictions_', roiName, '.png']))
end

%% Breakdown plots!! Which ones are worth plotting?

for fitRoi = 1:length(fitRois)
    roiName = fitRois{fitRoi};
    roi = strInCellArray(roiName, roiNames);
    
    contrastSubset = [gratings_contrast, noisebars_contrast, waves_contrast, patterns_contrast];
    contrastInterleave = flatten(reshape(1:numel(contrastSubset), 5, [])');

    whichToPlot = {[patterns_sparse, gratings_sparse, noisebars_sparse, waves_sparse],...
            [gratings_ori, noisebars_ori, waves_ori],...
            gratings_cross,...
            contrastSubset,...
            contrastSubset(contrastInterleave)};
    titles = {'sparsity', 'orientation', 'cross-modulated', 'contrast', 'contrast(interleaved)'};

    for ii = 1:length(whichToPlot)
        subset = whichToPlot{ii};
        fH = figure; clf, set(fH, 'Color', 'w'); hold on;

        %b = bar(betamn{roi}(subset));
        for jj = 1:numel(betamn{roi}(subset))
          h = bar(jj, betamn{roi}(subset(jj)));
          if jj == 1, hold on, end
          set(h, 'FaceColor', catColors(subset(jj), :)) 
        end

        errorbar(betamn{roi}(subset), betase{roi}(subset), '.k', 'LineWidth', 1);
        %plot(nanmean(predictionsOld(:, subset), 1) * scaleMe, 'ro-'); % no! bad!

        if strcmp(titles{ii}, 'contrast(interleaved)')
            values = nanmean(predictionsNew{fitRoi}(:, subset), 1) * scaleMe;
            plot(1:4, values(1:4), 'go-', 'LineWidth', 2);
            plot(5:8, values(5:8), 'go-', 'LineWidth', 2);
            plot(9:12, values(9:12), 'go-', 'LineWidth', 2);
            plot(13:16, values(13:16), 'go-', 'LineWidth', 2);
            plot(17:20, values(17:20), 'go-', 'LineWidth', 2);
        else
            plot(nanmean(predictionsNew{fitRoi}(:, subset), 1) * scaleMe, 'go-', 'LineWidth', 2);
        end

        title([roiName, ' - ', titles{ii}]);
        %    set(gca, 'YLim', [0 2], 'XTick', 1.5:3.5:12, 'YTick', 0:.5:2,  ...
        %        'XTickLabel', {'Gratings', 'Noisy Stripes', 'Waves', 'Patterns'})
        ylabel('Mean BOLD response')

        setfigurepos([500, 500, 1200, 600]);

        hgexport(fH, fullfile(figDir, ['past_predictions_', roiName, titles{ii}, '.eps']))
        saveas(fH, fullfile(figDir, ['past_predictions_', roiName, titles{ii}, '.fig']))
        saveas(fH, fullfile(figDir, ['past_predictions_', roiName, titles{ii}, '.png']))

    end
end