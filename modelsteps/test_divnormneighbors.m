function test_divnormneighbors()
    test_manybandsize();
    % VERY weak test, needs more tests!
end

function test_manybandsize()
    xy = 10;
    numbands = 8; 
    numims = 5;
    
    ims = ones(xy*xy, numims, numbands);
    result = divnormneighbors(ims, 1, 1, 3);
    
    expectSize = [xy*xy, numims, numbands];
    assertEqual(size(result), expectSize);
end