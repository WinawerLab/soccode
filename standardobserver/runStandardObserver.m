%% TODO ASK NOAH
% - what are the retData.visual_area values? 1, 1.5, 2, 2.5, 3?
% - what am I fucking up with degrees to radians?

%%
%%%%%%%%%% PART 1 - parameters %%%%%%%%%%
%
%% Load the Kay et al. 2008 fMRI data
retData = load('/Volumes/server/Projects/SOC/data/retinotopy/wl_subj001.mat');

epaRaw = cat(2, retData.eccentricity', retData.polar_angle', retData.visual_area');
nVoxRaw = size(epaRaw,1);
    % Out: voxs x 3 (ecc, polar angle, area)

% Remove visual areas 1.5 and 2.5, which are voxels on the borders
discardAreas = or(epaRaw(:,3) == 1.5, epaRaw(:,3) == 2.5);
discardEcc = epaRaw(:,1) > 20;
discardVoxels = or(discardAreas, discardEcc);
epa = epaRaw(~discardVoxels, :);

%% Compute parameters

% Obtain SOC parameters for voxels
params = stdObs_epaToParams(epa);
    % In: voxs x 3 (ecc, polar angle, area)
    % Out: voxs x 3 (sigma_s, n, c)
  
% (Sanity check: do pRF sizes get larger with area?)
% mean(params(epa(:,3) == 1, 1)) - 5.57
% mean(params(epa(:,3) == 2, 1)) - 5.31
% mean(params(epa(:,3) == 3, 1)) - 7.71
    
%% Sanity check hemifield (demo)
% Convert eccentricity and polar angle (in degrees) to x,y (in pixels)
imSzPxDemo = 300; % images assumed to be square
pxPerDegDemo = 10; % TODO get real values
xyDemo = stdObs_epToXy(epa(:,1:2), imSzPxDemo, pxPerDegDemo);
    % In: voxs x 2 (ecc, polar angle), 1x2 (size), 1
    % Out: voxs x 2 (x, y)
    
figure(1); hold on;
scatter(xyDemo(epa(:,2) >=0, 1), xyDemo(epa(:,2) >=0, 2), 'ro');
scatter(xyDemo(epa(:,2) < 0, 1), xyDemo(epa(:,2) < 0, 2), 'bo');
axis ij; xlim([0, imSzPxDemo]); ylim([0, imSzPxDemo]);

%%
%%%%%%%%%% PART 2 - predictions %%%%%%%%%%
%

%% Make predictions for some data

data = load_subj001_2015_10_22();
imStack = data.stimuli.imStack(:,:,:,1);
imStack = (double(imStack)- 127)/255;
imStack = imresize(imStack, [150, 150]);
imFlat = stackToFlat(imStack);
    % TODO: just one frame/exemplar per class for now

cpd = 3; % cycles per degree to analyze
totalFovDeg = 18;  % from stimulusgen_2015_10_05 script
cpIm = cpd * totalFovDeg;

imSzPx = sqrt(size(imFlat,1));
pxPerDeg = imSzPx / totalFovDeg;

xy = stdObs_epToXy(epa(:,1:2), imSzPx, pxPerDeg);
xyParams = [xy, params];

if exist('gaborOutput', 'var')
    preds = stdObs_predict(xyParams, imFlat, cpIm, gaborOutput);
else
    [preds, gaborOutput] = stdObs_predict(xyParams, imFlat, cpIm);
end
    % In: voxs x 5 (x, y, sigma_s, n, c), px x nIms, 1
    % Out: voxs x nIms 
    
%% Plot *all* predictions versus data
rois = {'RV1', 'RV2', 'RV3'};
for area = 1:3 % just V1 for now
    roiData = data.betamn{strInCellArray(rois{area}, data.roiNames)};
    
    predStdObs = mean(preds(epa(:,3) == area, :), 1);
    predStdObs_scaled = predStdObs * mean(roiData(:)) / mean(predStdObs);

    setupBetaFig;
    plotWithColors(roiData, data.plotOrder, data.plotNames, data.catColors)
    plot(predStdObs_scaled(data.plotOrder), 'go');
end
 
    
%% Load old parameters for *someone else's* V1 and V2
% and run it on the gaborOutput to make old predictions

paramLoc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');
datasetNum = 4;
aOld = 0; eOld = 1;
fitRois = {'V1', 'V2'};
voxNums = {};
voxNums{1} = [167,44,100,308,172,17,171,84,101,16,...
            77,71,92,86,58,67,78,179,469,40]; % Twenty V1 voxels
voxNums{2} = [94,200,619,190,105,204,191,309,274,746, ...
    90,243,472,152,322,473,566,254,457,314]; % Twenty V2 voxels

nFolds = 10;
allParams{1} = [];
allParams{2} = [];

for roi = 1:length(fitRois)
    for voxIdx = 1:length(voxNums{roi})
        voxNum = voxNums{roi}(voxIdx);
        folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

        try
            filename = ['aegridsearch-a', num2str(aOld), '-e', num2str(eOld), '-subj', num2str(datasetNum), '.mat'];
            load(fullfile(paramLoc, folder, filename), 'results');
            allParams{roi} = cat(1, allParams{roi}, cat(1, results.foldResults.params)); % just grab every fold
        catch
            disp('not found...')
            continue;
        end
    end
end

%% Make new predictions
predsOldParams{1} = stdObs_predict(allParams{1}(:,1:5), imFlat, cpIm, gaborOutput);
predsOldParams{2} = stdObs_predict(allParams{2}(:,1:5), imFlat, cpIm, gaborOutput);

%% Plot *all* predictions versus data

rois = {'RV1', 'RV2', 'RV3'};
for area = 1:3 % just V1 for now
    roiData = data.betamn{strInCellArray(rois{area}, data.roiNames)};
    
    predStdObs = mean(preds(epa(:,3) == area, :), 1);
    predStdObs_scaled = predStdObs * mean(roiData(:)) / mean(predStdObs);
    
    predVoxelwise = mean(predsOldParams{area}, 1);
    predVoxelwise_scaled = predVoxelwise * mean(roiData(:)) / mean(predVoxelwise);

    setupBetaFig;
    plotWithColors(roiData, data.plotOrder, data.plotNames, data.catColors)
    plot(predStdObs_scaled(data.plotOrder), 'go');
    plot(predVoxelwise_scaled(data.plotOrder), 'ro');
end
 
