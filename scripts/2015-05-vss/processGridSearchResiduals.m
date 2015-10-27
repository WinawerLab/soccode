%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Process the results for the grid search on a and e:
%   - Load data for multiple a and e values, and compare *on the specific
%   categories*!
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function residuals = processGridSearchResiduals(a, e, datasetNum, voxNums)

%% Prepare the data
dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');

%%
residuals = ones(108, length(voxNums)); % pardon the magic number
residuals = residuals * NaN;

for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];
    

    filename = ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat'];
    try
        % Get the saved cross-validated parameters
        % (This might fail. If it does, it's no problem at all.)
        load(fullfile(dataloc, folder, filename));
    catch
        disp(['Failed on ', filename]);
        continue;
    end
    
    residuals(:, voxIdx) = results.concatPredictions - results.betamnToUse;
end
end

