function [imNumsToUse, betamnToUse, voxNums] = loadDataset(n, whichVoxs)
% LOAD DATASET: Encapsulates a common motif in scripts, of loading
% a dataset, and selecting certain voxels and images
%
%   n - an integer from 1 to 5, indicating which dataset to use
%   whichVoxs - either a vector of numbers, indicating which voxel numbers
%       to use, *or* a string indicating which visual area to load voxels
%       from (e.g. 'V1'). If empty, load a single demo voxel.

    if nargin < 1
        n = 3;
    end
    if nargin < 2
        voxNums = 33; % demo voxel
    end
    
    dataset = ['dataset', num2str(n, '%02d'), '.mat'];
    load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase','roi','roilabels');
    
    if isinteger(whichVoxs)
        voxNums = whichVoxs;
    elseif ischar(whichVoxs)
        roiNum = find(strcmp(roilabels, whichVoxs));
        voxNums = find(roi == roiNum);
    else
        assert(false, 'whichVoxs must be a vector of integers for voxel indices, or a string of which visual area')
    end
 
    
    % Which images are in the dataset?    
    if n==1 || n==2
        imNumsDataset = 1:69;
        imNumsToUse = 1:69;
    elseif n==3 || n==4
        imNumsDataset = 70:225;
        imNumsToUse = [70:173, 175:225]; %skip the category with only 7 frames
    elseif n==5
        imNumsDataset = 226:260;
        imNumsToUse = 226:260;
    end
  
    % Extract the relevant voxel and images
    betamnIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);
    betamnToUse = betamn(voxNums, betamnIdx);

end