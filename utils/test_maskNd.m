function test_maskNd()
    test_values();
end

function test_values()
    % Create test image
    mat = magic(5);
    mat = repmat(mat, [1, 1, 2, 3]);
    
    % Create test mask - here, extracts the second column
    msk = zeros(5);
    msk(:, 2) = 1;
    
    % We expect to get the second column repeated 2 x 3 times
    expect = repmat(mat(:, 2, 1, 1), [1, 2, 3]);
    
    % Padding
    assertElementsAlmostEqual(maskNd(mat, msk), expect, 'absolute', 10^-16);
end

