function test_windowsum()
    % One or many images, one or many bands
    test_im_band(10, 1, 1);
    test_im_band(10, 1, 8);
    test_im_band(10, 5, 1);
    test_im_band(10, 5, 8);
end

function test_im_band(xy, nims, nbands)

   ims = ones(xy*xy, nims, nbands);
   
   wt = zeros(xy*xy, 1);
   wt(4) = 5; % arbitrary weight
   
   expect = repmat(5, [1, nims, nbands]);
   % result has no extent in the "pixels" dimension, but has extent in the
   % ims and bands dimensions
   
   result = windowsum(ims, wt);
   
   assertElementsAlmostEqual(result, expect, 'absolute', 10^-6); 
end

function test_dim_mismatch()
    im = ones(100, 1, 1);
    wt = ones(90, 1); % too short
    
    assertExceptionThrown(@() windowsum(im, wt), 'MATLAB:assertion:failed');
end

% assert(ndims(imFlat) < 3, 'MATLAB:assertion:failed', 'flatToStack does not support multiple bands');