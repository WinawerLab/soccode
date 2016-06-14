function data = load_subj001_2016_02_17()
% Combines the fMRI data with stimulus and plotting information, for 
% ease of use

%% Get current data
fmri_fname = 'wl_subj001_2016_02_17';
load(fullfile(rootpath, 'data', 'fMRI_CBI', fmri_fname, 'GLMdenoised', 'roiBetas.mat'));
data = roiBetas;
data.fmri_fname = fmri_fname;

data.stimuli_fname = 'stimuli-2016-02-17.mat';
load(fullfile(rootpath,'data', 'stimuli', data.stimuli_fname), 'stimuli');
data.stimuli = stimuli;

data.title = 'Spatial frequency pilot';
end