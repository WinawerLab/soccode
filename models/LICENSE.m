function predictions = socmodel_memgabor(params, imFlat, memgabor)
    assert(max(imFlat(:)) - min(imFlat(:)) - 1 < 10^-16, 'MATLAB:assertion:failed', 'Must be [-0.5, 0.5]')
    
    p = num2cell(params);
    [R, S, X, Y, D, G, N, C] = deal(p{:});
    
    numor = 8; numph = 2;
    bands = memgabor(imFlat, numor, numph);
    divnorm = divnormpointwise(bands, R, S);
    contrast = sum(divnorm, 3);
    
    res = sqrt(size(contrast, 1));
    wt = makegaussian2d(res,X,Y,D,D)/(2*pi*D^2);
    wt = wt(:);
    
    varim = variancelike(contrast, wt, C);
    varsum = windowsum(varim, wt);
    predictions = nonlinearity(varsum, G, N);
end