% 2015-10-21

% Horizontal subject: 022
tmp = load(fullfile(rootpath, 'data', 'fMRI_CBI', 'wl_subj022_2015_06_19', 'GLMdenoised', 'betas.mat'), 'betamn', 'betase', 'roiNames', 'glmr2');
betamn_h = tmp.betamn;
betase_h = tmp.betase;
roiNames_h = tmp.roiNames;
glmr2_h = tmp.glmr2;

% Vertical subject: 001
tmp = load(fullfile(rootpath, 'data', 'fMRI_CBI', 'wl_subj001_2015_10_05', 'GLMdenoised', 'betas.mat'), 'betamn', 'betase', 'roiNames', 'glmr2');
betamn_v = tmp.betamn;
betase_v = tmp.betase;
roiNames_v = tmp.roiNames;
glmr2_v = tmp.glmr2;

% Get stimnames and imrefs squared away!
