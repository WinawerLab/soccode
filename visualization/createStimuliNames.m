%% Augment the existing stimuli names .mat
% imnums 261 to 270
stimuliNamesApr = [repmat({'pilot_waves_sparse'}, 5, 1); ...
 repmat({'pilot_noisebars_sparse'}, 5, 1)];

% imnums 271 to 320
stimuliNamesJun = [repmat({'patterns_sparse'}, 5, 1); ...
 repmat({'gratings_sparse'}, 5, 1); ...
 repmat({'noisebars_sparse'}, 5, 1); ...
 repmat({'waves_sparse'}, 6, 1); ...
 ...
 repmat({'gratings_ori'}, 3, 1); ...
 repmat({'noisebars_ori'}, 3, 1); ...
 repmat({'waves_ori'}, 3, 1); ...
 ...
 repmat({'gratings_cross'}, 4, 1); ...
 ...
 repmat({'patterns_contrast'}, 4, 1); ...
 repmat({'gratings_contrast'}, 4, 1); ...
 repmat({'noisebars_contrast'}, 4, 1); ...
 repmat({'waves_contrast'}, 4, 1)];

%% load, and append, to stimulinames.mat
load(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames');
stimuliNames260 = stimuliNames(1:260);
stimuliNames = [stimuliNames260, stimuliNamesApr', stimuliNamesJun'];
save(fullfile(rootpath, 'code', 'visualization', 'stimuliNames.mat'), 'stimuliNames');

%% Fix mistaken repeat of imnum 260 in the April stimulus set
aprImNums = [176 177 178 179 180
             181 182 183 85 184
             261 262 263 264 265
             266 267 268 269 270];
         
%% Stimuli
stimfile = fullfile(rootpath, 'data', 'stimuli', 'stimuli_2015_04_06.mat');
load(stimfile, 'stimuli');
stimuli.imNums = aprImNums;
stimuli.imNumsDisplay = [177 178 179 182 183 85 262 263 264 267 268 269];
save(stimfile, 'stimuli');

%% Preprocessing
directory = fullfile(rootpath, 'data', 'preprocessing', '2015-05-09');

load(fullfile(directory, 'gaborbandsNewstimuli_b45.mat'), 'gabor');
gabor.imNums = aprImNums;
save(fullfile(directory, 'gaborbandsNewstimuli_b45.mat'), 'gabor');

files = dir(directory);
for ii = 1:length(files)
    f = files(ii);
    if f.isdir; continue; end;
    if length(f.name)>=10 && strcmp(f.name(1:10), 'newstimuli')
        load(fullfile(directory, f.name), 'preprocess')
        preprocess.imNums = aprImNums;
        save(fullfile(directory, f.name), 'preprocess')
        display(ii);
    end
end

%% Fix June stimulus set to start from 271 instead of 270
junImNums = 271:(271+50-1);

%% Stimuli
stimfile = fullfile(rootpath, 'data', 'stimuli', 'stimuli-2015-06-19.mat');
load(stimfile, 'stimuli');
stimuli.imNums = junImNums;
save(stimfile, 'stimuli');

%% Preprocessing
directory = fullfile(rootpath, 'data', 'preprocessing', '2015-09-13');

load(fullfile(directory, 'gaborbandsJunstimuli_b45.mat'), 'gabor');
gabor.imNums = junImNums;
save(fullfile(directory, 'gaborbandsJunstimuli_b45.mat'), 'gabor');

files = dir(directory);
for ii = 1:length(files)
    f = files(ii);
    if f.isdir; continue; end;
    if length(f.name)>=10 && strcmp(f.name(1:10), 'junstimuli')
        load(fullfile(directory, f.name), 'preprocess')
        preprocess.imNums = junImNums;
        save(fullfile(directory, f.name), 'preprocess')
        display(ii);
    end
end



