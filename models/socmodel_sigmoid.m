function predictions = socmodel_sigmoid(params, imFlat)
% imFlat has already passed through the divnorm stage;
% params excludes R and S
% ALSO, rather than G and N, it takes L and K for sigmoid
    p = num2cell(params);
    [X, Y, D, L, K, C] = deal(p{:});
        
    res = sqrt(size(imFlat, 1));
    wt = makegaussian2d(res,X,Y,D,D)/(2*pi*D^2);
    wt = wt(:);
    
    varim = variancelike(imFlat, wt, C);
    varsum = windowsum(varim, wt);
    predictions = sigmoid(varsum, L, K);
end