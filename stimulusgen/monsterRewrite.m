
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
angles = [0, pi/4, pi/2, 3*pi/4];

[barsSparsity, lineSparsity, ~] = createBarStimulus(res, flt, spacing, jumpvals, nframes, angles(1));

barsOrientation = [];
linesOrientation = [];

for angle = angles
    [barsSparsity, lineSparsity, ~] = createBarStimulus(res, flt, spacing, jumpvals(3), nframes, angle);
    barsOrientation = cat(3, barsOrientation, bar);
    linesOrientation = cat(3, linesOrientation, line);
end

%% Patterns
patvals = [0.012, 0.016, 0.022, 0.041, 0.06];
    % first four are carefully matched to 9, 7, 5, and 3... then the last is arbitrary
    % sparsest is first (lowest frequency)
%patvals = [0.06, 0.07, 0.08, 0.09, 0.1];
patternsSparsity = zeros(res, res, length(patvals), nframes);
edgesSparsity = zeros(res, res, length(patvals), nframes);
for ii = 1:length(patvals)
    for jj = 1:nframes
        [output, edge] = createPatternStimulus([res, res], patvals(ii), flt);
        patternsSparsity(:, :, ii, jj) = output;
        edgesS(:, :, ii, jj) = edge;
    end
    
%     if ii == 1 % sparsest
%       contrastBoostPats = .5 / max(abs(flatten(pats(:, :, ii, jj))));
%     end
end

contrastBoostPats = 1.9342; % saved from a good run with smooth contours
patternsSparsity = patternsSparsity * contrastBoostPats;
patternsSparsity(patternsSparsity > 0.5) = 0.5;
patternsSparsity(patternsSparsity < -0.5) = -0.5;

% CHECK - count blank pixels to match sparsity of patterns and bars
% barsum = squeeze(sum(sum(bars==0, 1), 2)); % can also do abs(bars) for another check
% patsum = squeeze(sum(sum(patterns==0, 1), 2)); % or include a square for a variance check
% 
% figure; hold on;
% plot(patvals, patsum, 'o');
% plot(patvals, mean(patsum, 2), 'x-');

%% Bandpassed white noise
compareIms = patternsSparsity(:, :, 1:3, :);
compareVar = var(compareIms(compareIms ~= 0)); % 0.0325
noise = createFilteredNoiseStimulus(res, flt, compareVar, nframes);

%% Noise bars
noiseBars = createFilteredNoiseStimulus(res, flt, compareVar, nframes*length(angles)*(length(jumpvals)-1));
noiseBars = reshape(noiseBars, res, res, length(angles)*(length(jumpvals)-1), nframes);

blursize = 5; % NOTE: tuned by hand to be correct size!

extraVarBoost = 1.2; % to compensate for clipping; a hack
linesToUse = 1:size(lines,3);
linesToUse = linesToUse(mod(linesToUse, length(jumpvals)) ~= 0);
noiseBars = createNoiseBarStimulus(noiseBars, lines(:, :, linesToUse, :), blursize, compareVar*extraVarBoost);

% % Variance check:
% noiselinevarnew = var(noiseBars(noiseBars~=0));
% disp('Var:')
% disp(compareVar)
% disp(noiselinevarnew)
% 
% % Visual check:
% concat = [bars(:, 100:200, 3, 1), noiseBars(:, 200:300, 3, 1)];
% figure(1); clf; imshow(concat, span);
% figure(2); clf; imshow(noiseBars(:, :, 3, 1), span);

%% Waves
contrastCutoff = 0.2;
smoothness = 4;

waves = [];
for angle = angles
    wave = createWaveStimulus(edgesS, angle, flt, cpim, contrastCutoff, smoothness, compareVar);
    waves = cat(3, waves, wave);
end

%% Multiple contrasts
contrasts = [0.03, 0.1, 0.25, 0.5, 1];

show = [];
for c = contrasts
    newPatterns = patternsSparsity * c;
    newGratings = bars * c;
    toadd = [newPatterns(:, :, 3, 1); newGratings(:, :, 3, 1)];
    show = [show, toadd];
end
figure; imshow(show, span);

%% Multiple orientations
jumpvals = [9, 7, 5, 3, 1];
[barsOri, linesOri, contrastBoostBars] = createBarStimulus(res*2, flt, spacing, jumpvals, nframes);

%% Knockout
denseBars = bars(:, :, 5, :);
mediumBars = bars(:, :, 3, :);

denseKnockout