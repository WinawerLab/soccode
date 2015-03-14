function test_flatToStack()
%TEST: FLAT TO STACK - test the flatToStack function
    test_frames_nobands()
    test_bands()
    test_unsquare()
end

function test_frames_nobands()
    % Create three categories, two frames, 5*5 (all primes for dim
    % checking), no bands
    im1f1 = (101:125)';
    im1f2 = (151:175)';
    im2f1 = (201:225)';
    im2f2 = (251:275)';
    im3f1 = (301:325)';
    im3f2 = (351:375)';
    
    % Flat size is (X*Y) * (C*F)
    flat(:, 1) = im1f1;
    flat(:, 2) = im1f2;
    flat(:, 3) = im2f1;
    flat(:, 4) = im2f2;
    flat(:, 5) = im3f1;
    flat(:, 6) = im3f2;
    
    stack = flatToStack(flat, 2); % second arg is desired number of frames
    
    % Check size - should be X * Y * C * F
    expectSize = [5, 5, 3, 2];
    assertEqual(size(stack), expectSize);
    
    % Pull out a random entry and check that it's where we expect
    get_im2f1 = stack(:, :, 2, 1);
    reshape_im2f1 = reshape(im2f1, 5, 5);
     
    assertEqual(get_im2f1, reshape_im2f1);
end

function test_bands()
    % Create three categories, two frames, 5*5 (all primes for dim
    % checking), two *bands*
    im1f1b1 = (1:25)';
    im1f1b2 = (-1:-1:-25)';
    im1f2b1 = (51:75)';
    im1f2b2 = (-51:-1:-75)';
    
    im2f1b1 = (101:125)';
    im2f1b2 = (-101:-1:-125)';
    im2f2b2 = (151:175)';
    im2f2b1 = (-151:-1:-175)';
    
    im3f1b1 = (201:225)';
    im3f1b2 = (-201:-1:-225)';
    im3f2b1 = (251:275)';
    im3f2b2 = (-251:-1:-275)';
    
    % Flat size is (X*Y) * (C*F) * B
    flat(:, 1, 1) = im1f1b1;
    flat(:, 1, 2) = im1f1b2;
    flat(:, 2, 1) = im1f2b1;
    flat(:, 2, 2) = im1f2b2;
    flat(:, 3, 1) = im2f1b1;
    flat(:, 3, 2) = im2f1b2;
    flat(:, 4, 1) = im2f2b1;
    flat(:, 4, 2) = im2f2b2;
    flat(:, 5, 1) = im3f1b1;
    flat(:, 5, 2) = im3f1b2;
    flat(:, 6, 1) = im3f2b1;
    flat(:, 6, 2) = im3f2b2;
    
    stack = flatToStack(flat, 2);
    
    % Check size - should be X * Y * C * F * B
    expectSize = [5, 5, 3, 2, 2];
    assertEqual(size(stack), expectSize);
    
    % Pull out a random entry and check that it's where we expect
    get_im2f2b2 = stack(:, :, 2, 2, 2);
    reshape_im2f2b2 = reshape(im2f2b2, 5, 5);
     
    assertEqual(get_im2f2b2, reshape_im2f2b2);
end

function test_unsquare()
    singleim = (1:11)'; % not square
    assertExceptionThrown(@() flatToStack(singleim, 1), 'MATLAB:assertion:failed');
end