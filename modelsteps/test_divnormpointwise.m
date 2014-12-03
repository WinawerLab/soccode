function test_divnormpointwise()
    test_onepixvalues();
    test_manybandsize();
end

function test_onepixvalues()
   ims(1, 1, 1) = 10; % three bands of a single-pixel image
   ims(1, 1, 2) = 1;
   ims(1, 1, 3) = 1;
   
   r = 1;
   s = 6;
   
   expect(1, 1, 1) = 1; % avg=4, plus s=6, makes a denominator of 10   
   expect(1, 1, 2) = 0.1;
   expect(1, 1, 3) = 0.1;
   
   result = divnormpointwise(ims, r, s);
   
   assertElementsAlmostEqual(result, expect, 'absolute', 10^-16); 
end

function test_manybandsize()
    xy = 10;
    numbands = 8; 
    numims = 5;
    
    ims = ones(xy*xy, numims, numbands);
    result = divnormpointwise(ims, 1, 1);
    
    expect = ones(xy*xy, numims, numbands) * 0.5; % point five, because s = 1
    
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16); 
end