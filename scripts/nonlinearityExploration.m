%% Get some data to work with
load(fullfile(rootpath, 'data', 'modelfits', '2015-05-13', 'subj3-vox353', 'xval-a0-e1-subj3-nfolds108.mat'), 'results');

% Betas ...
betamnToUse = results.betamnToUse;

% ... and images
load(fullfile(rootpath, results.inputImages), 'preprocess'); 

nFrames = 9;
imStack = flatToStack(preprocess.contrast, nFrames);
imStack = imStack(:, :, convertIndex(preprocess.imNums, results.imNumsToUse), :);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

%% Rerun a model fit
modelfun = get_socmodel_original(90);
newfits = modelfittingContrastIm(modelfun, betamnToUse, imToUse);

%% Now start making predictions and plotting them
% pred1 = modelfun(newfits.params, permute(stackToFlat(imStack), [2 1]));
% pred1 = blob(pred1, 1, nFrames) / nFrames; % matches postdiv exactly

predOrig = socmodel_postdiv(newfits.params, stackToFlat(imStack));
predOrig = blob(predOrig, 2, nFrames) / nFrames;

paramsNew = newfits.params;
paramsNew(4) = 3;
paramsNew(5) = 50;
predNew = socmodel_nononlin(paramsNew, stackToFlat(imStack));
predNew = blob(predNew, 2, nFrames) / nFrames;

%% Compare
figure; hold on;
plot(predNew, betamnToUse, 'ro');
plot(predNew, predOrig, 'go');


%% Plot
setupBetaFig;
bar(betamnToUse,1);
plot(predOrig,'ro','LineWidth',2);
plot(predNew,'g.','LineWidth',2);

ylabel('BOLD signal (% change)');
title('Data and model fit');

load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
addXlabels(stimuliNames(results.imNumsToUse));

%% How in general do piecewise nonlinearities work
g = 2;
n = 0.2;

L = 3;
k = 50;

x = linspace(0,2,100);
figure; hold on;
plot(x, g*x.^n);
plot(x, sigmoid(x, L, k));
plot(x, erf(x));
xlim([0,0.5]);
ylim([0,1.5]);

