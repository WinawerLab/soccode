%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus exploration:
%   A sketchpad for trying out different ideas for what new stimuli to use
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Superimpose two sines of different amplitudes
x = linspace(0, pi*6, 400);
factor = 2;
sin1 = sin(x*factor);
sin2 = sin(2*x*factor);
sin3 = sin(3*x*factor);

combo1 = (sin1+sin2)/2;
combo2 = sin1 + sin2/2;
combo3 = sin1 + sin3/2;
combo4 = sin1 - sin3/2;

im1 = repmat(sin1, size(sin1,2), 1);
im2 = repmat(sin2, size(sin2,2), 1);
im3 = repmat(sin3, size(sin3,2), 1);

c1 = repmat(combo1, size(combo1,2), 1);
c2 = repmat(combo2, size(combo2,2), 1);
c3 = repmat(combo3, size(combo3,2), 1);
c4 = repmat(combo4, size(combo4,2), 1);

figure; range = [-1.5, 1.5];
subplot(2, 3, 1); imshow(im1, range);
subplot(2, 3, 4); plot(sin1);
subplot(2, 3, 2); imshow(im2, range);
subplot(2, 3, 5); plot(sin2);
subplot(2, 3, 3); imshow(im3, range);
subplot(2, 3, 6); plot(sin3);

figure;
subplot(2, 5, 1); imshow(c1, range);
subplot(2, 5, 6); plot(combo1);
subplot(2, 5, 2); imshow(c2, range);
subplot(2, 5, 7); plot(combo2);
subplot(2, 5, 3); imshow(c3, range);
subplot(2, 5, 8); plot(combo3);
subplot(2, 5, 4); imshow(c4, range);
subplot(2, 5, 9); plot(combo4);

%% Preparation for noise image: Load the bpfilter
load(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), 'bpfilter');

%% Build a thresholded noise image
im = randn(400, 400);
im = im./(max(im(:) - min(im(:)))) + 0.5;

%% Do the DFT
dft = fftshift(fft2(im));
logAbsDft = log(abs(dft));

% Find the midpoint
mid = ceil((size(im)+1)/2); % Midpoint pixels

% Define the frequencies to use, in terms of *k*, cycles per vector length.
% Negative frequencies are used as the way to deal with Nyquist limit.
[freqX freqY] = meshgrid([1:size(im,2)]-mid(2), [1:size(im,1)]- mid(1));

% Define a relative cutoff in terms of the available frequencies:
%relCutoff = 1/3;
relCutoff = 1/100;

% Nice soft round filter:
radius = relCutoff*size(im,1)/2;
mask = mkDisc(size(im), radius, mid, 60);

% Filter the image
mdft = mask.*dft;
res = ifft2(ifftshift(mdft));
imStats(imag(res))

% Threshold
thresh = res - min(res(:)) > (max(res(:)) - min(res(:)))/2;

% Grab edges with derivative filter
edge1 = [1, 0, -1];
edge2 = [1; 0; -1];
edge = conv2(double(thresh), edge1, 'same').^2 + conv2(double(thresh), edge2, 'same').^2;
figure; imshow(edge, []);

% Filter convolutionally with bpfilter; it's too small to be intended in
% the Fourier domain
output = conv2(edge, bpfilter, 'same');
%output = output.^2;

% Visualize
figure; imshow(output, [min(output(:)), max(output(:))]);

%% What's the old and new Fourier spectrum?
figure;
imshow(log(abs(fftshift(fft2(output)))), []);

figure;
imshow(shift(output, mid));
