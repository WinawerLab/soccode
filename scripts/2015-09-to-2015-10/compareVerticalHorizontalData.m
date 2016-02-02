% 2015-10-21

data = load_subj022_2015_06_19();
data(2) = load_subj001_2015_10_22();

%% Prepare fig dir
figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

saveFigures = true;

%% Make comparision plots

% Decide which ROIs to plot, in case they're not called the same thing
data(1).roi = 'LV2v';
data(2).roi = 'LV2';

for ii = 1:length(data)
    roiIdx = strInCellArray(data(ii).roi, data(ii).roiNames);
    setupBetaFig;
    
    % Plotting one bar at a time enables us to set the color
    plotData = data(ii).betamn{roiIdx}(data(ii).plotOrder);
    for jj = 1:numel(plotData)
      h = bar(jj, plotData(jj));
      set(h, 'FaceColor', data(ii).catColors(jj, :)) 
    end
    
    plotError = data(ii).betase{roiIdx}(data(ii).plotOrder);
    errorbar(plotData, plotError, 'k.');
    addXlabels(data(ii).plotNames);
    title([data(ii).title, ', ', data(ii).roi])
    
    if saveFigures,
        %drawPublishAxis;
        hgexport(gcf,fullfile(figDir, ['octData_', strrep(data(ii).title, ' ', '_'), '_', data(ii).roi, '.eps']));
        saveas(gcf,fullfile(figDir, ['octData_', strrep(data(ii).title, ' ', '_'), '_', data(ii).roi, '.png']));
    end
end

%% Make all plots! (Time-consuming and mostly unnecessary!)
for ii = 1:length(data)
    for roiIdx = 1:length(data(ii).roiNames)
        setupBetaFig;

        % Plotting one bar at a time enables us to set the color
        plotData = data(ii).betamn{roiIdx}(data(ii).plotOrder);
        for jj = 1:numel(plotData)
          h = bar(jj, plotData(jj));
          set(h, 'FaceColor', data(ii).catColors(jj, :)) 
        end

        plotError = data(ii).betase{roiIdx}(data(ii).plotOrder);
        errorbar(plotData, plotError, 'k.');
        addXlabels(data(ii).plotNames);
        title([data(ii).title, ', ', data(ii).roiNames{roiIdx}])

        if saveFigures,
            %drawPublishAxis;
            hgexport(gcf,fullfile(figDir, ['octData_', strrep(data(ii).title, ' ', '_'), '_', data(ii).roiNames{roiIdx}, '.eps']));
            saveas(gcf,fullfile(figDir, ['octData_', strrep(data(ii).title, ' ', '_'), '_', data(ii).roiNames{roiIdx}, '.png']));
        end
    end
end
