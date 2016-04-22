function data = load_subj022_2015_06_19()
% Combines the fMRI data with stimulus and plotting information, for 
% ease of use

%% Get current data
fmri_fname = 'wl_subj022_2015_06_19';
load(fullfile(rootpath, 'data', 'fMRI_CBI', fmri_fname, 'GLMdenoised', 'roiBetas.mat'));
data = roiBetas;
data.fmri_fname = fmri_fname;

data.stimuli_fname = 'stimuli-2015-06-19.mat';
load(fullfile(rootpath,'data', 'stimuli', data.stimuli_fname), 'stimuli');
data.stimuli = stimuli;

data.title = 'Horizontal';

%% Repeat bars as needed
% I regret that this is spelled out by hand, but redoing it also completely
% sucks
% 
% Dataset 1:
patterns_sparse = 1:5;
gratings_sparse = 6:10;
noisebars_sparse = 11:15;
waves_sparse = 18:21; % 16 is just toooo sparse; remove 17 for consistency
gratings_ori = [8, 22:24];
noisebars_ori = [13, 25:27];
waves_ori = [20, 28:30]; % alas, this really was waves 20, not waves 18, oops/ugh
gratings_cross = [31, 32, 10, 33, 34, 8];
gratings_contrast = [35:36, 8, 37:38]; % YES, this starts with gratings first, patterns at the end
noisebars_contrast = [39:40, 13, 41:42];
waves_contrast = [43:44, 18, 45:46];
patterns_contrast = [47:48, 3, 49:50];

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