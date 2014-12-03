function imFlat = variancelike(imFlat, wt, c)
%VARIANCELIKE: First compute a weighted average; then subtract off c times 
% that average from the whole image, and square the result. Each pixel now
% represents something like its squared distance from the mean. This output
% needs to be pooled in order to get a single number like the variance.
%
% Inputs:
%   imFlat - a matrix (X*Y pixels) * N images * B bands of flattened
%       images. 
%   wt - a column vector (X*Y) containing a weight function for summation
%
% Outputs:
%   scalars - a matrix 1 * N * B of weighted sums for each image

    
    wtsums = windowsum(imFlat, wt);
    imFlat = bsxfun(@minus, imFlat, c * wtsums);
    imFlat = imFlat.^2;
end
