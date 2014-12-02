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
    % Create three categories, one frame, 5*5 (all primes for dim
    % checking), two *bands*
    im1b1 = (1:25)';
    im1b2 = (51:75)';
    im2b1 = (101:125)';
    im2b2 = (151:175)';
    im3b1 = (201:225)';
    im3b2 = (251:275)';
    
    % Flat size is (X*Y) * (C*F) * B
    flat(:, 1, 1) = im1b1;
    flat(:, 1, 2) = im1b2;
    flat(:, 2, 1) = im2b1;
    flat(:, 2, 2) = im2b2;
    flat(:, 3, 1) = im3b1;
    flat(:, 3, 2) = im3b2;
    
    % Not yet implemented... hopefully will be someday
    
    assertExceptionThrown(@() flatToStack(flat, 2), 'MATLAB:assertion:failed');
    
%     % Check size - should be X * Y * C * F * B
%     expectSize = [5, 5, 3, 1, 2];
%     assertEqual(size(stack), expectSize);
%     
%     % Pull out a random entry and check that it's where we expect
%     get_im2f1 = stack(:, :, 2, 1, 1);
%     reshape_im2f1 = reshape(im2b1, 5, 5);
%      
%     assertEqual(get_im2f1, reshape_im2f1);
end

function test_unsquare()
    singleim = (1:11)'; % not square
    assertExceptionThrown(@() flatToStack(singleim, 1), 'MATLAB:assertion:failed');
end