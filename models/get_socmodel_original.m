function modelfun = get_socmodel_original(res)
% GET_SOCMODEL_ORIGINAL - Given a resolution, build a function that will take a set
% of parameters and a preprocessed stimulus frame and predict the response
% for those parameters. This is the original, optimized code directly
% from knk's repository. The resolution must be known in advance for pre-
% allocation

% Code below is explained in Kendrick's example, socmodel_example.m

% Parameters:
%   dd - The R,S-preprocessed stimulus frame TODO what shape?
%   pp - Parameters: [X Y s G N C]

    % Set up a meshgrid (preallocate for speed)
    [~,xx,yy] = makegaussian2d(res,2,2,2,2);
    
    % The actual socfun
    socfun = @(dd,wts,c) bsxfun(@minus,dd,c*(dd*wts)).^2 * wts;
    
    % Just a Gaussian that sums to one
    % (TODO except not really, 2*pi*pp(3)^2 is incorrect maybe)
    gaufun = @(pp) vflatten(makegaussian2d(res,pp(1),pp(2),pp(3),pp(3),xx,yy,0,0)/(2*pi*pp(3)^2));
    
    % TODO not sure I agree with restrictrange... but that's OK
    modelfun = @(pp,dd) pp(4)*(socfun(dd,gaufun(pp),restrictrange(pp(6),0,1)).^pp(5));

    
end

