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
%im = randn(100, 100);
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
relCutoff = 1/100;
%relCutoff = 1/100;

% Nice soft round filter:
radius = relCutoff*size(im,1)/2;
mask = mkDisc(size(im), radius, mid, 60);

% Filter the image
mdft = mask.*dft;
res = ifft2(ifftshift(mdft));

% Threshold
thresh = res - min(res(:)) > (max(res(:)) - min(res(:)))/2;

% Grab edges with derivative filter
% (the padding enables us to do circular convolution)
threshPad = padarray(thresh, [1, 1], 'circular', 'both');
edge1 = [0, 0, 0; 1, 0, -1; 0, 0, 0];
edge2 = [0, 1, 0; 0, 0, 0; 0, -1, 0];
edge = conv2(double(threshPad), edge1, 'valid').^2 + conv2(double(threshPad), edge2, 'valid').^2;
%figure; imshow(edge, []);

% Filter convolutionally with bpfilter; it's too small to be intended in
% the Fourier domain
edgePad = padarray(edge, floor(size(bpfilter)/2), 'circular', 'both');
output = conv2(edgePad, bpfilter, 'valid');

%% Show Fourier spectra
figure;
tinybp = placematrix(zeros(size(edge)), bpfilter, mid - size(bpfilter)/2);
toShow = {im, ifft2(ifftshift(mask)), res, double(thresh), edge, bpfilter, tinybp, output};
for ii = 1:length(toShow)
    subplot(3, length(toShow), ii);
    imshow(toShow{ii}, [min(toShow{ii}(:)), max(toShow{ii}(:))]);
    subplot(3, length(toShow), length(toShow) + ii);
    ft = log(abs(fftshift2(fft2(toShow{ii}))));
    imshow(ft, [min(ft(:)), max(ft(:))]);
    subplot(3, length(toShow), length(toShow)*2 + ii);
    ft = abs(fftshift2(fft2(toShow{ii})));
    imshow(ft, [min(ft(:)), max(ft(:))]);
end

%% What if we had done a real band pass?
lpsize = 1/4;
lpfourier = reshape(mvnpdf([freqX(:), freqY(:)], [0,0], size(im)*lpsize), size(im));

hpsize = 1/2;
hpfourier = reshape(mvnpdf([freqX(:), freqY(:)], [0,0], size(im)*hpsize), size(im));

filt1 = hpfourier .* (1 - lpfourier);
filt2 = hpfourier - lpfourier + 1;

%% Try again. Those sum to 1. The random person's guess doesn't.
distances = reshape((freqX(:).^2 + freqY(:).^2).^0.5, size(im));
hpsigma = 40;
hpgauss = exp(-distances.^2 / (2*hpsigma^2));
lpsigma = 20;
lpgauss = exp(-distances.^2 / (2*lpsigma^2));

%bpgauss = hpgauss .* (1-lpgauss);
bpgauss = hpgauss/2 - lpgauss/2;
bpspace = log(abs(ifftshift(ifft2(bpgauss))));
    % This looks crazy, but... another method gave this too, so... ???
    % (I bet I'm not handling phase correctly?)
    
%% What happens then?
fftim = fftshift2(fft2(output));
mag = abs(fftim);
phase = angle(fftim);

%F_recon = mag.*exp(1i*phase);

% Stopped here... didn't seem fruitful anymore

%% Remember what it is that Jon wants? Namely, for me to generate images!
% For use in a scan!!
% I need to generate at least a sample of a cross-wise one of these for
% that to work

%% Generate a pure grating, just to show it's doable
N = size(im,1);
k = N / 8;
sinusoid = sin(2*pi*k/N*(1:N));
sinim = repmat(sinusoid, size(im,2), 1);
figure; imshow(sinim/2 + 0.5);

%% Generate a sparse grating

%% Generate a line pattern windowing onto a pure grating
linewindow = output.*sinim;
linewindow = linewindow - min(linewindow(:)) / (max(linewindow(:)) - min(linewindow(:)));
figure; imshow(linewindow, []);
figure; imshow(abs(fftshift(fft(linewindow))), []);
