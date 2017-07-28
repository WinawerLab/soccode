function mat = sigmoid(mat, L, k)
% NONLINEARITY: Every pixel value x gets scaled by
%    L * [1 / (1 + e^(-kx)) + 0.5]
% Inputs:
%   mat - a matrix of any shape
%   L, k - gain and steepness
%
% Outputs:
%   mat - transformed matrix

    mat = L * (1 ./ (1+exp(-k*mat)) - 0.5);
end
