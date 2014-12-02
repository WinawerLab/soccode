function test_loadImages()
% TEST: LOAD IMAGES - Test the loadImages() function

    fullfile(rootpath, 'data/input/stimuli.mat');
    test_outputDims();
end

function test_outputDims()

    imPath = fullfile(rootpath, 'data/input/stimuli.mat');
    imNums = 1:5;
    
    images = loadImages(imPath, imNums);
    
    assertEqual(size(images), [600, 600, 5, 30]);
end