function [sd1, sdratio] = mkApproximateDog(res, fpix, bpix, toplot)
% Get approximate DoG parameters for a desired frequency and bandwidth.
% For a better approximation, use mkBandpassDog which uses minimization
% to get even closer.
%   res - desired square resolution
%   fpix - desired peak frequency, in cycles per res pixels
%   bpix - desired bandwidth at half max, in cycles per res pixels
%   plot - optional, if '1' then show the DoG
% Note, a bpix lower than fpix*1.2 will be ignored.

    if ~exist('toplot', 'var'), toplot = 0; end

    % Make the approximation
    if bpix / fpix <= 1.2
        sdratio = 2;
    else
        sdratio = bpix/(0.3*fpix) - 2;
    end
    sd1 = 2*res/(2*pi) * (1/fpix) * sqrt(log(sdratio)/(sdratio^2 - 1));

    % Plotting
    if toplot
        mid = ceil((res+1)/2);
        [xx,yy] = meshgrid(1:res,1:res);
        filt = evaldog2d([mid, mid, sd1, sdratio, 1, 1, 0], xx, yy);
        %figure; imshow(filt, []);
        %figure; plot(filt(mid, :));

        f = abs(fftshift(fft2(filt)));
        figure; imshow(f, []);
        plot(calccpfov1D(res), f(mid, :));

        peak = max(f(:));
        hold on; plot(fpix, linspace(0,peak,100), 'r-');

        if bpix/fpix <= 1.2
            bplotL = bpix / 2;
            bplotR = bpix / 2;
        else
            bplotL = fpix * 0.6;
            bplotR = bpix - bplotL;
        end
        plot(linspace(fpix-bplotL, fpix+bplotR, 100), peak/2);
        hold off;
        
    end
end