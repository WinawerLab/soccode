function imPxv = stackToPxv(imStack)
% STACK TO PIXEL VECTORS: Turn a stack of images X * Y * C * F into a set of
% flattened image vectors, respecting category boundaries, (X*Y) * C * F.
%
% Inputs:
%   imStack - a stack of images X pixels * Y pixels * C categories* F frames
%
% Outputs:
%   imLinear - a matrix (X * Y) * C * F. Each image's pixels have been
%   written out in a long vector, but the whole matrix is not fully flat/2D.

    assert(ndims(imStack)<5, 'Bands are not yet implemented for stackToPxv');

    [X, Y, C, F] = size(imStack);
    imPxv = reshape(imStack, [X*Y, C, F]);
end

