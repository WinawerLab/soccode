function test_gaborenergy_memoized()
    test_speed()
end

function test_speed()
    
    % Acquire real test images
    imNum = [85, 86]; % pattern space
    imFile = fullfile(rootpath, 'data/input/stimuli.mat');   
    imStack = loadImages(imFile, imNum);
    imStack = resizeStack(imStack, 150, 30);
    imFlat = stackToFlat(imStack);
    
    firstFlat = imFlat(:, 1);
    secondFlat = imFlat(:, 2);
    
    % Get a memoized instance of gaborenergy step
    memgabor = get_gaborenergy_memoized();
    
    % Run model to generate predictions
    tic;
    origOutput = memgabor(firstFlat, 8, 2);
    origTime = toc;
    
    % Run model again
    tic;
    repeatOutput = memgabor(firstFlat, 8, 2);
    repeatTime = toc;
    
    % Run on new image
    tic;
    newOutput = memgabor(secondFlat, 8, 2);
    newTime = toc;
    
    assertTrue(origTime > 100*repeatTime, 'If this fails, try rerunning tests.') % Expect over a 100-fold speedup for repeat images
    assertTrue(origTime < 3*newTime, 'If this fails, try rerunning tests.') % but no speedup, certainly not even twice as fast, for new images
end