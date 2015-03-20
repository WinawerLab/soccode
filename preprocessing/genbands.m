%% Choose only images from dataset 3
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames

%% Load gabor images (huge time-saver!)
inputfile = 'data/preprocessing/2014-12-04/gaborBands.mat';
load(fullfile(rootpath, inputfile), 'gaborBands');

%% Continue with contrast images
outputdir = fullfile(rootpath, ['data/preprocessing/', datestr(now,'yyyy-mm-dd')]);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

%% Do the preprocessing
rvals = [0.25, 0.5, 1, 1.5, 2, 4];
svals = [0.125, 0.25, 0.5, 0.75, 1, 2];
avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 3, 4, 8, 12, 16];

for r = rvals
    for s = svals
        for a = avals
            for e = evals
                disp(['Starting neighbor divnorm ', num2str(r), ' ', num2str(s), ' ', num2str(a), ' ', num2str(e)]);
                
                %tic;
                preprocess = {};
                preprocess.bands = divnormneighbors2(gaborBands, r, s, a, e);
                preprocess.contrast = sum(preprocess.bands, 3);
                preprocess.r = r;
                preprocess.s = s;
                preprocess.a = a;
                preprocess.e = e;
                preprocess.function = 'divnormneighbors2(gaborBands, r, s, a, e)';
                preprocess.inputImages = inputfile;
                preprocess.imNums = imNumsToUse;
                preprocess.nFrames = 9; % number of frames per category in this dataset
                
                name = ['divnormbands_r', strrep(num2str(r), '.', 'pt'),...
                                    '_s', strrep(num2str(s), '.', 'pt'),...
                                    '_a', strrep(num2str(a), '.', 'pt'),...
                                    '_e', strrep(num2str(e), '.', 'pt'), '.mat'];
                save(fullfile(outputdir, name), 'preprocess');
                %toc;
                % Roughly 14 seconds for one batch of 1395 images
            end
        end
    end
end