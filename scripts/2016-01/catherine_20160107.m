clear all; close all;

stimdir = fullfile(rootpath, 'data', 'stimuli');
load(fullfile(stimdir, 'stimuli-2015-10-05.mat'));

figDir = fullfile(rootpath, 'figs', datestr(now,'yyyy-mm-dd'));
if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% Run example stimuli

% demostims = [8, 9, 10, 29, 30, 31, 32];
% demostims = [33, 34, 8, 35, 36]; 
% demostims = [8, 9, 10, 29, 30, 31, 32, 33, 34, 35, 36];
demostims = 33; % testing only

stims = [];
resps = zeros(size(demostims));
outfirsts = [];
outseconds = [];

for ii = 1:length(demostims)
    demostim = demostims(ii);
    disp(demostim)
    stimulus = double(stimuli.imStack(:,:,demostim,1)); % 8 and 29
    stimulus = stimulus/255 - 0.5;
    [resp, outfirst, outsecond] = catherine_secondordercontrast(stimulus, 1);
    disp(resp)
    
    stims = cat(3, stims, stimulus);
    resps(ii) = resp;
    outfirsts = cat(5, outfirsts, outfirst);
    outseconds = cat(5, outseconds, outsecond);

    saveas(gcf,fullfile(figDir, ['multiband-vis-', num2str(demostim), '.png']));
    %hgexport(gcf,fullfile(figDir, ['multiband-vis-', num2str(demostim), '.eps']));
end

%% Make pics for example stimuli, with same scale

respfirsts = sum(sum(outfirsts, 2),1);
respseconds = sum(sum(outseconds, 2),1);

for ii = 1:length(demostims)
    figure(ii);
    
    stimulus = stims(:,:,ii);
    outfirst = outfirsts(:,:,:,:,ii);
    outsecond = outseconds(:,:,:,:,ii);
    
    subplot(2,2,1); imshow(stimulus, [min(stims(:)), max(stims(:))]); colormap('gray'); freezeColors; title('Stimulus');

    respfirst = squeeze(sum(sum(outfirst,2),1));
    subplot(2,2,2); imagesc(respfirst', [0, max(respfirsts(:))]); axis xy; title('Filtered response, summed across space, varying by ori and SF'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF');

    popresp = squeeze(sum(sum(outfirst,4),3));
    subplot(2,2,3); imshow(popresp,[0, max(outfirsts(:))]); colormap('gray'); freezeColors; title('Population response, summed across ori and SF');

    respsecond = squeeze(sum(sum(outsecond,2),1));
    subplot(2,2,4); imagesc(respsecond', [0, max(respseconds(:))]); axis xy; title('SECOND-order response, summed across space, varying by ori and SF'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF');
    
    saveas(gcf,fullfile(figDir, ['multiband-vis-normalized-', num2str(demostims(ii)), '.png']));
end

%% Get ready to plot these all pretty-like

data = load_subj001_2015_10_22();

plotOrder = data.plotOrder;
plotNames = data.plotNames;
catColors = data.catColors;

%% Run all stimuli

% Predict
nstim = length(stimuli.stimuliNames);
totalresponseGlobalSOC = zeros(1,nstim);
for i = 1:nstim
    i
    tic
    stimulus = double(stimuli.imStack(:,:,i,1));
    %stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;
    stimulus = stimulus/255 - 0.5;
    
    totalresponseGlobalSOC(i) = catherine_secondordercontrast(stimulus);
    totalresponseGlobalSOC(i)
    toc
end

plotWithColors(totalresponseGlobalSOC, data.plotOrder, data.plotNames, data.catColors);
ylim([0, max(totalresponseGlobalSOC(1:30))*1.2]);

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