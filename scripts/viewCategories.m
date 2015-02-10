%% Acquire a dataset
dataset = 'dataset03.mat';
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase');
imNumsDataset = 70:225;

%% Choose categories
gratingNums = 176:180; gratingIdx = 1:5;
patternNums = 181:184; patternIdx = 6:9;

%% Load and resize images
imFile = fullfile(rootpath, 'data/input/stimuli.mat');   
imStack = loadImages(imFile, [gratingNums, patternNums]);
imStack = resizeStack(imStack, 150, 30);
imFlat = stackToFlat(imStack);

%% Make a memgabor
memgabor = get_gaborenergy_memoized();

%% Get a memoized model
% socmodel_memoized_handle = get_socmodel_surround(memgabor);
socmodel_memoized_handle = get_socmodel_memgabor(memgabor);
    
%% Make predictions with a set of reasonable parameters
R = 1; S = 0.5;

X = [25, 45, 65]; % Average over a few receptive field locations
Y = [25, 45, 65];

D = 2;
G = 3;
N = 0.5;
C = 0.95;

% Average over a few receptive field locations
cat1PredictionsAccumulate = zeros(length(gratingNums), 1);
cat2PredictionsAccumulate = zeros(length(patternNums), 1);

for x = X
    for y = Y        
        params = [R, S, x, y, D, G, N, C];
        display(['Predicting for ', num2str(x), ' and ', num2str(y)]);
        predictions = socmodel_memoized_handle(params, imFlat);
        avgPredictions = squeeze(mean(flatToStack(predictions, 9), 4));

        cat1PredictionsAccumulate = cat1PredictionsAccumulate + avgPredictions(gratingIdx);
        cat2PredictionsAccumulate = cat2PredictionsAccumulate + avgPredictions(patternIdx);
    end
end
cat1Predictions = cat1PredictionsAccumulate / (numel(X)*numel(Y));
cat2Predictions = cat2PredictionsAccumulate / (numel(X)*numel(Y));

%% Plot it
figure; hold on;
bar(1:numel(gratingIdx), cat1Predictions, 'r');
bar(numel(gratingIdx)+1:numel(gratingIdx)+numel(patternIdx), cat2Predictions, 'b');
ylim([0 3]);
xlimit=get(gca,'xlim');
plot(xlimit,[mean(cat1Predictions), mean(cat1Predictions)], 'r');
plot(xlimit,[mean(cat2Predictions), mean(cat2Predictions)], 'b');
legend('Gratings', 'Patterns');