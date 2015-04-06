%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus exploration:
%   A sketchpad for trying out different ideas for what new stimuli to use
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparation for noise image: Load the bpfilter
load(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), 'bpfilter');

% Define parameters; borrowed from Kendrick's script
finalres = 800;                % target resolution for the stimuli
res = 256;                     % native resolution that we construct at (or is it 300? or 600? TODO!)
totalfov = 12.5;               % total number of degrees for FOV
rfov = totalfov/2;             % radius of FOV in degrees
cpd = 3;                       % target cycles per degree
cpfov = totalfov*cpd;          % cycles per FOV that we are aiming for
spacing = res/cpfov;           % pixels to move from one cycle to the next

numframes = 9;                 % how many images from each class (if applicable)

cpf = totalfov/2;              % cycles per field of view for standard zebra texture
    % TODO what is this?


%% Build a thresholded noise image
load(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), 'bpfilter');
output = createPatternStimulus([800, 800], 1/100, bpfilter);

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

%% Analyze the sparse grating to show it's really made out of the bpfilter
subchunkIdxs = 182:356;
subchunk = sparseGrating(subchunkIdxs, mid(2));
figure;
subplot(3, 1, 1); plot(subchunk);
subplot(3, 1, 2); plot(abs(fftshift(fft(subchunk))), 'ro-');
subplot(3, 1, 3); plot(-1*bpfilter(:, 10)); xlim([0, 100]);

%% Generate a line pattern windowing onto a pure grating
linewindow = output.*sinim;
linewindow = linewindow - min(linewindow(:)) / (max(linewindow(:)) - min(linewindow(:)));
figure; imshow(linewindow, []);
figure; imshow(abs(fftshift(fft(linewindow))), []);

%% Wiggly aperture, grating backdrop
wigglyAperture = denseGrating .* sparsePattern;
toShow = {denseGrating, sparsePattern, wigglyAperture};
showFourier(toShow);

%% Wiggly backdrop, grating aperture
gratingAperture = densePattern .* sparseGrating;
toShow = {densePattern, sparseGrating, gratingAperture};
showFourier(toShow);