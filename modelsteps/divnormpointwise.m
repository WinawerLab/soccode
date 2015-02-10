function imFlat = divnormpointwise(imFlat, r, s)
%DIVNORM POINTWISE: Apply pointwise divisive normalization across all bands
%of a set of flattened images
%
% Inputs:
%   imFlat - a matrix (X*Y pixels) * N images * B bands of flattened
%       images decomposed into orientation energy bands
%   r, s - normalization parameters in x^r / (s^r + avg^r)
%
% Outputs:
%   imFlat - a matrix (X*Y)*N*B of image data after divisive normalization,
%       with normalization pool averaged over all bands at each pixel location

    numerator = imFlat.^r;
    
    pointavg = sum(imFlat, 3) / size(imFlat, 3);
    denominator = s^r + pointavg.^r;

    imFlat = bsxfun(@rdivide, numerator, denominator);
    
    if ~all(isreal(imFlat))
        keyboard()
    end
end

