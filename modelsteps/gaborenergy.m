function output = gaborenergy(imFlat, numor, numph, cpfovs)
%GABOR ENERGY: Compute the gabor energy, summed across phases, at each of
%numor orientation bands, using gabor wavelets
%
% Inputs:
%   imFlat - a matrix (X*Y pixels) * N images of flattened images
%   numor, numph - number of orientations and phases to use
%
% Outputs:
%   imFlat - a matrix of (X*Y) * N * numor bands of energy, summed across
%   phases, with gabor wavelets

  
    assert(ndims(imFlat) < 3, 'MATLAB:assertion:failed', 'imFlat may not already contain bands');

   
    if sqrt(size(imFlat, 1)) ~= 180
        warning('gaborenergy only appropriate params for 180x180 images');
    end
    
    bandwidths = -1;
    spacings = 1;
    thresh = 0.01;
    scaling = 2;
    mode = 0;
    
    % Reconfigure dimensions to interface with knkutils code
    imShape = permute(imFlat, [2 1]);
    
    % Compute filter outputs
    output = applymultiscalegaborfilters(imShape, ...
      cpfovs,bandwidths,spacings,numor,numph,thresh,scaling,mode);
  
    % Collapse energy
    output = sqrt(blob(output.^2,2,numph));  % n * (pixels*numor)
    
    % Reconfigure dimensions to return from knkutils space
    n = size(output, 1);
    pixels = size(output, 2)/numor;
    
    output = permute(reshape(output, n, numor, pixels), [3 1 2]);
end
