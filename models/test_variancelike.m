function test_variancelike()
    test_size()
    test_values_easyc()
    test_values_hardc()
    test_dim_mismatch();
end

function test_size()
    xy = 10;
    nims = 5;
    bands = 4;
    c = 1;
    
    ims = ones(xy*xy, nims, bands);
    wt = ones(xy*xy, 1);
    result = variancelike(ims, wt, c);
    expectSize = [xy*xy, nims, bands];
    
    assertEqual(size(result), expectSize);
end

function test_values_easyc()
    ims = [5; 1; 2; 5];
    wt = [0; 0.5; 0.5; 0]; % avg of middle two is 1.5
    c = 1;
    
    expect = [3.5; -0.5; 0.5; 3.5].^2;
    result = variancelike(ims, wt, c);
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16);
end

function test_values_hardc()
    ims = [5; 1; 2; 5];
    wt = [0; 0.5; 0.5; 0]; % avg of middle two is 1.5
    c = 0.2; % weighted average is 0.3
    
    expect = [4.7; 0.7; 1.7; 4.7].^2;
    result = variancelike(ims, wt, c);
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16);
end

function test_dim_mismatch()
    xy = 10;
    nims = 5;
    bands = 4;
    c = 1;
    
    ims = ones(xy*xy, nims, bands);
    wt = ones(xy*xy + 1, 1); % wrong size
   
    assertExceptionThrown(@() variancelike(ims, wt, c), 'MATLAB:assertion:failed');
end