%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Leave-out-out cross-validation for a given A and E
% REDO IT if some are missing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function redoGridSearchAandE(datasetNum, voxNum, datefolder)


%% Set up the inputs and outputs for model fitting
r = 1;
s = 0.5;
avals = [0.25, 0.5, 0.75, 1];
evals = [1, 2, 4, 8, 16];

outputdir = ['data/modelfits/', datefolder, '/vox', num2str(voxNum)];
disp(voxNum);

%% Load the 'main' results as the central repository to replenish all else
load(fullfile(rootpath, outputdir, ['aegridsearch-a0-e1', '-subj', num2str(datasetNum), '.mat']), 'results');
mainResults = results;

%% Loop over a and e values and run folds
for a = avals
    for e = evals
        
        if exist(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), 'file')
            disp(['Already exists for a=', num2str(a), ' e=', num2str(e)]);
            continue
        end
        disp(['Redoing for a=', num2str(a), ' e=', num2str(e)]);
        
        %% Load the images
        [inputdir,name,ext] = fileparts(mainResults.inputImages);
        [imAll, imFileName, imNumsLoad] = loadOneDivnormIm(inputdir, r, s, a, e);

        %% Set up a results struct
        results = {};
        results.voxNums = mainResults.voxNums;
        results.dataset = mainResults.dataset;
        results.modelfun = mainResults.modelfun;
        results.inputImages = fullfile(inputdir, imFileName);
        results.r = r;
        results.s = s;
        results.a = a;
        results.e = e;
        results.foldImNums = mainResults.foldImNums;
        results.foldResults = struct([]);
        results.imNumsDataset = mainResults.imNumsDataset;
        results.catToUse = mainResults.catToUse;
        results.datasetIdxToUse = mainResults.datasetIdxToUse;
        results.imNumsToUse = mainResults.imNumsToUse;
        results.betamnToUse = mainResults.betamnToUse;
        
        nFolds = length(mainResults.foldImNums);
        modelfun = eval(results.modelfun);
        
        %% Run all 10 folds of this a/e
        for fold = 1:nFolds
            allFolds = 1:nFolds;
            trainFolds = allFolds ~= fold;
            imNumsTrain = [results.foldImNums{trainFolds}];
            imNumsTest = results.foldImNums{fold};
            
            imTrain = imAll(convertIndex(imNumsLoad, imNumsTrain), :, :);
            imTest = imAll(convertIndex(imNumsLoad, imNumsTest), :, :);
            
            betamnTrain = results.betamnToUse(:, convertIndex(results.imNumsToUse, imNumsTrain));
            betamnTest = results.betamnToUse(:, convertIndex(results.imNumsToUse, imNumsTest));
            
            tempResults = modelfittingContrastIm(modelfun, betamnTrain, imTrain);
            results.foldResults(fold).params = tempResults.params;
            results.foldResults(fold).foldNumber = fold;
            results.foldResults(fold).imNumsTrain = imNumsTrain;
            results.foldResults(fold).imNumsTest = imNumsTest;
            
            predictions = predictResponses(imTest, results.foldResults(fold).params, modelfun);
            useThisMean = mean(betamnToUse);    
            [r2test, ~, ss_res, ss_tot] = computeR2(predictions, betamnTest, useThisMean);
            
            results.foldResults(fold).predictions = predictions;
            results.foldResults(fold).r2test = r2test;
            results.foldResults(fold).ss_res = ss_res;
            results.foldResults(fold).ss_tot = ss_tot;
        end
        
        %% Concatenate the cross-validated results (and get a *useful* R2!)
        results.concatPredictions = zeros(1, length(results.betamnToUse));
        for fold = 1:length(results.foldImNums)
            imNumsTest = results.foldImNums{fold};
            results.concatPredictions(convertIndex(results.imNumsToUse, imNumsTest)) = results.foldResults(fold).predictions;
        end
        results.concatR2 = computeR2(results.concatPredictions, results.betamnToUse);
        
        
        %% Here's another way that I hope computes the same thing
        accumSSres = 0;
        accumSStot = 0;
        for fold = 1:nFolds
            accumSSres = accumSSres + results.foldResults(fold).ss_res;
            accumSStot = accumSStot + results.foldResults(fold).ss_tot;
        end
        results.accumR2 = 1 - accumSSres / accumSStot;
        
        %% Save every a and e with its model fit and x-val R^2
        save(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), ...
        'results');
    end
end

end % end function

