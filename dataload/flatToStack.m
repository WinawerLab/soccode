function imStack = flatToStack(imFlat, nFrames)
% FLAT TO STACK: Turn a matrix of flattened image vectors (X*Y) * (C*F),
% into a stack of images X * Y * C * F; restore category boundaries
%
% Inputs:
%   imFlat - a matrix (X pixels * Y pixels) * (C categories * F frames)
%       of image data. Currently only implemented for X = Y square images!
%   nFrames [optional] - every nth image is treated as being a different
%       frame in the same category
% 
% Outputs:
%   imStack - a stack of images X pixels * Y pixels * C categories * F frames

% optional nframes

    if nargin < 2
        nFrames = 1;
    end

    assert(ndims(imFlat) < 3, 'MATLAB:assertion:failed', 'flatToStack does not support multiple bands');
    
    [XY, CF] = size(imFlat);
    assert(isint(sqrt(XY)), 'MATLAB:assertion:failed', 'flatToStack is currently only implemented for square images');
    
    X = sqrt(XY);
    Y = sqrt(XY);
    C = CF / nFrames;
        
    imStack = reshape(imFlat, [X, Y, nFrames, C]);
    imStack = permute(imStack, [1, 2, 4, 3]);

end

