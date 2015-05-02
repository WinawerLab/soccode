%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exploration: How is the fitting procedure currently operating?
%   Is it behaving well? Do we want it to do something else?
% 
%   Work with the fits for one voxel; examine reseed consistency
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Acquire dataset and demo voxel
datasetNum = 3;
dataset = ['dataset', num2str(datasetNum, '%02d'), '.mat'];
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase', 'roi', 'roilabels');
% betamn is 1323 voxels * 156 betamn values

imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames
betamnIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);

%% Pick a demo voxel
voxNum = 78; % a V1 voxel with good SNR
fh = setupBetaFig();
bar(betamn(voxNum, :));
addXlabels(imNumsToUse);

betamnToUse = betamn(voxNum, betamnIdx);

%% Ok now we gotta get all the images... in some acceptable format
% (This will be more useful when doing grid search)
r = 1;
s = 0.5;
avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 3, 4, 8, 12, 16];

inputdir = 'data/preprocessing/2015-03-11';

imCell = cell(length(avals), length(evals));
for aIdx = 1:length(avals)
    for eIdx = 1:length(evals)
        imname = ['divnormbands_r', strrep(num2str(r), '.', 'pt'), ...
                              '_s', strrep(num2str(s), '.', 'pt'), ...
                              '_a', strrep(num2str(avals(aIdx)), '.', 'pt'), ...
                              '_e', strrep(num2str(evals(eIdx)), '.', 'pt')];
        load(fullfile(rootpath, inputdir, imname));
        
        imStack = flatToStack(preprocess.contrast, 9);
        imPxv = stackToPxv(imStack);
        imToUse = permute(imPxv, [2 1 3]);
        
        imCell{aIdx, eIdx} = imToUse;
    end
end

%% Now we gotta fit it!
modelfun = get_socmodel_original(90);
%results = modelfittingOTS(modelfun, betamnToUse, imCell);
    % Still under construction

%% What do we get with an a=1, e=4?
results = modelfittingContrastIm(modelfun, betamnToUse, imCell{5, 4});

%% Logging manually the results of one run of the above, for all 16
% re-seeds:
reseedsA1E4 = [ 47.890,  0.941, 2.018, 4.413, 0.102, 0.400; ...
                51.907, -2.151, 6.479, 2.519, 0.146, 1.069; ...
                46.493, 30.077, 1.571, 1.707, 0.163, -0.162; ...
                51.407,  1.419, 9.068, 2.480, 0.241, -0.902; ...
                45.162, 11.763, 0.637, 2.623, 0.149, 0.912; ...
                46.790, 25.665, 1.738, 1.623, 0.167, -0.158; ...
                46.238, 28.284, 0.983, 2.284, 0.128, 0.881; ...
                47.990, 23.073, 1.530, 2.110, 0.165, 0.759; ...
                50.368,  8.240, 8.174, 2.316, 0.300, 0.400; ...
                46.993, 30.477, 1.804, 2.509, 0.235, 0.710; ...
                51.504, 16.751, 5.394, 2.564, 0.300, 0.901; ...
                56.452, 17.764, 7.229, 2.445, 0.307, 0.950; ...
                46.798, 29.799, 2.224, 2.365, 0.256, 0.615; ...
                51.645, 22.967, 6.949, 3.038, 0.508, 0.623; ...
                52.963, 21.121, 6.931, 3.320, 0.493, 0.728; ...
                53.485, 17.999, 7.358, 3.063, 0.436, 0.897 ];
       

%% What do we get with an a=0, the original way basically?
resultsOriginal = modelfittingContrastIm(modelfun, betamnToUse, imCell{1, 4});

%% Logging manually the results for a=0
reseedsA0 =   [ 46.659  29.144  1.367 1.604 0.124 -0.044; ...
                52.772  16.185  4.530 2.137 0.193 1.280; ...
                45.772  13.412  0.429 2.691 0.126 1.003; ...
                 8.712 -40.838 15.997 8.352 0.189 1.079; ...
                55.658  -2.033  5.669 2.708 0.133 1.254; ...
                46.479  22.068  0.955 1.821 0.100 0.700; ...
                48.489  15.534  1.949 2.276 0.153 0.916; ...
                49.129  19.011  1.965 2.117 0.145 0.849; ...
                47.120  30.590  1.296 2.363 0.166 0.811; ...
                51.025  24.302  4.348 2.484 0.300 0.700; ...
                50.854  23.324  3.696 2.094 0.217 0.668; ...
                54.869  20.824  5.488 2.759 0.292 0.937; ...
                49.366  26.561  3.267 2.527 0.268 0.763; ...
                53.056  25.740  9.702 2.822 0.500 0.700; ...
                52.947  21.779  6.490 2.987 0.413 0.822; ...
                54.030  22.641  7.954 3.510 0.499 0.950 ];
                
                
%% Create full predictions from reseeded parameters

predictionsA0 = [];
imToUse = imCell{1, 4};

for i = 1:size(reseedsA0, 1)
    params = reseedsA0(i, :);
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    modelPredictionsAvg = mean(modelPredictionsByFrame, 2);
    predictionsA0(i, :) = modelPredictionsAvg;
end

actual = betamnToUse;
guesses = predictionsA0;
ss_tot = sum((actual - mean(actual)).^2); % one number
ss_exp = sum((guesses - mean(actual)).^2, 2); % sixteen numbers
ss_res = sum(bsxfun(@minus, actual, guesses).^2, 2); % sixteen numbers
r2_A0 = 1 - ss_res./ss_tot;

[r2_A0,i_A0] = sort(r2_A0);
predictionsA0 = predictionsA0(i_A0, :);
predictionsA0 = predictionsA0(end-4:end, :); % drop all but the best four


% And again for the A=1, E=4 results

predictionsA1E4 = [];
imToUse = imCell{5, 4};

for i = 1:size(reseedsA1E4, 1)
    params = reseedsA1E4(i, :);
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    modelPredictionsAvg = mean(modelPredictionsByFrame, 2);
    predictionsA1E4(i, :) = modelPredictionsAvg;
end

actual = betamnToUse;
guesses = predictionsA1E4;
ss_tot = sum((actual - mean(actual)).^2); % one number
%ss_exp = sum((guesses - mean(actual)).^2, 2); % sixteen numbers
ss_res = sum(bsxfun(@minus, actual, guesses).^2, 2); % sixteen numbers
r2_A1E4 = 1 - ss_res./ss_tot;

[r2_A1E4,i_A1E4] = sort(r2_A1E4);
predictionsA1E4 = predictionsA1E4(i_A1E4, :);
predictionsA1E4 = predictionsA1E4(end-4:end, :);

%% Plot stuff

% Beta bars and setup
setupBetaFig()
bar(betamnToUse);
ylabel('BOLD signal (% change)');
title('Data and model fit, A=0');
addXlabels(imNumsToUse);

% Individual lines with gradated colors
hold all;
colorset = flipud(hot());
colorsToUse = zeros(size(predictionsA0, 1), 3);
for ii = 1:size(predictionsA0, 1);
    colorIdx = floor((size(colorset,1)-1) * (ii/size(predictionsA0, 1))) + 1;
    colorsToUse(ii, :) = colorset(colorIdx, :);
end
set(gca, 'ColorOrder', colorsToUse);

h=plot(predictionsA0','LineWidth',2);
legend(h, num2str(r2_A0));


%% 
setupBetaFig()
bar(betamnToUse);
ylabel('BOLD signal (% change)');
title('Data and model fit, A=1 E=4');
addXlabels(imNumsToUse);
hold all;

colorset = flipud(hot());
colorsToUse = zeros(size(predictionsA1E4, 1), 3);
for ii = 1:size(predictionsA1E4, 1);
    colorIdx = floor((size(colorset,1)-1) * (ii/size(predictionsA1E4, 1))) + 1;
    colorsToUse(ii, :) = colorset(colorIdx, :);
end
set(gca, 'ColorOrder', colorsToUse);

h=plot(predictionsA1E4','LineWidth',2);
legend(h, num2str(r2_A1E4));

%% Just out of curiousity... what are some normal values of G, the gain?
load(fullfile(rootpath, 'data', 'modelfits', '2014-06-24', 'results_V1_all_R=1_S=0pt5.mat'));
figure; hist(squeeze(results.params(:, 4, :)))

%% What if we fit just the pRF at one time?
modelfittingPrfOnly(modelfun, betamnToUse, imCell{1, 4});

%% Results
% These actually seem OK
resultsPrf =   [51.827 20.480 6.260 3.629 0.500 0.900; ... % best R^2
                50.261 20.929 6.804 3.533 0.500 0.900; ...
               % 18.121 38.560 22.960 2.270 0.500 0.900; ...
               % 14.384 -0.692 18.552 4.118 0.500 0.900; ...
                49.833 19.578 6.837 3.375 0.500 0.900; ...
                54.274 22.591 7.435 3.553 0.500 0.900; ...
                52.035 20.894 6.697 3.519 0.500 0.900; ...
                53.521 23.311 7.701 3.534 0.500 0.900; ...
                52.498 21.656 7.061 3.535 0.500 0.900; ...
                53.764 22.886 7.000 3.679 0.500 0.900; ...
                53.514 23.375 7.478 3.369 0.500 0.900; ...
                50.773 20.851 7.484 3.365 0.500 0.900; ...
              %  62.742 11.570 17.074 2.747 0.500 0.900; ...
                50.939 20.545 6.509 3.566 0.500 0.900; ...
              %  64.164 27.490 14.713 2.511 0.500 0.900; ...
                55.456 23.632 7.950 3.314 0.500 0.900];

%% For comparison what if we use only the "space" stimuli?
load(fullfile(rootpath, 'code/visualization/stimuliNames.mat'), 'stimuliNames');
xlabels = stimuliNames(imNumsToUse);

idxSpace = strcmp(xlabels, 'pattern_space');
modelfittingPrfOnly(modelfun, betamnToUse(:, idxSpace), imCell{1, 4}(idxSpace, :, :));

% This did NOT go as well! At all!

%% What if we blur them?
spaceIm ages = imCell{1,4}(idxSpace,:,:);
% TODO start here

%% What if we leave out a random 10%?
n = length(betamnToUse);
randIdx = logical([ones(1, floor(n*0.9)), zeros(1, ceil(n*0.1))]);
randIdx = randIdx(randperm(length(randIdx)));

%% Get the PRF
results = modelfittingPrfOnly(modelfun, betamnToUse(:, randIdx), imCell{1, 4}(randIdx, :, :));

% This really does totally fine. A bit choppier, but not really a problem
% finding it with the right seed!

% And if we seed from G=2, not G=10, does G move?? ... no!
% As for G =8... even worse? or just a bad set of indices?
% Ok, don't mess with G=10... but gyeah =/

%% Now use the PRF, get the rest
xydg = results.params(1:4);
results = modelfittingGivenPrf(modelfun, betamnToUse(:, randIdx), imCell{1, 4}(randIdx, :, :), xydg);

% This is very stable... but it also stays really close to the existing
% seeds
% e.g. [52.692 20.889 6.466 3.562 0.483 0.889] given seeds 0.5 and 0.9 for
% last two. Let's try *different* seeds!

% ok, now I get [48.927 28.672 3.064 2.502 0.286 0.728] given 0.3 and 0.7
% so... it definitely didn't work

% lemme just go seed with all that and see?

% also, for future reference, all this is with zeros at
% [23 54 55 61 63 64 76 78 79 84 88 96 98 115 129 144]

%% Do a CSS model fit on *just* the contrast images
modelcss = get_socmodel_original(90);
%results = modelfittingOTS(modelfun, betamnToUse, imCell);
    % Still under construction