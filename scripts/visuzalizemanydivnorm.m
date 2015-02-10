%% THIS IS THE NEW PART

load('/mnt/storage/Documents/Dropbox/Research/code/SOC-new/data/modelfits/2014-12-04/tzeroresults.mat');

t = 1;

params = results{1}.params;

%% Load and resize preprocessed contrast images for this t, again
name = ['contrastNeighbors', strrep(num2str(t), '.', 'pt'), '.mat'];
load(fullfile(inputdir, name));
imStack = flatToStack(contrastNeighbors, 9);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);

%% Compute actual results here
modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
for frame=1:size(imToUse,3)
    modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
end
modelPredictionsAvg = mean(modelPredictionsByFrame, 2);

%% Now show them!
figure;
setfigurepos([100 100 450 250]);
hold on;
bar(betamnToUse,1);
plot(modelPredictionsAvg,'ro','LineWidth',3);

ylabel('BOLD signal (% change)');
title('Data and model fit');