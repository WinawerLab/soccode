function resultFlat = divnormneighbors2(imFlat, r, s, a, e)
%DIVNORM NEIGHBORS: Apply divisive normalization across all bands
%of a set of flattened images, both pointwise *and* within-band surround on
%immediate neighbors
%
% Inputs:
%   imFlat - a matrix (X*Y pixels) * N images * B bands of flattened
%       images decomposed into orientation energy bands
%   r, s - normalization parameters in x^r / (s^r + avg^r)
%   a - how much the surround weighs into the computation
%   e - spatial extent, measured in pixels away from center
%
% Outputs:
%   imFlat - a matrix (X*Y)*N*B of image data after divisive normalization,
%       with normalization pool averaged over all bands at each pixel
%       location *and* including a weighted proportion of the pixel's
%       nearby neighbors

    if nargin < 5
        e = 2; % backwards compatibility
    end
    
    assert((0 <= a) && (a <= 1), 'parameter "a" should be between 0 and 1');

    % For a convolutional operation, go straight into stack space
    imStack = flatToStack(imFlat, 1); % no frames, just pull out X * Y * N * 1 * B
    
    % What's in the numerator of divnorm equation
    numerator = imStack.^r;
    
    % Compute the untuned, central contribution; same for all orientations
    pointsum = sum(imStack, 5);
    pointavg = pointsum / size(imStack, 5);
        
    % Compute the tuned, surround contribution; different per orientation
    convKern = ones(2*e + 1);
    convKern(e+1, e+1) = 0;
    padded = padarray(imStack, [e, e], 'circular');
    surroundsum = convn(padded, convKern, 'valid');
    surroundavg = surroundsum / sum(convKern(:));
    
    % Put together the contribution as an "average"
    avg = bsxfun(@plus, (1-a) * pointavg, a * surroundavg);
    denominator = s^r + avg.^r;

    resultStack = bsxfun(@rdivide, numerator, denominator);
    resultFlat = stackToFlat(resultStack);
end

