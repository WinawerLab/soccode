%% Now let's load their existing fits! Rather than fit them again. Yay.
rois = {'V1', 'V2', 'V3'};
resultsByRoi = cell(1, numel(rois));
for roiIdx = 1:numel(rois)
    whichRoi = rois{roiIdx};
    
    voxelFitIxs = find(roi == find(strcmp(roilabels, whichRoi)));
    
    curr = cd('/mnt/storage/Documents/Dropbox/Research/code/SOC/');
    filenameResults = ['results_', whichRoi, '_all_R=', strrep(num2str(1), '.', 'pt'), '_S=', strrep(num2str(0.5), '.', 'pt'), '.mat'];
    display(['Loading ', filenameResults]);
    loaded = load(fullfile('data/model_fit_results', filenameResults), 'results', 'voxelFitIxs', 'modelfun');
    resultsByRoi{roiIdx} = loaded;
    
    cd(curr);
end

