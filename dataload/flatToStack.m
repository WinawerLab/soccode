function imStack = flatToStack(imFlat, nFrames)
% FLAT TO STACK: Turn a matrix of flattened image vectors (X*Y) * (C*F),
% into a stack of images X * Y * C * F; restore category boundaries
%
% Inputs:
%   imFlat - a matrix (X pixels * Y pixels) * (C categories * F frames) * B
%       of image data. Currently only implemented for X = Y square images!
%   nFrames [optional] - every nth image is treated as being a different
%       frame in the same category
% 
% Outputs:
%   imStack - a stack of images X pixels * Y pixels * C categories * F
%   frames * B bands

% optional nframes

    if nargin < 2
        nFrames = 1;
    end

    assert(ndims(imFlat) < 4, 'MATLAB:assertion:failed', 'flatToStack can be at most (X*Y) * ims * bands');
    
    [XY, CF, B] = size(imFlat);
    assert(mod(sqrt(XY),1) == 0, 'MATLAB:assertion:failed', 'flatToStack is currently only implemented for square images');
    
    X = sqrt(XY);
    Y = sqrt(XY);
    C = CF / nFrames;
        
    imStack = reshape(imFlat, [X, Y, nFrames, C, B]);
    imStack = permute(imStack, [1, 2, 4, 3, 5]); % because I did a permutation going in, is all

end

