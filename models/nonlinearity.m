function mat = nonlinearity(mat, g, n)
% NONLINEARITY: Every pixel value gets scaled by g * px^N
%
% Inputs:
%   mat - a matrix of any shape
%   g, n - gain and exponent in g*(x^n)
%
% Outputs:
%   mat - transformed matrix

    mat = g * (mat.^n);
end
