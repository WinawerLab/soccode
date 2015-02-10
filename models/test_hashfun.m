function test_hashfun()
    test_speed();
end

function test_speed()
    xy = 180;
    numbands = 8; 
    numims = 100;
    
    imFlat = randn(xy*xy, numims, numbands);
    
    hashfun(imFlat);
end