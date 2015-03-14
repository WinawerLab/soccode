function test_nonlinearity()
    test_scalar();
    test_oneim();
    test_randdata();
end

function test_scalar()
    scalar = 5;
    
    n = 2;
    g = 0.5;
    
    result = nonlinearity(scalar, g, n);
    expect = 12.5;
    
    assertEqual(result, expect);
end

function test_oneim()
    ims = [-2 -1 -0.5 0 0.5 1 2];
    
    n = 2;
    g = 0.5;
    
    result = nonlinearity(ims, g, n);
    expect = g * (ims.^n);
    
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16);
end

function test_randdata()
    xy = 10;
    numbands = 8; 
    numims = 5;
    
    ims = randn(xy*xy, numims, numbands);
    
    n = randn();
    g = randn();
    
    result = nonlinearity(ims, g, n);
    expect = g * (ims.^n);
    
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16);
end