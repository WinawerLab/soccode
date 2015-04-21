function results = modelfittingGivenPrf(modelhandle, betamnToUse, imToUse, xydg)
% Model fitting, with a provided X,Y,D,and G.

    res = 90;
    X = xydg(1);
    Y = xydg(2);
    D = xydg(3);
    G = xydg(4); 
    Ns = [.05 .1 .3 .5 .7];
    Cs = [.4 .7 .9 .95];
    seeds = [];
    for n=1:length(Ns)
      for c=1:length(Cs)
        seeds = cat(1,seeds,[X Y D G Ns(n) Cs(c)]);
      end
    end

    bounds = [1-res+1 1-res+1 0   -Inf 0   0;
              2*res-1 2*res-1 Inf  Inf Inf 1];
    boundsFIX = bounds;
    boundsFIX(1,1:4) = NaN; % fix all but N and C

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


