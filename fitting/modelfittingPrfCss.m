function results = modelfittingPrfCss(modelhandle, betamnToUse, imToUse)
% Model fitting for the pRF only; NO C parameter!!

    res = 90;
    Xs = (1+res)* [0.2 0.4 0.6 0.8];
    Ys = (1+res) * [0.2 0.4 0.6 0.8];
    D = res/4*sqrt(0.5); % not currently reseeding, let's see how it goes
    G = 10; 
    N = 0.5; % Currently working with no N reseeding
    seeds = [];
    for x=1:length(Xs)
      for y=1:length(Ys)
        seeds = cat(1,seeds,[Xs(x) Ys(y) D G N]);
      end
    end

    bounds = [1-res+1 1-res+1 0   -Inf 0  ;
              2*res-1 2*res-1 Inf  Inf Inf];
    boundsFIX = bounds;
    boundsFIX(1,5) = NaN; % fix the N

    model = {{[]         boundsFIX   modelhandle}};
         
    optimoptions = {'Algorithm' 'levenberg-marquardt' 'Display' 'off'};
    resampling = 0;
    metric = @(a,b) calccod(a,b,[],[],0);

    % construct the options struct
    opt = struct( ...
      'outputdir',    'temp', ...
      'stimulus',     imToUse, ...
      'data',         betamnToUse', ...
      'model',        {model}, ...
      'seed',         seeds, ...
      'optimoptions', {optimoptions}, ...
      'resampling',   resampling, ...
      'metric',       metric);

    results = fitnonlinearmodel(opt);
   
end


