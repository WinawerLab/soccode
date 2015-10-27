%% Stimulus generation for the June 2015 stimulus set
% (formerly known as "monsterRewrite.m")

%% Set up image size parameters
res = 600; %400;                     % native resolution that we construct at
totalfov = 18; %12;                 % total number of degrees for image
cpd = 3;                       % target cycles per degree

maskFrac = 17/18; %11.5/totalfov;      % what fraction of radius for the circular mask to start at

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
canonicalSparsity = 5;
canonicalAngle = 0;

jumpvals = [9, 7, 5, 3, 1];
angles = [0, pi/4, pi/2, 3*pi/4];

[barsSparsity, linesSparsity, ~] = createBarStimulus(res, flt, spacing, jumpvals, nframes, canonicalAngle);

barsOri = [];
linesOri = [];
for angle = angles(1:end)
    if angle == canonicalAngle; continue; end; % don't duplicate work
    [bar, line, ~] = createBarStimulus(res, flt, spacing, canonicalSparsity, nframes, angle);
    barsOri = cat(3, barsOri, bar);
    linesOri = cat(3, linesOri, line);
end

display('Gratings done');

%% Patterns
patvals = [0.012, 0.016, 0.022, 0.041, 0.06];
    % first four are carefully matched to 9, 7, 5, and 3... then the last is arbitrary
    % sparsest is first (lowest frequency)
patterns = zeros(res, res, length(patvals), nframes);
edges = zeros(res, res, length(patvals), nframes);
for ii = 1:length(patvals)
    for jj = 1:nframes
        [output, edge] = createPatternStimulus([res, res], patvals(ii), flt);
        patterns(:, :, ii, jj) = output;
        edges(:, :, ii, jj) = edge;
    end
    
%     if ii == 1 % sparsest
%       contrastBoostPats = .5 / max(abs(flatten(pats(:, :, ii, jj))));
%     end
end

contrastBoostPats = 1.9342; % saved from a good run with smooth contours
patterns = patterns * contrastBoostPats;
patterns(patterns > 0.5) = 0.5;
patterns(patterns < -0.5) = -0.5;

display('Patterns done');

% CHECK - count blank pixels to match sparsity of patterns and bars
% barsum = squeeze(sum(sum(barsSparsity==0, 1), 2)); % can also do abs(barsOri) for another check
% patsum = squeeze(sum(sum(patterns==0, 1), 2)); % or include a square for a variance check
% 
% figure; hold on;
% %plot(patvals, patsum, 'o');
% plot(patvals, mean(patsum, 2), 'rx-');
% %plot(patvals, patsum, 'o');
% plot(patvals, mean(barsum, 2), 'bx-');

%% Bandpassed white noise
compareIms = patterns(:, :, 1:3, :);
compareVar = var(compareIms(compareIms ~= 0)); % 0.0325
noise = createFilteredNoiseStimulus(res, flt, compareVar, nframes);
noise = permute(noise, [1 2 4 3]);

%% Noise bars
blursize = 5; % NOTE: tuned by hand to be correct size!
extraVarBoost = 1.2; % to compensate for clipping; a hack

noiseBarsSparsity = createFilteredNoiseStimulus(res, flt, compareVar, nframes*(length(jumpvals)));
noiseBarsSparsity = reshape(noiseBarsSparsity, res, res, length(jumpvals), nframes);
[noiseBarsSparsity, nbsApertures] = createNoiseBarStimulus(noiseBarsSparsity, linesSparsity(:, :, 1:end, :), blursize, compareVar*extraVarBoost);

noiseBarsOri = createFilteredNoiseStimulus(res, flt, compareVar, nframes*(length(angles)-1));
    % exclude the canonical orientation
noiseBarsOri = reshape(noiseBarsOri, res, res, length(angles)-1, nframes);
[noiseBarsOri, nboApertures] = createNoiseBarStimulus(noiseBarsOri, linesOri, blursize, compareVar*extraVarBoost);

display('Noisebars done');

% % Check: Variance
% noiselinevarnew = var(noiseBars(noiseBars~=0));
% disp('Var:')
% disp(compareVar)
% disp(noiselinevarnew)
% 
% % Check: Visual
% concat = [bars(:, 100:200, 3, 1), noiseBars(:, 200:300, 3, 1)];
% figure(1); clf; imshow(concat, span);
% figure(2); clf; imshow(noiseBars(:, :, 3, 1), span);

% % Check: Fourier
% tmpNoise = createFilteredNoiseStimulus(res, flt, compareVar, nframes*(length(jumpvals)));
% tmpNoise = reshape(tmpNoise, res, res, length(jumpvals), nframes);
% tmp = 2 * tmpNoise .* barsSparsity;
% 
% figure(1); clf;
% subplot(2, 5, 1); imshow(tmpNoise(:, :, 3, 1), span);
% subplot(2, 5, 6); imshow(abs(fftshift(fft2(tmpNoise(:, :, 3, 1)))), []);
% subplot(2, 5, 2); imshow(nbsApertures(:, :, 3, 1), []);
% subplot(2, 5, 7); imshow(abs(fftshift(fft2(nbsApertures(:, :, 3, 1)))), []);
% subplot(2, 5, 3); imshow(noiseBarsSparsity(:, :, 3, 1), span);
% subplot(2, 5, 8); imshow(abs(fftshift(fft2(noiseBarsSparsity(:, :, 3, 1)))), []);
% subplot(2, 5, 4); imshow(barsSparsity(:, :, 3, 1), span);
% subplot(2, 5, 9); imshow(abs(fftshift(fft2(barsSparsity(:, :, 3, 1)))), []);
% subplot(2, 5, 5); imshow(tmp(:, :, 3, 1), span);
% subplot(2, 5, 10); imshow(abs(fftshift(fft2(tmp(:, :, 3, 1)))), []);



%% Waves
contrastCutoff = 0.2;
smoothness = 4;

% Sparsity
wavepatvals = [0.03, 0.041, 0.06, 0.1]; % cannot get a fifth one that is dense enough...
waveEdges = zeros(res, res, length(wavepatvals), nframes);
for ww = 1:length(wavepatvals)
    for jj = 1:nframes
        [output, edge] = createPatternStimulus([res, res], wavepatvals(ww), flt);
        waveEdges(:, :, ww, jj) = edge;
    end
end
wavesSparsity = createWaveStimulus(waveEdges, canonicalAngle, flt, cpim, contrastCutoff, smoothness, compareVar);

% Orientation
wavesOri = [];
sparsityIdx = find(jumpvals == canonicalSparsity);
for angle = angles
    if angle == canonicalAngle; continue; end; % don't duplicate work
    
    wave = createWaveStimulus(waveEdges(:, :, sparsityIdx, :), angle, flt, cpim, contrastCutoff, smoothness, compareVar);
    wavesOri = cat(3, wavesOri, wave);
end

% Check! (was crucially missing last time!)
% barsum = squeeze(sum(sum(barsSparsity==0, 1), 2)); % can also do abs(barsOri) for another check
% patsum = squeeze(sum(sum(patterns==0, 1), 2)); % or include a square for a variance check
% wavsum = squeeze(sum(sum(wavesSparsity == 0, 1), 2));
% 
% figure; hold on;
% plot(patvals, mean(patsum, 2), 'rx-');
% plot(patvals, mean(barsum, 2), 'bx-');
% plot(patvals(1:end-1), mean(wavsum, 2), 'gx-');

display('Waves done');

%% Multiple contrasts
contrasts = [0.03, 0.1, 0.5, 1];

barsContrast = [];
patternsContrast = [];
noiseBarsContrast = [];
wavesContrast = [];

sparsityIdx = find(jumpvals == canonicalSparsity);
for c = contrasts
    barsContrast = cat(3, barsContrast, c * barsSparsity(:, :, sparsityIdx, :));
    patternsContrast = cat(3, patternsContrast, c * patterns(:, :, sparsityIdx, :));
    noiseBarsContrast = cat(3, noiseBarsContrast, c * noiseBarsSparsity(:, :, sparsityIdx, :));
    wavesContrast = cat(3, wavesContrast, c * wavesSparsity(:, :, sparsityIdx, :));
end

display('Contrasts done');

%% Knockouts
denseBars = barsSparsity(:, :, 5, :);
mediumBars = barsSparsity(:, :, 3, :);

knockLines = linesSparsity(:, :, 3, :);

denseKnockin = createKnockoutStimulus(denseBars, knockLines, 8, 1);
denseKnockout = createKnockoutStimulus(denseBars, knockLines, 8, 0);
mediumKnockin = createKnockoutStimulus(mediumBars, knockLines, 8, 1);
mediumKnockout = createKnockoutStimulus(mediumBars, knockLines, 8, 0);

knockouts = cat(3, denseKnockin, denseKnockout, mediumKnockin, mediumKnockout);

display('Knockouts done');

%% Blank
blank = zeros(res, res, 1, nframes);

%% Combine everything
canonicalContrast = 0.25;
everything = canonicalContrast * cat(3, patterns, ...
                       barsSparsity, noiseBarsSparsity, wavesSparsity, ...
                       barsOri, noiseBarsOri, wavesOri, ...
                       knockouts); % these should all go to medium contrast, the rest are already at the right contrast
everything = cat(3, everything, barsContrast, noiseBarsContrast, wavesContrast, patternsContrast);
everything = bsxfun(@times, mask, everything);

%% Rotate everything 90 degrees
everything = imrotate(everything, 90);

%% Visualize everything
showme = 1:size(everything, 3);%1:size(everything, 3); % 30:34
figure; for ii = showme, imshow(everything(:, :, ii, 1), span); title(ii); waitforbuttonpress; end; %pause(0.5); end;

%% Chop up into two matrices
oddStimuli = cat(3, everything(:, :, 1:2:end, :), blank);
oddStimuli = uint8(round((oddStimuli+0.5)*255));
oddStimuli = permute(oddStimuli, [1 2 4 3]);
oddStimuli = reshape(oddStimuli, size(oddStimuli,1), size(oddStimuli,2), []);

evenStimuli = cat(3, everything(:, :, 2:2:end, :), blank);
evenStimuli = uint8(round((evenStimuli+0.5)*255));
evenStimuli = permute(evenStimuli, [1 2 4 3]);
evenStimuli = reshape(evenStimuli, size(evenStimuli,1), size(evenStimuli,2), []);

stimuli.odd = oddStimuli;
stimuli.even = evenStimuli;

stimuli.imStack = uint8(round((everything+0.5)*255));
stimuli.imNums = 271:(271+size(stimuli.imStack, 3)-1);

% TODO: make sure to rename the filename below if you're rerunning this!
save('stimuli-2015-10-05_rerun.mat', 'stimuli', '-v7.3');

%% Retroactive fixing of imStack bug
imFile = fullfile('data', 'stimuli', 'stimuli-2015-10-05.mat');
load(fullfile(rootpath, imFile), 'stimuli');

tmpOdd = permute(reshape(stimuli.odd, size(stimuli.odd, 1), size(stimuli.odd, 2), 9, []), [1 2 4 3]);
tmpEven = permute(reshape(stimuli.even, size(stimuli.even, 1), size(stimuli.even, 2), 9, []), [1 2 4 3]);
tmp = cat(3, tmpOdd(:, :, 1:size(tmpOdd,3)-1, :), tmpEven(:, :, 1:size(tmpEven,3)-1, :)); % -1 to remove blanks
    
newOrder = flatten(reshape(1:size(tmp,3), [], 2)'); % 1, 26, 2, 27 ... to interleave
tmp2 = tmp(:, :, newOrder, :);

stimuli.imStack = tmp2;

save(fullfile(rootpath, imFile), 'stimuli');

%% Retroactive addition of stimuliNames

imFile = fullfile('data', 'stimuli', 'stimuli-2015-10-05.mat');
load(fullfile(rootpath, imFile), 'stimuli');

stimuliNames = [repmat({'patterns_sparse'}, 1, 5), ...
 repmat({'gratings_sparse'}, 1, 5), ...
 repmat({'noisebars_sparse'}, 1, 5), ...
 repmat({'waves_sparse'}, 1, 4), ...
 ...
 repmat({'gratings_ori'}, 1, 3), ...
 repmat({'noisebars_ori'}, 1, 3), ...
 repmat({'waves_ori'}, 1, 3), ...
 ...
 repmat({'gratings_cross'}, 1, 4), ...
 ...
 repmat({'patterns_contrast'}, 1, 4), ...
 repmat({'gratings_contrast'}, 1, 4), ...
 repmat({'noisebars_contrast'}, 1, 4), ...
 repmat({'waves_contrast'}, 1, 4)];

stimuli.stimuliNames = stimuliNames;

save(fullfile(rootpath, imFile), 'stimuli');

%% Retroactive fixing of imNums (which are kind of outdated anyway)
imFile = fullfile('data', 'stimuli', 'stimuli-2015-10-05.mat');

load(fullfile(rootpath, imFile), 'stimuli');
stimuli.imNums = [271:289, 292:320];

save(fullfile(rootpath, imFile), 'stimuli');

