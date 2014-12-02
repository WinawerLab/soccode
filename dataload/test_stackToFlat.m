function test_stackToFlat()
%TEST: STACK TO FLAT - Test the stackToFlat function
    test_identity()
end

function test_identity()
    % Create three categories, two frames, 5*5 (all primes for dim
    % checking)
    im1f1 = reshape(101:125, 5, 5); 
    im1f2 = reshape(151:175, 5, 5);
    im2f1 = reshape(201:225, 5, 5);
    im2f2 = reshape(251:275, 5, 5);
    im3f1 = reshape(301:325, 5, 5);
    im3f2 = reshape(351:375, 5, 5);
    
    % stack has shape X*Y*C*F
    stack(:, :, 1, 1) = im1f1;
    stack(:, :, 1, 2) = im1f2;
    stack(:, :, 2, 1) = im2f1;
    stack(:, :, 2, 2) = im2f2;
    stack(:, :, 3, 1) = im3f1;
    stack(:, :, 3, 2) = im3f2;
    
    flat = stackToFlat(stack);
    
    % Check size: (X*Y)*(C*F), flat does not distinguish frames
    expectSize = [5*5, 3*2];
    assertEqual(size(flat), expectSize);
    
    % Pull out a random entry and check that it's where we expect
    get_im2f1 = flat(:, 3); % third image
    rebuild_im2f1 = reshape(get_im2f1, 5, 5);
     
    assertEqual(rebuild_im2f1, im2f1);
end