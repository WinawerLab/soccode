%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIX the gridsearch
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fixConcatPredictions(datasetNum, voxNum)
%% Dataset

display(['voxNum: ', num2str(voxNum)])

avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 4, 8, 16];

outputdir = fullfile('data','modelfits','2015-05-07',['subj', num2str(datasetNum), '-vox', num2str(voxNum)]);

%% Loop over a and e values and fix concatenated predictions
for a = avals
    for e = evals
        if (a == 0) && (e > 1)
            continue;
        end
        
        %% Load results
        try
        load(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), ...
        'results');
        catch
            disp(['Failed on ', ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']]);
            continue;
        end
        
        %% Concatenate the cross-validated results (and get a *useful* R2!)
        results.concatPredictions = zeros(1, length(results.betamnToUse));
        for fold = 1:length(results.foldImNums)
            imNumsTest = results.foldImNums{fold};
            results.concatPredictions(convertIndex(results.imNumsToUse, imNumsTest)) = results.foldResults(fold).predictions;
        end
        results.concatR2 = computeR2(results.concatPredictions, results.betamnToUse);
        
        %% Save every a and e with its model fit and x-val R^2
        save(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), ...
        'results');
    end
end

end % end function

