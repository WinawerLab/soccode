function test_maskNd()
    test_2d_mask();
    test_3d_mask();
end

function test_2d_mask()
    % Create test image
    mat = magic(5);
    mat = repmat(mat, [1, 1, 2, 3]);
    
    % Create test mask - here, extracts the second column
    msk = zeros(5);
    msk(:, 2) = 1;
    
    % We expect to get the second column repeated 2 x 3 times
    expect = repmat(mat(:, 2, 1, 1), [1, 2, 3]);
    
    % Check
    result = maskNd(mat,msk);
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16);
    assertEqual(size(result), [sum(msk(:)), 2, 3]);
end

function test_3d_mask()
    % Create test image
    mat = magic(5);
    mat = repmat(mat, [1, 1, 2, 3]);
    
    % Create test mask - here, acts over three dimensions
    msk = zeros(5, 5, 2);
    msk(1, 1, 1) = 1;
    msk(5, 5, 2) = 1; % grab two opposite corners of the cube
    
    % We expect to get the top left (17) and the bottom right (9) repeated
    % three times
    expect = repmat([17; 9], 1, 3);
    
    % Padding
    result = maskNd(mat,msk);
    assertElementsAlmostEqual(result, expect, 'absolute', 10^-16);
    assertEqual(size(result), [sum(msk(:)), 3]);
end
