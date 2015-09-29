function predictions = socmodel_postdiv(params, imFlat)
% imFlat has already passed through the divnorm stage;
% params excludes R and S
    p = num2cell(params);
    [X, Y, D, G, N, C] = deal(p{:});
        
    res = sqrt(size(imFlat, 1));
    wt = makegaussian2d(res,X,Y,D,D)/(2*pi*D^2);
    wt = wt(:);
    
    varim = variancelike(imFlat, wt, C);
    varsum = windowsum(varim, wt);
    predictions = nonlinearity(varsum, G, N);
end