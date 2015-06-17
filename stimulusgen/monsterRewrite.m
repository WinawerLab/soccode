
%% Set up image size parameters
res = 400;                     % native resolution that we construct at
totalfov = 12;                 % total number of degrees for image
cpd = 3;                       % target cycles per degree

maskFrac = 11.5/totalfov;      % what fraction of radius for the circular mask to start at

nframes = 9;                 % how many images from each class

radius = totalfov/2;           % radius of image in degrees
cpim = totalfov*cpd;           % cycles per image that we are aiming for
spacing = res/cpim;            % pixels to move from one cycle to the next

span = [-0.5, 0.5];             % dynamic range, to put into 'imshow' etc.

%% Choose which bandpass filter to use
bandwidth = 1;
fltsz = 31;
flt = mkBandpassCosine(res, cpim, bandwidth, fltsz, 0);
%flt = mkBandpassDog(res, cpim, bandwidth, fltsz, 0);

%% Make circular stimulus masks
innerres = floor(4/totalfov * res/2)*2;
mask = makecircleimage(res,res/2*maskFrac,[],[],res/2);  % white (1) circle on black (0)

%% Bars
jumpvals = [9, 7, 5, 3, 1];
[bars, contrastBoostBars, lines] = createBarStimulus(res, flt, spacing, jumpvals, nframes);

%% Patterns
nframes = 9;
patvals = [0.012, 0.016, 0.022, 0.041]; % matched to 9, 7, 5, and 3
    % sparsest first (lowest frequency)
%patvals = [0.06, 0.07, 0.08, 0.09, 0.1];
pats = zeros(res, res, length(patvals), nframes);
for ii = 1:length(patvals)
    for jj = 1:nframes
        [output, edge] = createPatternStimulus([res, res], patvals(ii), flt);
        pats(:, :, ii, jj) = output;
    end
    
%     if ii == 1 % sparsest
%       contrastBoostPats = .5 / max(abs(flatten(pats(:, :, ii, jj))));
%     end
end

contrastBoostPats = 1.9342; % saved from a good run with smooth contours
pats = pats * contrastBoostPats;
pats(pats > 0.5) = 0.5;
pats(pats < -0.5) = -0.5;

%% compare!
barsum = squeeze(sum(sum(bars==0, 1), 2)); % can also do abs(bars) for a parallel check
patsum = squeeze(sum(sum(pats==0, 1), 2));

figure; hold on;
plot(patvals, patsum, 'o');
plot(patvals, mean(patsum, 2), 'x-');

%% Bandpassed white noise
compareIms = pats(:, :, 1:3, :);
compareVar = var(compareIms(compareIms ~= 0)); % 0.0325
noise = zeros(res, res, 1, nframes);
for ii = 1:nframes
    noise(:, :, 1, ii) = createNoiseStimulus(res, flt, compareVar);
end

%% Noise bars
