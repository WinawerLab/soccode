
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
[bars, lines, contrastBoostBars] = createBarStimulus(res, flt, spacing, jumpvals, nframes);

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

%% CHECK - compare pixels to match sparsity of patterns and bars
% Count number of blank pixels:
barsum = squeeze(sum(sum(bars==0, 1), 2)); % can also do abs(bars) for a parallel check
patsum = squeeze(sum(sum(pats==0, 1), 2)); % or include a square for a variance check

figure; hold on;
plot(patvals, patsum, 'o');
plot(patvals, mean(patsum, 2), 'x-');

%% Bandpassed white noise
compareIms = pats(:, :, 1:3, :);
compareVar = var(compareIms(compareIms ~= 0)); % 0.0325
noise = createFilteredNoiseStimulus(res, flt, compareVar, nframes);

%% Noise bars
noiseBars = createFilteredNoiseStimulus(res, flt, compareVar, nframes*(length(jumpvals)-1));
noiseBars = reshape(noiseBars, res, res, length(jumpvals)-1, nframes);

blursize = 5; % WARNING: tuned by hand to be correct size!

extraVarBoost = 1.2; % to compensate for clipping; a hack
noiseBars = createNoiseBarStimulus(noiseBars, lines(:, :, 1:end-1, :), blursize, compareVar*extraVarBoost);

% Variance check:
noiselinevarnew = var(noiseBars(noiseBars~=0));
disp('Var:')
disp(compareVar)
disp(noiselinevarnew)

% Visual check:
concat = [bars(:, 100:200, 3, 1), noiseBars(:, 200:300, 3, 1)];
figure(1); clf; imshow(concat, span);
figure(2); clf; imshow(noiseLines, span);

%% Waves
gaborCpfovs = 45;
fovs = 800;
gaborFiltSize = 32;
cpFiltsize = (gaborCpfovs/ fovs)*gaborCpfovs;

for ii = 6:10
    for frame = 1:size(fullStack,4)
        gaborfilt = makegabor2d(gaborFiltSize, [], [], cpFiltsize, 0, 0, -1);
        
        aperture = -1 * fullStack(:, :, ii, frame);
        aperture(aperture < 0) = 0; % remove the flanking stripes
        aperturePad = padarray(aperture, floor(size(gaborfilt)/2), 'circular', 'both');
        aperturePad = aperturePad(1:end-1, 1:end-1);
        horizPattern  = conv2(aperturePad, gaborfilt, 'valid');
        
        fullStack(:, :, 10 + ii, frame) = horizPattern;
    end
end

savemetoo = fullStack(:, :, 16:20, :);
