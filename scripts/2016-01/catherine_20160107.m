clear all; close all;

stimdir = fullfile(rootpath, 'data', 'stimuli');
load(fullfile(stimdir, 'stimuli-2015-10-05.mat'));

figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Run example stimuli

for demostim = [8, 9, 10, 29, 30, 31, 32];
    disp(demostim)
    stimulus = double(stimuli.imStack(:,:,demostim,1)); % 8 and 29
    stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;
    resp = catherine_secondordercontrast(stimulus, 1);

    saveas(gcf,fullfile(figDir, ['multiband-vis-', num2str(demostim), '.png']));
    %hgexport(gcf,fullfile(figDir, ['multiband-vis-', num2str(demostim), '.eps']));
end

%% Get ready to plot these all pretty-like
[plotOrder, plotNames, catColors] = getJunePlotInfo();

%% Run all stimuli

% Predict
nstim = length(stimuli.stimuliNames);
totalresponseGlobalSOC = zeros(1,nstim);
for i = 1:nstim
    i
    
    stimulus = double(stimuli.imStack(:,:,i,1));
    stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;
    
    totalresponseGlobalSOC(i) = catherine_secondordercontrast(stimulus);
    totalresponseGlobalSOC(i)
end

plotWithColors(totalresponseGlobalSOC, plotOrder, plotNames, catColors);

%% Run all stimuli more different
nstim = length(stimuli.stimuliNames);
totalresponseLocal = zeros(1,nstim);
for i = 1:nstim
    i
    
    stimulus = double(stimuli.imStack(:,:,i,1));
    stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;
    
    totalresponseLocal(i) = catherine_endsuppression(stimulus);
    totalresponseLocal(i)
end

figure; bar(totalresponseLocal); hold on;
addXlabels(stimuli.stimuliNames,1);

%% Run example stimuli more different
stimulus1 = double(stimuli.imStack(:,:,8,1));
stimulus1 = (stimulus1-min(stimulus1(:)))/(max(stimulus1(:))-min(stimulus1(:))) - 0.5;
resp1 = catherine_endsuppression(stimulus1, 1);

stimulus2 = double(stimuli.imStack(:,:,29,1));
stimulus2 = (stimulus2-min(stimulus1(:)))/(max(stimulus2(:))-min(stimulus2(:))) - 0.5;
resp2 = catherine_endsuppression(stimulus2, 1);

figure; hold on; bar([1,2], [resp1,resp2]);