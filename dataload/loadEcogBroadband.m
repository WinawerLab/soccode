function [ecog_vals, ecog_errs] = loadEcogBroadband(electrodes)
% Set of electrodes from Dora:
%   electrodes=[108 109 115 120 121 107];

load(fullfile(rootpath, 'data', 'input', 'ecog_datasets', 'TVD_resamp_stats_V2'),'resamp_parms');

load(fullfile(rootpath, 'data', 'input', 'ecog_datasets', 'TVD_erp_parms_V2'));
% This is 116 * 86 * 100 * 3
% 116: number of electrodes
% 86: number of stimulus classes
% 100: ?
% 3: ERP, BB, and Gamma
nstim = size(erp_parms, 2);

load(fullfile(rootpath, 'data', 'input', 'ecog_datasets', 'TVD_otherinfo'),'chan_lbls','srate','t','f');
% chan_lbls holds the allowable electrodes

% Which component of the signal to load?
ecog_use=1; 
% 1 - broadband 
% 2 - gamma 
% 3 - erp 
% 4 - broadband + gamma 
% 5 - broadband power

ecog_vals = zeros(length(electrodes), nstim);
ecog_errs = zeros(length(electrodes), nstim, 2); % lower and upper

for el=1:length(electrodes)
    electr=electrodes(el);
    make_plot = false;
    [ecog_vals_channel,ecog_err_channel]=get_ecog_vals(electr,ecog_use,erp_parms,resamp_parms,chan_lbls,make_plot);
    
    ecog_vals(el, :) = ecog_vals_channel;
    ecog_errs(el, :, :) = ecog_err_channel;
end

% What are the image classes?
% 1:38 - 'space'
% 39:46 - 'orie' orientation
% 47:50 - 'grat' grating
% 51:54 - 'pl' plaid
% 55:58 - 'circ' circular
% 59:68 - 'zcon' zebra contrast
% 68:73 - 'sp' sparse grating
% 74:78 - 'zsp' zebra sparse
% 79:82 - 'coh' NEW, variable coherence
% 82:86 - 'nm' NEW, superimposed noise and zebra

end