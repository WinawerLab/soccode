%%%%% FIX METADATA by adding metadata that I really wish was there %%%%%%%%

%% Stuff that I keep recomputing that I really ought to save
imNumsDataset = 70:225;

load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames')
catToUse = {'pattern_space', 'pattern_central', 'grating_ori', ...
           'grating_contrast', 'plaid_contrast', 'circular_contrast', ...
           'pattern_contrast', 'grating_sparse', 'pattern_sparse'}; % omit naturalistic and noise space/halves
idxToUse = find(arrayfun(@(idx) strInCellArray(stimuliNames{idx}, catToUse), imNumsDataset));

datasetNum = 9;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');

%% Go through the directories and add it
containingFolder = fullfile(rootpath, 'data', 'modelfits', '2015-05-05');
directories = dir(containingFolder);

for dirIdx = 1:length(directories)
    directory = directories(dirIdx).name;
    if strcmp(directory, '.') || strcmp(directory, '..')
        continue
    end
    
    structs = dir(fullfile(containingFolder, directory));
    
    for structIdx = 1:length(structs);
        structfile = structs(structIdx).name;
        if strcmp(structfile, '.') || strcmp(structfile, '..')
            continue
        end
    
        load(fullfile(containingFolder, directory, structfile), 'results');
        
        results.imNumsDataset = imNumsDataset;
        results.catToUse = catToUse;
        results.datasetIdxToUse = idxToUse;
        results.imNumsToUse = imNumsDataset(idxToUse);
        results.betamnToUse = betamn(results.voxNums, idxToUse);
    
        save(fullfile(containingFolder, directory, structfile), 'results');
    end
end

%%
