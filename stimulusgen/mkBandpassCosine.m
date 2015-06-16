function fltTrunc = mkBandpassCosine(res, cpim, bandwidth, fltsz, doplot)
% MAKE BANDPASS COSINE - Create a raised cosine filter with certain bandpass properties
% Input:
%   res - Image resolution of final image, in pixels
%   cpim - Target band in cycles per image resolution (above)
%   bandwidth - Bandwidth in octaves for the target SF band above
%   fltsz - Truncated size of final spatial filter
% Output:
%   fltTrunc - final truncated cosine filter

if ~exist('doplot','var'), doplot = 0; end

if fltsz < 0
    fltsz = abs(fltsz);
    warning('mkBandpassCosine: fltsz should be positive')
end


band = 1;                      % Fraction of linear bandwidth to use for transition zone of target SF band (ie, how much of it is cosine-shaped)
delta = cpim * (2^bandwidth - 1) / (2^bandwidth + 1); % TODO not sure why this is, but it is the spread +/- of the desired bandwidth

fltF = constructcosinefilter(res,[cpim-delta cpim+delta],band*(2*delta));  % this is the amp spectrum to match
fltTrunc = fouriertospace(fltF,-1*fltsz);
fltTruncF = abs(fftshift(fft2(fltTrunc)));

if doplot
    figure(1); clf; hold all;
    
    subplot(1, 3, 1);
    fltFshift = fftshift(fltF);
    plot(calccpfov1D(res(1)), fltFshift(ceil((res(1)+1)/2), :), 'o-');
    title('Target Fourier domain');
 
    subplot(1, 3, 2);
    plot(calccpfov1D(fltsz), fltTrunc(ceil((fltsz+1)/2), :), 'o-');
    title('Truncated filter');
    
    subplot(1, 3, 3);
    plot(calccpfov1D(fltsz), fltTruncF(ceil((fltsz+1)/2), :), 'o-');
    title('Truncated filter, Fourier domain');    
end

end
