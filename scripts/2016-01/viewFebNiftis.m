
%% Load one
datapath = fullfile('/Volumes', 'server', 'Projects', 'SOC', 'data', 'fMRI_CBI', 'wl_subj001_2016_02_17', 'Raw');

epipath{4} = fullfile('04+Single_Shot_epi_2_24sl', '160217112345.nii');
epipath{5} = fullfile('05+Single_Shot_epi_2_24sl', '160217112514.nii');
epipath{6} = fullfile('06+Single_Shot_epi_2_24sl', '160217113054.nii');
%epipath{7} = fullfile('07+Single_Shot_epi_2_24sl', '160217113853.nii');
epipath{8} = fullfile('08+Single_Shot_epi_2_24sl', '160217114141.nii');
epipath{9} = fullfile('09+Single_Shot_epi_2_24sl', '160217114555.nii');
epipath{10} = fullfile('10+Single_Shot_epi_2_24sl', '160217115110.nii');
epipath{11} = fullfile('11+Single_Shot_epi_2_24sl', '160217115537.nii');
epipath{12} = fullfile('12+Single_Shot_epi_2_24sl', '160217120009.nii');
epipath{13} = fullfile('13+Single_Shot_epi_2_24sl', '160217120427.nii');

inplanepath = fullfile('14+cbi_tfl_T1inplane_2_24sl', '+14+cbi_tfl_T1inplane_2_24sl.nii');

for ii = [4,5,6,8,9,10,11,12,13]
    disp(ii)
    %epi{ii} = niftiRead(fullfile(datapath,epipath{ii}));
    disp(size(epi{ii}.data));
end

inplane = niftiRead(fullfile(datapath,inplanepath));
%% View
figure; imshow(epi.data(:,:,12,40), []);
figure; imshow(inplane.data(:,:,12), []);

%% q to xyz
epi.qto_xyz
cal.qto_xyz