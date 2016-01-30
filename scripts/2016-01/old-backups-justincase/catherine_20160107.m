clear all; close all;

stimdir = fullfile(rootpath, 'data', 'stimuli');
load(fullfile(stimdir, 'stimuli-2015-10-05.mat'));

%% Run example stimuli
stimulus = double(stimuli.imStack(:,:,8,1));
stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;
resp = catherine_secondordercontrast(stimulus, 1);

%% Run all stimuli
nstim = length(stimuli.stimuliNames);
totalresponse = zeros(1,nstim);
for i = 1:nstim
    i
    
    stimulus = double(stimuli.imStack(:,:,i,1));
    stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;
    
    totalresponse(i) = catherine_secondordercontrast(stimulus)
end

figure; bar( totalresponse); hold on;
addXlabels(stimuli.stimuliNames,1);