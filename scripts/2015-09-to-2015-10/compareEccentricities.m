% 2015-11-02

%% Define dataset
%data = load_subj022_2015_06_19();
data = load_subj001_2015_10_22();

%% Prepare fig dir
figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

saveFigures = true;

%% Make one plot
roi = 'RV1_1to4deg';

roiIdx = strInCellArray(roi, data.roiNames);
setupBetaFig;

% Plotting one bar at a time enables us to set the color
plotData = data.betamn{roiIdx}(data.plotOrder);
for jj = 1:numel(plotData)
  h = bar(jj, plotData(jj));
  set(h, 'FaceColor', data.catColors(jj, :)) 
end

plotError = data.betase{roiIdx}(data.plotOrder);
errorbar(plotData, plotError, 'k.');
addXlabels(data.plotNames);
title([data.title, ', ', data.roi])

% if saveFigures,
%     %drawPublishAxis;
%     hgexport(gcf,fullfile(figDir, ['octData_', strrep(data(ii).title, ' ', '_'), '_', data(ii).roi, '.eps']));
%     saveas(gcf,fullfile(figDir, ['octData_', strrep(data(ii).title, ' ', '_'), '_', data(ii).roi, '.png']));
% end

%% Make all plots!
rois = {'RV1_0to1deg'; 'RV1_1to2deg'; 'RV1_2to4deg'; 'RV1_4to8deg'; 'RV1_8to12deg'; 'RV1_12tomaxdeg'};
for roi = 1:length(rois)
    roiIdx = strInCellArray(rois(roi), data.roiNames);
    setupBetaFig;

    % Plotting one bar at a time enables us to set the color
    plotData = data.betamn{roiIdx}(data.plotOrder);
    for jj = 1:numel(plotData)
      h = bar(jj, plotData(jj));
      set(h, 'FaceColor', data.catColors(jj, :)) 
    end

    plotError = data.betase{roiIdx}(data.plotOrder);
    errorbar(plotData, plotError, 'k.');
    addXlabels(data.plotNames);
    title([data.title, ', ', strrep(data.roiNames{roiIdx}, '_', '\_')])

    if saveFigures,
        %drawPublishAxis;
        hgexport(gcf,fullfile(figDir, [strrep(data.title, ' ', '_'), '_', data.roiNames{roiIdx}, '.eps']));
        saveas(gcf,fullfile(figDir, [strrep(data.title, ' ', '_'), '_', data.roiNames{roiIdx}, '.png']));
    end
end