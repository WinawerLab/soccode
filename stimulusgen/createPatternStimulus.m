function [output, edge, thresh, result] = createPatternStimulus(sz, relCutoff, bpfilter)
% CREATE PATTERN STIMULUS
%   sz - the desired image size
%   relCutoff - Define a relative cutoff in terms of the available frequencies
%   bpfilter - the convolutional bandpass filter to use, in space domain

    if ~exist('toplot', 'var'), toplot = false; end

    % Create a random seed
    im = randn(sz(1), sz(2));
    im = im./(max(im(:) - min(im(:)))) + 0.5;
    
    % Find the midpoint pixels
    mid = ceil((size(im)+1)/2);

    % Create a soft round filter in Fourier space
    radius = relCutoff*size(im,1)/2;
    mask = mkDisc(size(im), radius, mid, radius/5);

    % Filter the image
    dft = fftshift(fft2(im));
    mdft = mask.*dft;
    result = ifft2(ifftshift(mdft)); 

    % Threshold the filtered noise
    thresh = result - min(result(:)) > (max(result(:)) - min(result(:)))/2;

    % Grab edges with derivative filter
    edge1 = [0, 0, 0; 1, 0, -1; 0, 0, 0];
    edge2 = [0, 1, 0; 0, 0, 0; 0, -1, 0];
    edge = -1*(imfilter(double(thresh), edge1, 'circular').^2 + imfilter(double(thresh), edge2, 'circular').^2);
    
    edge = .125*edge; % takes the max down to 0.25 (but maybe should be 0.5?)

    % Filter convolutionally with bpfilter in the image domain
    output = imfilter(edge, bpfilter, 'circular');

end