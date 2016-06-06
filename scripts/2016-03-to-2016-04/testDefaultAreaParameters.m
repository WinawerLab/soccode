% Alright so here we go
% check the default parameters against the data from each area
% so I guess we use June

%% Load June data
load(fullfile(rootpath, 'data', 'preprocessing', '2015-09-13', 'gaborbandsJunstimuli_b45.mat'));
dataStruct = load_subj022_2015_06_19();

%% Set default parameters from Kay et al. 2013b
paramRoiNames = {'V1', 'V2', 'V3'}; % hV4
roiPrfSigmaAtTwoDeg = [0.16, 0.18, 0.25, 0.18]*90;
roiN = [0.18, 0.13, 0.12, 0.13];
roiC = [0.93, 0.99, 0.99];
R = 1; S = .5;
X = 45; Y = 45;
G = 1;

%% Do the predictions based on the default parameters

roiPredMean = cell(size(paramRoiNames));
for paramRoiIdx = 1:length(paramRoiNames)
    D = roiPrfSigmaAtTwoDeg(paramRoiIdx);
    N = roiN(paramRoiIdx);
    C = roiC(paramRoiIdx);

    params = [R, S, X, Y, D, G, N, C];
    predictions = socmodel_nogaborstep(params, gabor.gaborFlat); % 450 predictions
    predictions = squeeze(flatToStack(predictions, gabor.nFrames)); % 50 categories * 9 frames
    roiPredMean{paramRoiIdx} = mean(predictions,2)';
end

%% Make plots

figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Plot data vs. predictions
for paramRoiIdx = 1:length(paramRoiNames)
    whichRoi = paramRoiNames{paramRoiIdx};

    predMean = roiPredMean{paramRoiIdx};
    
    data = dataStruct.roiBetamn{strInCellArray(whichRoi, dataStruct.roiNames)};
    G = mean(data)/mean(predMean);

    setupBetaFig;
    plotWithColors(data, dataStruct.plotOrder, dataStruct.plotNames, dataStruct.catColors)
    plot(G*predMean(dataStruct.plotOrder), 'ro');
    title([whichRoi, ' default param predictions vs. data'])
    saveas(gcf, fullfile(figDir, ['defaultPredictionsVsData_', whichRoi, '.png']));
end

%% Plot all predictions together
setupBetaFig;
demoRoi = 'V1';
data = dataStruct.roiBetamn{strInCellArray(demoRoi, dataStruct.roiNames)};
plotWithColors(data, dataStruct.plotOrder, dataStruct.plotNames, dataStruct.catColors)
hold all;
colors = {'r','g','b','k'};
for paramRoiIdx = 1:length(paramRoiNames)
    predMean = roiPredMean{paramRoiIdx};
    G = mean(data)/mean(predMean);

    plot(G*predMean(dataStruct.plotOrder), [colors{paramRoiIdx},'o']);
end
title('V1, V2, and V3 (R,G,B) predictions, versus V1 data for reference')
saveas(gcf, fullfile(figDir, ['defaultPredictions_allROI_over', demoRoi, '.png']));

%% Investigate the role of the C value

whichRoi = 'V2';
paramRoiIdx = strInCellArray(whichRoi, paramRoiNames);
params = [R, S, X, Y, roiPrfSigmaAtTwoDeg(paramRoiIdx), G, roiN(paramRoiIdx), roiC(paramRoiIdx)];
predC = mean(squeeze(flatToStack(socmodel_nogaborstep(params, gabor.gaborFlat), gabor.nFrames)), 2)';

params = [R, S, X, Y, roiPrfSigmaAtTwoDeg(paramRoiIdx), G, roiN(paramRoiIdx), 0];
predNoC = mean(squeeze(flatToStack(socmodel_nogaborstep(params, gabor.gaborFlat), gabor.nFrames)), 2)';

setupBetaFig; hold on;
data = dataStruct.roiBetamn{strInCellArray(whichRoi, dataStruct.roiNames)};
plotWithColors(data, dataStruct.plotOrder, dataStruct.plotNames, dataStruct.catColors)

G = mean(data)/mean(predC);
plot(G*predC(dataStruct.plotOrder), 'rx');

G = mean(data)/mean(predNoC);
plot(G*predNoC(dataStruct.plotOrder), 'go');

title([whichRoi, ' data, with C parameter (red) and without (green)'])
saveas(gcf, fullfile(figDir, ['adjustParam_C_', whichRoi, '.png']));

%% Re-create the example plots from the SOC paper

