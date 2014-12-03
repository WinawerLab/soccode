function wrapped = wrapmodel(model)
% INTERFACE MODEL: For a model that accepts params and images
%   Pixels * (C * F) and returns predictions 1 * (C * F), return a wrapper model
%   that accepts params and an image set (C*F) * Pixels and returns
%   predictions (C*F) * 1
    
    wrapped = @(params, PI)(permute(model(params, permute(PI, [2 1])), [2 1]));
end