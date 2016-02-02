function [predictionsOTS, predictionsSOC] = generateCachedV1V2Predictions(imOTS, imSOC, pprcss, paramLoc, modelfun)

    %% Create predictions on these stimuli
    datasetNum = 4;
    fitRois = {'V1', 'V2'};
    voxNums = {};
    voxNums{1} = [167,44,100,308,172,17,171,84,101,16,...
                77,71,92,86,58,67,78,179,469,40]; % Twenty V1 voxels
    voxNums{2} = [94,200,619,190,105,204,191,309,274,746, ...
        90,243,472,152,322,473,566,254,457,314]; % Twenty V2 voxels

    for roi = 1:length(fitRois)
        predictionsSOC{roi} = NaN*ones(length(voxNums{roi}), size(imSOC, 1));
        predictionsOTS{roi} = NaN*ones(length(voxNums{roi}), size(imOTS, 1));

        for voxIdx = 1:length(voxNums{roi})
            voxNum = voxNums{roi}(voxIdx);
            folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

            % Old
            try
                filename = ['aegridsearch-a', num2str(pprcss.aOld), '-e', num2str(pprcss.eOld), '-subj', num2str(datasetNum), '.mat'];
                load(fullfile(paramLoc, folder, filename), 'results');
            catch
                disp('oops, one of the files was not found')
                continue;
            end

            predictions = zeros(length(results.foldImNums), size(imSOC, 1));
            for fold = 1:length(results.foldImNums)
                params = results.foldResults(fold).params;
                predictions(fold, :) = predictResponses(imSOC, params, modelfun);
            end
            predictionsSOC{roi}(voxIdx, :) = mean(predictions, 1);

            % New
            try
                filename = ['aegridsearch-a', num2str(pprcss.aNew), '-e', num2str(pprcss.eNew), '-subj', num2str(datasetNum), '.mat'];
                load(fullfile(paramLoc, folder, filename), 'results');
            catch
                disp('oops, one of the files was not found')
                continue;
            end

            predictions = zeros(length(results.foldImNums), size(imOTS, 1));
            for fold = 1:length(results.foldImNums)
                params = results.foldResults(fold).params;
                predictions(fold, :) = predictResponses(imOTS, params, modelfun);
            end
            predictionsOTS{roi}(voxIdx, :) = mean(predictions, 1);
        end
    end
end
