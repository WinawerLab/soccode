function imFlat = stackToFlat(imStack)
% STACK TO FLAT: Turn a stack of images X * Y * C * F into a set of
% flattened image vectors agnostic of category boundaries, (X*Y) * (C*F).
%
% Inputs:
%   imStack - a stack of images X pixels * Y pixels * C categories* F frames
%
% Outputs:
%   imFlat - a matrix (X * Y) * (C * F) of the same data. All frames of one
%   category remain in a contiguous block.

    assert(ndims(imStack)<5, 'Bands are not yet implemented for stackToFlat');

    [X, Y, C, F] = size(imStack);
    imFlat = reshape(permute(imStack, [1 2 4 3]), [X*Y, C*F]);
        % "Permute" is necessary to maintain category adjacency

end

