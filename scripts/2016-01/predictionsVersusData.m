% 2016-02-01
% Designed to replace "predictionsForJuneStimuli", which was buggy

data = load_subj022_2015_06_19();
% data = load_subj001_2015_10_22(); % NOT DEFINED for October dataset
% because no preprocessing has been done yet

%% Prepare fig dir
figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end
saveFigures = true;

%% Load images for running model
[imOTS, imSOC, pprcss] = loadPreprocessedImages_2015_06();
paramLoc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');
modelfun = get_socmodel_original(90);

%% Get predictions
[predictionsOTS, predictionsSOC] = generateCachedV1V2Predictions(imOTS, imSOC, pprcss, paramLoc, modelfun);

%% Plot data
roi = 'LV2v';
dataRoiIdx = strInCellArray(roi, data.roiNames);
predictionRoiIdx = 2; % V2 is the second element of the cell array

setupBetaFig;
%plotWithColors(data.betamn{dataRoiIdx}, data.plotOrder, data.plotNames, data.catColors)
%errorbar(data.betamn{dataRoiIdx}(data.plotOrder), data.betase{dataRoiIdx}(data.plotOrder), 'k.');
plotWithColors(data.roiBetamn{dataRoiIdx}, data.plotOrder, data.plotNames, data.catColors) % 2016-05 edit
errorbar(data.roiBetamn{dataRoiIdx}(data.plotOrder), data.roiBetase{dataRoiIdx}(data.plotOrder), 'k.');

title([data.title, ', ', roi])

%% Plot predictions
predSOC = nanmean(predictionsSOC{predictionRoiIdx}, 1);
predOTS = nanmean(predictionsOTS{predictionRoiIdx}, 1);

noisebars_sparse = 11:15;
%scaleMe = mean(data.betamn{dataRoiIdx}(noisebars_sparse)) / mean(predSOC(noisebars_sparse));
scaleMe = mean(data.roiBetamn{dataRoiIdx}(noisebars_sparse)) / mean(predSOC(noisebars_sparse));
    % this is TOTALLY eyeballing; trying to match the noisebars category,
    % since it looks like we can do it very well
plot(predSOC(data.plotOrder) * scaleMe, 'rx-', 'LineWidth', 2);
%scaleMe = mean(data.betamn{dataRoiIdx}(noisebars_sparse)) / mean(predOTS(noisebars_sparse));
scaleMe = mean(data.roiBetamn{dataRoiIdx}(noisebars_sparse)) / mean(predOTS(noisebars_sparse));
    % this is TOTALLY eyeballing; trying to match the noisebars category,
    % since it looks like we can do it very well
plot(predOTS(data.plotOrder) * scaleMe, 'gx-', 'LineWidth', 2);

%% Save out
if saveFigures,
    %drawPublishAxis;
    hgexport(gcf,fullfile(figDir, ['approxPredictions_', '2015_06_', strrep(data.title, ' ', '_'), '_', roi, '.eps']));
    saveas(gcf,fullfile(figDir, ['approxPredictions_', '2015_06_', strrep(data.title, ' ', '_'), '_', roi, '.png']));
end