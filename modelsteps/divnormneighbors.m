function resultFlat = divnormneighbors(imFlat, r, s, t)
%DIVNORM NEIGHBORS: Apply divisive normalization across all bands
%of a set of flattened images, both pointwise *and* within-band surround on
%immediate neighbors
%
% Inputs:
%   imFlat - a matrix (X*Y pixels) * N images * B bands of flattened
%       images decomposed into orientation energy bands
%   r, s - normalization parameters in x^r / (s^r + avg^r)
%   t - how much the surround weighs into the tuned surround
%
% Outputs:
%   imFlat - a matrix (X*Y)*N*B of image data after divisive normalization,
%       with normalization pool averaged over all bands at each pixel
%       location *and* including a weighted proportion of the pixel's
%       nearby neighbors

    % For a convolutional operation, go straight into stack space
    imStack = flatToStack(imFlat, 1); % no frames, just pull out X * Y * N * 1 * B
    
    % What's in the numerator of divnorm equation
    numerator = imStack.^r;
    
    % Compute the untuned, central contribution; same for all orientations
    pointsum = sum(imStack, 5);
        
    % Compute the tuned, surround contribution; different per orientation
    convKern = t * [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1]; % two neighbors
    padded = padarray(imStack, [2, 2], 'circular');
    surround = convn(padded, convKern, 'valid');
    
    % Put together the contribution as an "average"
    contributions = bsxfun(@plus, pointsum, surround);
    avg = contributions ./ (size(imStack, 5) + sum(convKern(:)));
    denominator = s^r + avg.^r;

    resultStack = bsxfun(@rdivide, numerator, denominator);
    resultFlat = stackToFlat(resultStack);
end

