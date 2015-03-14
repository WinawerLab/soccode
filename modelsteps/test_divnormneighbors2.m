function test_divnormneighbors2()
    test_manybandsize();
    test_values();
end

function test_manybandsize()
    xy = 10;
    numbands = 8; 
    numims = 5;
    
    imFlat = ones(xy*xy, numims, numbands);
    result = divnormneighbors2(imFlat, 1, 0.5, 0.5, 2);
    
    expectSize = [xy*xy, numims, numbands];
    assertEqual(size(result), expectSize);
end

function test_values()
    % Choose some particular values; compare result with
    % a hand-computed expected result
    bands = [];
    bands(:, :, 1, 1, 1) = magic(6);
    bands = bands(1:5, 1:5, :);
    bands(:, :, 1, 1, 2) = magic(5);
    imFlat = stackToFlat(bands);

    r = 1;
    s = 0.5;
    a = 0.5;
    e = 1;
    result = divnormneighbors2(imFlat, r, s, a, e);
    result = flatToStack(result);
    
    % values at the center of the first band
    center = 2;
    pointavg = 7.5; % That's 15/2
    neighavg = 21.125; % That's 169/8
    
    expect = 0.135; % That's 2 / (0.5 + 7.5/2 + 21.125/2)
    
    assertEqual(result(3, 3, 1, 1, 1), expect);
    
end