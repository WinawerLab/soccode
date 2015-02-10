%% Choose only images from dataset 3
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames

%% Load and resize images
imFile = fullfile(rootpath, 'data/input/stimuli.mat');   
imStack = loadImages(imFile, imNumsToUse);
imStack = resizeStack(imStack, 150, 30);
imFlat = stackToFlat(imStack);

%% Produce gabor images
outputdir = fullfile(rootpath, ['data/preprocessing/', datestr(now,'yyyy-mm-dd')]);
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

gaborBands = gaborenergy(imFlat, 8, 2);
save(fullfile(outputdir, 'gaborBands.mat'), 'gaborBands');

%% Continue with contrast images
tic; display('Starting regular divnorm')
divnorm_output = divnormpointwise(gaborBands, 1, 0.5);
contrastPointwise = sum(divnorm_output, 3);
save(fullfile(outputdir, 'contrastPointwise.mat'), 'contrastPointwise');
toc;

for t = [0 0.001 0.1 1.0 10.0 100.0 1000.0] % zero is just a check
    tic;
    disp(['Starting neighbor divnorm ', num2str(t)]);
    divnorm_output = divnormneighbors(gaborBands, 1, 0.5, t);
    contrastNeighbors = sum(divnorm_output, 3);
    name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
    save(fullfile(outputdir, name), 'contrastNeighbors');
    toc;
end

%% Visualize them
ixs = arrayfun(@(x) find(imNumsToUse == x,1,'first'), [176:180, 181:184]);
show = [];
for t = [NaN 0 0.001 0.1 1.0 10.0 100.0 1000.0]
    if isnan(t)
        name = 'contrastPointwise.mat';
        load(fullfile(outputdir, name));
        contrastStack = flatToStack(contrastPointwise, 9);
    else
        name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
        load(fullfile(outputdir, name));
        contrastStack = flatToStack(contrastNeighbors, 9);
    end
    row = reshape(contrastStack(:,:,ixs,1), 90, 90*9);
    show = [show; row];
end
figure; imshow(show, []);