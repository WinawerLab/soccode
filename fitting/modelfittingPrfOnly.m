function results = modelfittingPrfOnly(modelhandle, betamnToUse, imToUse)
% Model fitting for the pRF only

    res = 90;
    Xs = (1+res)* [0.2 0.4 0.6 0.8];
    Ys = (1+res) * [0.2 0.4 0.6 0.8];
    D = res/4*sqrt(0.5); % not currently reseeding, let's see how it goes
    G = 10; %10; 
    N = 0.3; % 0.5; % Currently working with no N reseeding
    C = 0.7; % 0.9; % And also no C reseeding, temporarily for now
    seeds = [];
    for x=1:length(Xs)
      for y=1:length(Ys)
        seeds = cat(1,seeds,[Xs(x) Ys(y) D G N C]);
      end
    end

    bounds = [1-res+1 1-res+1 0   -Inf 0   0;
              2*res-1 2*res-1 Inf  Inf Inf 1];
    boundsFIX = bounds;
    boundsFIX(1,5:6) = NaN; % fix the N and C

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


