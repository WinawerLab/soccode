%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus exploration:
%   A sketchpad for trying out different ideas for what new stimuli to use
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparation for noise image: Load the bpfilter
load(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), 'bpfilter');

%% Build a thresholded noise image
load(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), 'bpfilter');
[output, edge, thresh, res] = createPatternStimulus([800, 800], 1/20, bpfilter);

%% Generate a pure grating, just to show it's doable
N = 800;
k = 40;
sinusoid = sin(2*pi*k/N*(1:N));
sinim = repmat(sinusoid, N, 1);
figure; imshow(sinim/2 + 0.5);

%% Load existing images
imFile = fullfile(rootpath, 'data', 'input', 'stimuli.mat');
existingIms = loadImages(imFile, [176:184]);

existingIms = (double(existingIms) / 255) - 0.5;

denseGrating = existingIms(:,:,1,1);
sparseGrating = existingIms(:,:,3,1);

densePattern = existingIms(:,:,6,1);
sparsePattern = existingIms(:,:,8,1);

mid = ceil((size(denseGrating)+1)/2);


%% Analyze the dense grating to show it isn't a pure grating
subchunkIdxs = 182:356;
subchunk = denseGrating(subchunkIdxs, mid(2));
figure;
subplot(2, 1, 1); plot(subchunk);
subplot(2, 1, 2); plot(abs(fftshift(fft(subchunk))), 'ro-');

%% Convolve with bpfilter?

%% Analyze the sparse grating to show it's really made out of the bpfilter
subchunkIdxs = 182:356;
subchunk = sparseGrating(subchunkIdxs, mid(2));
figure;
subplot(3, 1, 1); plot(subchunk);
subplot(3, 1, 2); plot(abs(fftshift(fft(subchunk))), 'ro-');
subplot(3, 1, 3); plot(-1*bpfilter(:, 10)); xlim([0, 100]);

%% Analyze the sparse pattern; it's also bpfilter
figure;
subplot(3, 1, 1); plot(sparsePattern(:, mid(2)));
subplot(3, 1, 2); plot(abs(fftshift(fft(sparsePattern))), 'ro-');
subplot(3, 1, 3); plot(-1*bpfilter(:, 10)); xlim([0, 100]);

%% Generate a line pattern windowing onto a pure grating
linewindow = output.*sinim;
linewindow = linewindow - min(linewindow(:)) / (max(linewindow(:)) - min(linewindow(:)));
figure; imshow(linewindow, []);
figure; imshow(abs(fftshift(fft(linewindow))), []);

%% Wiggly aperture, grating backdrop
wigglyAperture = denseGrating .* sparsePattern;
figure; imshow(wigglyAperture, []);
toShow = {denseGrating, sparsePattern, wigglyAperture};
showFourier(toShow);

%% Convolve? (time-consuming)
temp = conv2(sparsePattern, sinim);

%% Multiply in frequency domain (haven't done this yet)
temp2 = ifft2(fft2(denseGrating) .* fft2(sparsePattern));

%% Filter line image w/ one gabor
gaborfilt = makegabor2d(32, [], [], 4, 0, 0, 2);
edgePad = padarray(edge, floor(size(gaborfilt)/2), 'circular', 'both');
output = conv2(edgePad, gaborfilt, 'valid');
showFourier({edge, gaborfilt, gaborEdge});
figure; imshow(gaborEdge, []);
    % YES, do the ocean ripples one

%% Filter grating with low-frequency noise
res = (res - (min(res(:)))) / (max(res(:)) - min(res(:)));
gratingNoise = denseGrating .* res;
figure; imshow(gratingNoise, []);

gratingThresh = denseGrating .* thresh;

%% Create a literal carrier-frequency bandpass noise
noise = randn(800, 800);
noise = noise./(max(noise(:) - min(noise(:)))) + 0.5;
filterednoise = conv2(noise, bpfilter, 'same');
figure; imshow((sinim/2 + 0.5) .* filterednoise, [])

%% Do that, with the existing sparse gratings
noise = randn(800, 800);
noise = noise./(max(noise(:) - min(noise(:)))) + 0.5;
filterednoise = conv2(noise, bpfilter, 'same');

aperture = -1 * sparseGrating;
aperture(aperture < 0) = 0; % remove the flanking stripes

blursize = 3; % TODO: figure out the appropriate blur size
blurfilt = makegaussian2d(blursize * 5, [], [], blursize, blursize );
aperturePad = padarray(aperture, floor(size(blurfilt)/2), 'circular', 'both');
apertureBroad = conv2(aperturePad, blurfilt, 'valid');

noiseLines  = apertureBroad .* filterednoise;
figure; imshow(noiseLines, []);

%% Visualize band energy (not complete)
numor = 8;
numph = 2;

outputSz = 150; padSz = 30;
imStack = resizeStack(wigglyAperture, outputSz, padSz);
cpfovsA = 1 * 37.5*(180/150);
gaborFlatA = gaborenergy(wigglyAperture, numor, numph, cpfovsA);

cpfovsB = 0.5 * 37.5*(180/150);
gaborFlatB = gaborenergy(wigglyAperture, numor, numph, cpfovsB);


%% Edge-based aperture
wigglyAperture = denseGrating .* sparsePattern;
figure; imshow(wigglyAperture, []);
toShow = {denseGrating, sparsePattern, wigglyAperture};
showFourier(toShow);

%% Wiggly backdrop, grating aperture
gratingAperture = densePattern .* sparseGrating;
figure; imshow(gratingAperture, []);
toShow = {densePattern, sparseGrating, gratingAperture};
showFourier(toShow);