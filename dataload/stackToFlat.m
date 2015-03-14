function imFlat = stackToFlat(imStack)
% STACK TO FLAT: Turn a stack of images X * Y * C * F * B into a set of
% flattened image vectors agnostic of category boundaries, (X*Y) * (C*F) *
% B
%
% Inputs:
%   imStack - a stack of images X pixels * Y pixels * C categories* F
%   frames * B
% TODO note, Bands not tested
%
% Outputs:
%   imFlat - a matrix (X * Y) * (C * F) * Bof the same data. All frames of one
%   category remain in a contiguous block.

    assert(ndims(imStack)<6, 'Cannot be greater than X * Y * C * F *B');

    [X, Y, C, F, B] = size(imStack);
    imFlat = reshape(permute(imStack, [1 2 4 3 5]), [X*Y, C*F, B]);
        % "Permute" is necessary to maintain category adjacency

end

