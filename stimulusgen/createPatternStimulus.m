function output = createPatternStimulus(sz, relCutoff, bpfilter)
% CREATE PATTERN STIMULUS
%   sz - the desired image size
%   relCutoff - Define a relative cutoff in terms of the available frequencies
%   bpfilter - the convolutional bandpass filter to use, in space domain

    % Create a random seed
    im = randn(sz(1), sz(2));
    im = im./(max(im(:) - min(im(:)))) + 0.5;
    
    % Do the DFT
    dft = fftshift(fft2(im));

    % Find the midpoint pixels
    mid = ceil((size(im)+1)/2);

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
end