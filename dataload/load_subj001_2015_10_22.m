function data = load_subj001_2015_10_22()

data = struct();

data.fmri_fname = 'wl_subj001_2015_10_05';
data.stimuli_fname = 'stimuli-2015-10-05.mat';
data.title = 'Vertical';

%% Load data

tmp = load(fullfile(rootpath, 'data', 'fMRI_CBI', data.fmri_fname, 'GLMdenoised', 'betas.mat'), 'betamn', 'betase', 'roiNames', 'glmr2');
data.betamn = tmp.betamn;
data.betase = tmp.betase;
data.roiNames = tmp.roiNames;
data.glmr2 = tmp.glmr2;
clear tmp;

load(fullfile(rootpath,'data', 'stimuli', data.stimuli_fname), 'stimuli');
data.stimuli = stimuli;

%% Repeat bars as needed

% Dataset 2:
patterns_sparse = 1:5;
gratings_sparse = 6:10;
noisebars_sparse = 11:15;
waves_sparse = 16:19; % no need to omit waves, the four used were the correct four
gratings_ori = [8, 20:22];
noisebars_ori = [13, 23:25];
waves_ori = [18, 26:28]; % yes, hurrah, this was waves 18 this time
gratings_cross = [29, 30, 10, 31, 32, 8];
gratings_contrast = [33:34, 8, 35:36]; % YES, this starts with gratings too
noisebars_contrast = [37:38, 13, 39:40];
waves_contrast = [41:42, 18, 43:44];
patterns_contrast = [45:46, 3, 47:48];

data.plotOrder = [patterns_sparse, gratings_sparse, noisebars_sparse, waves_sparse, ...
             gratings_ori, noisebars_ori, waves_ori ...
             gratings_cross, ...
             patterns_contrast, gratings_contrast, noisebars_contrast, waves_contrast];
         
% Fix the plot name problems introduced by repeating stimuli
data.plotNames = data.stimuli.stimuliNames(data.plotOrder);
% anything called 'sparse' after the first 19 really belongs with its
% successors...
hasSparse = ~cellfun(@isempty, cellfun(@(x)strfind(x, 'sparse'), data.plotNames, 'UniformOutput', false));
fixThese = and(1:length(hasSparse)>19, hasSparse);
replaceWith = circshift(fixThese, [0, 1]);
replaceWith(38) = 0; replaceWith(36) = 1; % ok, well with one weird exception in the cross-modulated ones...
data.plotNames(fixThese) = data.plotNames(replaceWith);

%% Assign bar colors
gratingsColor = [80, 130, 220] ./ 255; % blue
noisebarsColor = [120, 98, 86] ./ 255; % brown
wavesColor = [0, 115, 130] ./ 255; % green
patternsColor = [80, 40, 140] ./ 255; % purple

data.catColors = zeros(length(data.plotNames), 3);

gratingRows = ~cellfun(@isempty, strfind(data.plotNames, 'grating'));
data.catColors(gratingRows, :) = repmat(gratingsColor, length(find(gratingRows)), 1);

noiseRows = ~cellfun(@isempty, strfind(data.plotNames, 'noise'));
data.catColors(noiseRows, :) = repmat(noisebarsColor, length(find(noiseRows)), 1);

wavesRows = ~cellfun(@isempty, strfind(data.plotNames, 'waves'));
data.catColors(wavesRows, :) = repmat(wavesColor, length(find(wavesRows)), 1);

patternRows = ~cellfun(@isempty, strfind(data.plotNames, 'pattern'));
data.catColors(patternRows, :) = repmat(patternsColor, length(find(patternRows)), 1);

end