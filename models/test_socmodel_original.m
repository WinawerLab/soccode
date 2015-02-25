function test_socmodel_original()
    test_comparetosaved();
end

function test_comparetosaved()
    % Load the preprocessed divnorm images
    imFile = fullfile(rootpath, 'data/preprocessing/2014-12-04/contrastPointwise.mat');
    load(imFile);
    nFrames = 9;
    imStack = flatToStack(contrastPointwise, nFrames);
    
    % Select test image
    imNum = 85;
    imNumsToUse = [70:173, 175:225];
    imIdx = find(imNumsToUse == imNum, 1);
    imStack = imStack(:, :, imIdx, :);
    imFlat = stackToFlat(imStack);
    
    % Run model to generate predictions
    params = [45 45 5 3 0.5 0.95]; % TODO note the truncated parameters!
    modelfun = wrapmodel(get_socmodel_original(90));
    predictNew = modelfun(params, imFlat);
    
    % For reference/regression testing, the actual current expected predictNew
    % ... Huh, somehow, the "new old" code works this way! OK!!
    predictExpect = [1.3141, 1.3473, 1.4037, 1.2643, 1.2665, 1.3509, 1.3321, 1.3427, 1.4228];
    assertElementsAlmostEqual(predictNew, predictExpect, 'absolute', 10^-4);
end