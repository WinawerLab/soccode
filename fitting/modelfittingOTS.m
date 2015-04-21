function results = modelfittingOTS(modelhandle, betamnToUse, imCell)
% Model fitting for the OTS model. Needs to be passed the full set of
% images at different a and e values, so it can try out each

% imCell should be a cell array of transposed pxv's

    res = 90;
    X = (1+res)/2;
    Y = (1+res)/2;
    D = res/4*sqrt(0.5);
    G = 10;
    Ns = 0.5; % [.05 .1 .3 .5]; %
    Cs = 0.9; % [.4 .7 .9 .95];
    seeds = [];
    for frame=1:length(Ns)
      for q=1:length(Cs)
        seeds = cat(1,seeds,[X Y D G Ns(frame) Cs(q)]);
      end
    end

    bounds = [1-res+1 1-res+1 0   -Inf 0   0;
              2*res-1 2*res-1 Inf  Inf Inf 1];
    boundsFIX = bounds;
    boundsFIX(1,5:6) = NaN; % fix the N and C

    model = {{[]         boundsFIX   modelhandle} ...
             {@(ss) ss   bounds      @(ss) modelhandle}};
         % First row is seeds, bounds (NaN is "fixed"), modelfun
         % Second row reuses params without transformation.  The @(ss) ss
         % are no-ops.
         
    optimoptions = {'Algorithm' 'levenberg-marquardt' 'Display' 'off'};
    resampling = 0;
    metric = @(a,b) calccod(a,b,[],[],0);
    
    % temporary
    imToUse = imCell{1, 1};

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


