% Plot Spatial Frequency vs. Eccentricity for Subj001

%% Setup mrVista
mrvDir = '/Volumes/server/Projects/SOC/data/fMRI_CBI/wl_subj001_2016_02_17';
cd(mrvDir);
vw = mrVista;
gray = mrVista('3');

%% Get ROIs

% These are found in
% Projects/SOC/data/fMRI_CBI/wl_subj022_2015_06_19/Inplane/ROIs,
% choose the ones that are useful to analyze
roiNames = {'RV1', 'RV2d', 'RV3d'};
local = 1;

for ii=1:length(roiNames)
    disp(roiNames{ii})
    vw = loadROI(vw, roiNames{ii}, [], 'k', 0, local);
end
gray = ip2volAllROIs(vw,gray);

vw = refreshScreen(vw); updateGlobal(vw)
gray = refreshScreen(gray); updateGlobal(gray);

%% Load retinotopy into scan 1
vw = viewSet(vw, 'current scan', 1);
gray = viewSet(gray, 'current scan', 1);
rmFile = 'Gray/Original/rmImported_retModel-20140113-134111-gFit_yflip.mat';
gray = rmSelect(gray, 2, fullfile(mrvDir, rmFile)); % I don't actually know what "2" means here
gray = rmLoadDefault(gray);

eccMap = viewGet(gray, 'scanmap', 1);
angleMap = viewGet(gray, 'scanph', 1);
prfSizeMap = viewGet(gray, 'scanamp', 1);

keep = find(eccMap < 9); % above about 10 degrees, the fits run into fitting constraints

%% Load SF into scan 2
vw = viewSet(vw, 'current scan', 2);
gray = viewSet(gray, 'current scan', 2);

load('gaussvoxfit.mat');
vw = viewSet(vw, 'scanmap', gaussvoxfit.center, 2); % putting it here means ip2volParMap gets both
vw = viewSet(vw, 'scanph', gaussvoxfit.stdev, 2);
vw = viewSet(vw, 'scanamp', gaussvoxfit.gain, 2);
vw = viewSet(vw, 'scanco', gaussvoxfit.glmR2, 2);
vw = viewSet(vw, 'cothresh', 0.1);
vw = setDisplayMode(vw, 'map'); 
vw = viewSet(vw, 'map clip', [1 9]);
vw = viewSet(vw, 'map win', [1 9]);
vw.ui.mapMode=setColormap(vw.ui.mapMode, 'cool_springCmap');
vw = refreshScreen(vw); updateGlobal(vw);

gray = ip2volParMap(vw,gray,2,0,'nearest');
gray = refreshScreen(gray); updateGlobal(gray); % TODO WHY IS EVERYTHING TEAL?

sfMap = viewGet(gray, 'scanmap', 2);

%% Make three 2D plots of ecc, pRF size, SF preference
figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

figure; hold all; title('Ecc vs. pRF size');
for ii=1:length(roiNames)
    idxs = intersect(viewGet(gray, 'ROI indices', ii), keep);
    plot(eccMap(idxs), prfSizeMap(idxs), 'o');
    xlabel('Ecc'), ylabel('PRF size');
end
legend(roiNames);
saveas(gcf,fullfile(figDir, 'eccVsPrf.png'));

figure; hold all; title('Ecc vs. SF preference');
for ii=1:length(roiNames)
    idxs = intersect(viewGet(gray, 'ROI indices', ii), keep);
    plot(eccMap(idxs), sfMap(idxs), 'o');
    xlabel('Ecc'), ylabel('SF preference');
    ylim([0 10]);
end
legend(roiNames);
saveas(gcf,fullfile(figDir, 'eccVsSf.png'));

figure; hold all; title('pRF size vs. SF preference');
for ii=1:length(roiNames)
    idxs = intersect(viewGet(gray, 'ROI indices', ii), keep);
    plot(prfSizeMap(idxs), sfMap(idxs), 'o');
    xlabel('pRF size'), ylabel('SF preference');
    ylim([0 10]);
end
legend(roiNames);
saveas(gcf,fullfile(figDir, 'PrfVsSf.png'));

%% Make a 3D plot of all three
figure; hold all; title('Ecc vs. pRF vs. SF preference');
for ii=1:length(roiNames)
    idxs = intersect(viewGet(gray, 'ROI indices', ii), keep);
    plot3(eccMap(idxs), prfSizeMap(idxs), sfMap(idxs), 'o');
    xlabel('Ecc'), ylabel('PRF size'), zlabel('SF preference');
    zlim([0 10]);
end
legend(roiNames);

