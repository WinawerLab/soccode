function [predictions, gaborOutput] = stdObs_predict(xyParams, imFlat, cpIm, gaborOutput)
% STANDARD CORTICAL OBSERVER: (x, y, sigma_s, n, c), imFlat, cpIm -> predictions
%
% Compute a set of predictions for specific images, based on set of SOC
% model parameters
%
%
%   In: voxs x 5 (x, y, sigma_s, n, c), px x nIms, 1 (cycles per image),
%       optional gaborOutput (for reusing)
%   Out: predictions voxs x nIms, gaborOutput (in case you want to reuse it)

% Try these as a test:
% xyParams = [5, 5, 1, 1, 1]; 
% imFlat = ones(100, 3); % dummy for three 10x10 ims
    
    if ~exist('gaborOutput', 'var')
        %% COMPUTE GABOR STAGE - compute once per function call, slow
        numor = 8; numph = 2;
        bandwidths = -1; spacings = 1; thresh = 0.01; scaling = 2; mode = 0;

        imShape = permute(imFlat, [2 1]); % Reconfigure dims for knkutils code

        disp('Computing Gabor filter output...')
        gaborOutput = applymultiscalegaborfilters(imShape, ...
          cpIm,bandwidths,spacings,numor,numph,thresh,scaling,mode);
        gaborOutput = sqrt(blob(gaborOutput.^2,2,numph));  % Collapse energy n * (pixels*numor)
        gaborOutput = blob(gaborOutput,2,numor)/numor; % average over orientations
    else
        disp('Using provided Gabor filter outputs')
    end

    %% PREPARE SOC STAGE
    % (this code is basically directly borrowed from knk's
    % "socmodel_example" function)
    disp('Computing model predictions')
    res = sqrt(size(gaborOutput, 2));
    [~,xx,yy] = makegaussian2d(res,2,2,2,2); % Set up a meshgrid (preallocate for speed)
    
    socfun = @(dd,wts,c) bsxfun(@minus,dd,c*(dd*wts)).^2 * wts;
    gaufun = @(pp) vflatten(makegaussian2d(res,pp(1),pp(2),pp(3),pp(3),xx,yy,0,0)/(2*pi*pp(3)^2));
    modelfun = @(pp,dd) (socfun(dd,gaufun(pp),restrictrange(pp(5),0,1)).^pp(4));
    
    %% COMPUTE SOC STAGE
    predictions = zeros(size(xyParams,1), size(imFlat, 2));
    tic
    for pp = 1:size(xyParams,1)
        if mod(pp,500) == 0;
            elapsedMins = toc/60;
            remaining = (size(xyParams,1)-pp) * (elapsedMins/pp);
            disp([num2str(pp), ' predictions in ', num2str(elapsedMins), ' mins. Anticipated ', num2str(remaining), ' mins remaining.'])
        end
        predictions(pp,:) = modelfun(xyParams(pp,:), gaborOutput);
    end
    
end