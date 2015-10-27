%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation: View predictions on gratings vs patterns, as a bar plot
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Choose categories
gratingNums = 176:180; gratingIdx = 1:5;
patternNums = [181, 182, 183, 85, 184]; patternIdx = 6:10;
horizPatternNums = 261:263; horizPatternIdx = 11:13;
noiseStripeNums = 266:268; noiseStripeIdx = 14:16;

%% Load and resize images
imFile1 = fullfile(rootpath, 'data', 'input', 'stimuli.mat');   
imStack1 = loadImages(imFile, [gratingNums, patternNums]);

imFile2 = fullfile(rootpath, 'data', 'input', 'stimuli_2015_04_06.mat');   
load(imFile2, 'stimuli');
imStack2 = stimuli.imStack(:, :, 7:12, :);

imStack = cat(3, imStack1, imStack2);
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
cat3PredictionsAccumulate = zeros(length(horizPatternNums), 1);
cat4PredictionsAccumulate = zeros(length(noiseStripeNums), 1);

for x = X
    for y = Y        
        params = [R, S, x, y, D, G, N, C];
        display(['Predicting for ', num2str(x), ' and ', num2str(y)]);
        predictions = socmodel_memoized_handle(params, imFlat);
        avgPredictions = squeeze(mean(flatToStack(predictions, 9), 4));

        cat1PredictionsAccumulate = cat1PredictionsAccumulate + avgPredictions(gratingIdx);
        cat2PredictionsAccumulate = cat2PredictionsAccumulate + avgPredictions(patternIdx);
        cat3PredictionsAccumulate = cat3PredictionsAccumulate + avgPredictions(horizPatternIdx);
        cat4PredictionsAccumulate = cat4PredictionsAccumulate + avgPredictions(noiseStripeIdx);
    end
end
cat1Predictions = cat1PredictionsAccumulate / (numel(X)*numel(Y));
cat2Predictions = cat2PredictionsAccumulate / (numel(X)*numel(Y));
cat3Predictions = cat3PredictionsAccumulate / (numel(X)*numel(Y));
cat4Predictions = cat4PredictionsAccumulate / (numel(X)*numel(Y));

%% Plot it
figure; hold on;
bar(gratingIdx(1):gratingIdx(end), cat1Predictions, 'r');
bar(patternIdx(1):patternIdx(end), cat2Predictions, 'b');
bar(horizPatternIdx(1):horizPatternIdx(end), cat3Predictions, 'm');
bar(noiseStripeIdx(1):noiseStripeIdx(end), cat4Predictions, 'c');

ylim([0 3]);
xlimit=get(gca,'xlim');
plot(xlimit,[mean(cat1Predictions), mean(cat1Predictions)], 'r');
plot(xlimit,[mean(cat2Predictions), mean(cat2Predictions)], 'b');
plot(xlimit,[mean(cat3Predictions), mean(cat3Predictions)], 'm');
plot(xlimit,[mean(cat4Predictions), mean(cat4Predictions)], 'c');
legend('Gratings', 'Patterns', 'Horizontal-aperture patterns', 'Noise stripes');

%% My personal predictions before running the above:
% Our model will care only about underlying orientation, not aperture shape
% and thus the windowed squiggles will act like squiggles; the horiz will
% act like gratings
% and the brain will...
% do the same?