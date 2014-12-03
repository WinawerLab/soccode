function test_resizeStack()
    test_values();
    test_size();
end

function test_values()
    % Create two images, 5*5
    im1 = reshape(101:125, 5, 5); 
    im2 = reshape(301:325, 5, 5);    
    stack(:, :, 1) = im1;
    stack(:, :, 2) = im2;
    
    % Resize, truncate, pad
    sz = 3;
    padding = 1;
    resized = resizeStack(stack, sz, padding);
    
    % Size
    expectSize = [4, 4, 2];
    assertEqual(size(resized), expectSize);
    
    % Truncation
    assertElementsAlmostEqual(max(resized(:)), 0.5, 'absolute', 10^-16); % Values over 255 are now at +0.5
        % Note the elements are now at single precision, not double
        % precision
    
    % Padding
    assertElementsAlmostEqual(resized(1, 1, 1), 0, 'absolute', 10^-16);
end

function test_size()
    % Create three images and two frames, 5*5
    im1f1 = reshape(101:125, 5, 5); 
    im1f2 = reshape(151:175, 5, 5);
    im2f1 = reshape(201:225, 5, 5);
    im2f2 = reshape(251:275, 5, 5);
    im3f1 = reshape(301:325, 5, 5);
    im3f2 = reshape(351:375, 5, 5);
    stack(:, :, 1, 1) = im1f1;
    stack(:, :, 1, 2) = im1f2;
    stack(:, :, 2, 1) = im2f1;
    stack(:, :, 2, 2) = im2f2;
    stack(:, :, 3, 1) = im3f1;
    stack(:, :, 3, 2) = im3f2;
    
    % Resize, truncate, pad
    sz = 3;
    padding = 1;
    resized = resizeStack(stack, sz, padding);
   
    % Check dimensions
    expectSize = [4, 4, 3, 2];
end