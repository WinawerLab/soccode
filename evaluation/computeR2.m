function [r2, residuals] = computeR2(predictions, actual)
% COMPUTE R^2: Compare this model to the "mean" model;
%   compute and return 1 - ss_res./ss_tot where ss_res is residual
%   sum of squares for this model, and ss_tot is for the "mean" model
%
%   predictions: n_models * n_datapoints
%   actual: n_datapoints

ss_tot = sum((actual - mean(actual)).^2); 

residuals = bsxfun(@minus, actual, predictions);
ss_res = sum(residuals.^2, 2);

r2 = 1 - ss_res./ss_tot;

end

