function predictions = predictResponses(imToUse, params, modelfun)
    modelPredictionsByFrame = zeros(size(imToUse, 1), size(imToUse, 3));
    for frame=1:size(imToUse,3)
        modelPredictionsByFrame(:,frame) = modelfun(params, imToUse(:,:,frame));
    end
    predictions = mean(modelPredictionsByFrame, 2)';
end

