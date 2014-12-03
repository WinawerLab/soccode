function scalars = windowsum(imFlat, wt)
%WINDOW SUM: Computed a weighted sum of the pixels in every image/band,
%using a particular weight filter
%
% Inputs:
%   imFlat - a matrix (X*Y pixels) * N images * B bands of flattened
%       images. 
%   wt - a column vector (X*Y) containing a weight function for summation
%
% Outputs:
%   scalars - a matrix 1 * N * B of weighted sums for each image

    
    assert(iscolumn(wt), 'MATLAB:assertion:failed', 'Weight vector must be a column');
    assert(size(wt, 1) == size(imFlat, 1), 'MATLAB:assertion:failed', 'Weight vector must match image dimension');
    
    scalars = zeros(1, size(imFlat, 2), size(imFlat, 3));
    
    for band = 1:size(imFlat, 3)
        % Matrix multiplication enables us to do a stack of images all at
        % once, but we can't do a whole 3D block of images, so we just
        % assume that there are only 8-odd bands and that this for loop
        % isn't terrible
        scalars(1, :, band) = wt' * imFlat(:, :, band);
    end
end
