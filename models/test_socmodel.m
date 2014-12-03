function test_socmodel()
    test_rejectbadrange();
    test_rejectbadsize();
    test_comparetosaved();
end

function test_rejectbadrange()
    params = [1 0.5 45 45 5 3 0.5 0.95];
    im = reshape(101:125, 5, 5); % Numbers are too high
    assertExceptionThrown(@() socmodel_co(params, im), 'MATLAB:assertion:failed');
end

function test_rejectbadsize()
    params = [1 0.5 45 45 5 3 0.5 0.95];
    im = reshape(linspace(-0.4, 0.4, 20), 5, 4); % Not square
    assertExceptionThrown(@() socmodel_co(params, im), 'MATLAB:assertion:failed');
end

function test_comparetosaved()
    
    % Acquire test image
    imNum = 85; % pattern space, full coverage
    imFile = fullfile(rootpath, 'data/input/stimuli.mat');   
    imStack = loadImages(imFile, imNum);
    imStack = resizeStack(imStack, 150, 30);
    imFlat = stackToFlat(imStack);
    
    % Run model to generate predictions
    params = [1 0.5 45 45 5 3 0.5 0.95];
    predictNew = socmodel_co(params, imFlat);
    
    % Hard-coded "old way" predictions for these images
    % so that this test still runs even if the "old way" becomes defunct.
    % FIXME I do not know, still, why these numbers differ subtly from
    % Kendrick's results.
    predictOrig = [1.3139, 1.3460, 1.4039, 1.2645, 1.2657, 1.3510, 1.3309, 1.3417, 1.4215];
    assertElementsAlmostEqual(predictNew, predictOrig, 'absolute', 10^-2);
    
    % For reference/regression testing, the actual current expected predictNew:
    predictExpect = [1.3141, 1.3473, 1.4037, 1.2643, 1.2665, 1.3509, 1.3321, 1.3427, 1.4228];
    assertElementsAlmostEqual(predictNew, predictExpect, 'absolute', 10^-4);
end