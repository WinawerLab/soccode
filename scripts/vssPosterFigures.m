%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% VSS Analysis, all in one place! Easy to run, easy to find! %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading the data!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

imNumsDataset = 70:225;
catKeep = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', ... % skip naturalistic ...
           'grating_sparse', 'pattern_sparse'}; % skip noise space/halves
           
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames');

% TODO: not complete; go to trainTestSubset.m

%% ECoG
electrodes=[108 109 115 120 121 107];
[ecog_vals, ecog_errs] = loadEcogBroadband(electrodes);

%% View the ECoG images
ims = load(fullfile(rootpath, 'data', 'input', 'ecog_datasets', 'socforecog.mat'));

figure;
for ii = 60:size(ims.stimuli, 3)
    imshow(ims.stimuli(:,:,ii));
    pause(1);
end