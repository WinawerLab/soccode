function predictions = socmodel_nogaborstep(params, bands)
    p = num2cell(params);
    [R, S, X, Y, D, G, N, C] = deal(p{:});
    
    divnorm = divnormpointwise(bands, R, S);
    contrast = sum(divnorm, 3);
    
    res = sqrt(size(contrast, 1));
    wt = makegaussian2d(res,X,Y,D,D)/(2*pi*D^2);
    wt = wt(:);
    
    varim = variancelike(contrast, wt, C);
    varsum = windowsum(varim, wt);
    predictions = nonlinearity(varsum, G, N);
end