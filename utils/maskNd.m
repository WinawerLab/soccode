function result = maskNd(mat, mask)
% MASK N-D: Given an MxNxAx...xZ matrix, and an MxN mask, produce an
%   [M*N]xAx...xZ matrix of the result of indexing into that matrix
%
% Inputs:
%   mat - a matrix M * N * A * Z ... * Z
%   mask - a logical mask M *N
% 
% Outputs:
%   result - a matrix [M*N] * A * ... * Z resulting from treating
%       the mask as a set of logical indices into the first two
%       dimensions of mat

    dims = size(mat);
    fullmask = repmat(mask, [1, 1, dims(3:end)]);
    
    indices = find(fullmask);
    reshapeSize = [length(find(mask)), dims(3:end)];
    indices = reshape(indices, reshapeSize);

    result = mat(indices);
end