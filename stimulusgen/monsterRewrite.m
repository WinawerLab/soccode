
%% Set up image size parameters
res = 400;                     % native resolution that we construct at
totalfov = 12;                 % total number of degrees for image
cpd = 3;                       % target cycles per degree

maskFrac = 11.5/totalfov;      % what fraction of radius for the circular mask to start at

nframes = 9;                 % how many images from each class

radius = totalfov/2;           % radius of image in degrees
cpim = totalfov*cpd;           % cycles per image that we are aiming for
spacing = res/cpim;            % pixels to move from one cycle to the next

%% Choose which bandpass filter to use
bandwidth = 1;
fltsz = 31;
flt = mkBandpassCosine(res, cpim, bandwidth, fltsz, 0);
%flt = mkBandpassDog(res, cpim, bandwidth, fltsz, 0);

%% Make circular stimulus masks
innerres = floor(4/totalfov * res/2)*2;
mask = makecircleimage(res,res/2*maskFrac,[],[],res/2);  % white (1) circle on black (0)

%% Bars
jumpvals = [1, 3, 5];
[bars, contrastBoostBars] = createBarStimulus(res, flt, spacing, jumpvals, nframes);

%% Patterns
patvals = [1/50, 1/30, 1/20, 1/10]; % sparsest first (lowest frequency)
pats = zeros(res, res, length(patvals), nframes);
for ii = 1:length(patvals)
    for jj = 1:length(nframes)
        pats(:, :, ii, jj) = createPatternStimulus([res, res], patvals(ii), flt);
    end
    
    if ii == 1
        contrastBoostPats = .5 / max(abs(flatten(pats(:, :, ii, jj)))); % set once, use for all
        % this could be made the same as above if the black lines were made the same
        % way for both
    end
end
pats = pats * contrastBoostPats;
pats(pats > 0.5) = 0.5;
pats(pats < -0.5) = -0.5;