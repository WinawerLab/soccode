function [fltFinalTrunc, fltDesiredTrunc] = mkBandpassDog(res, cpim, bandwidth, fltsz, doplot)
% MAKE BANDPASS DoG - Create a DoG filter with certain bandpass properties
% Input:
%   res - Image resolution of final image, in pixels
%   cpim - Target band in cycles per image resolution (above)
%   bandwidth - Bandwidth in octaves for the target SF band above
%   fltsz - Truncated size of final spatial filter
% Output:
%   fltFinalTrunc - final truncated DoG filter
%   fltDesiredTrunc - targeted raised cosine filter, for comparison

if ~exist('doplot','var'), doplot = 0; end

if fltsz < 0
    fltsz = abs(fltsz);
    warning('mkBandpassDog: fltsz should be positive')
end

%%

band = 1;                      % Fraction of linear bandwidth to use for transition zone of target SF band (ie, how much of it is cosine-shaped)

delta = cpim * (2^bandwidth - 1) / (2^bandwidth + 1); % TODO not sure why this is, but it is the spread +/- of the desired bandwidth

fltDesiredF = constructcosinefilter(res,[cpim-delta cpim+delta],band*(2*delta));  % this is the amp spectrum to match

fltDesiredFshift = ifftshift(fltDesiredF);

%% Create a DoG filter that targets the desired band
[xx,yy] = meshgrid(1:res,1:res);
mid = ceil((res+1)/2);

% Make an initial guess based on approximations
[guess_sd1, guess_sdratio] = mkApproximateDog(res, cpim, 2*delta);
tmpGuess = evaldog2d([mid, mid, guess_sd1, guess_sdratio, 1, 1, 0], xx, yy);
tmpF = abs(fft2(tmpGuess));
guess_gain = max(fltDesiredF(:)) / max(tmpF(:));

fltGuess = evaldog2d([mid, mid, guess_sd1, guess_sdratio, 1, guess_gain, 0], xx, yy);

% Use minimization to try to do even better
options = optimset('Display','iter','MaxFunEvals',Inf,'MaxIter',1000,'TolFun',1e-6,'TolX',1e-6);

% TODO what is thisL
bandexpt = 5;                  % exponent to apply to the amplitude spectrum of target SF band for fitting purposes

% find DOG that best matches fltA
fn = @(a,b) flatten(abs(fft2(evaldog2d([round(res/2) round(res/2) a(1) a(2) 1 a(3) 0], b)))).^bandexpt;
    % DOG first argument is [centerx, centery, sd, sdratio, volratio, gain, offset]
    % DOG second argument is where to evaluate
xdata = [flatten(xx); flatten(yy)];
ydata = flatten(fltDesiredF).^bandexpt;

dogparams_guess = [guess_sd1, guess_sdratio, guess_gain];
[dogparams,~,~,exitflag,~] = lsqcurvefit(fn, dogparams_guess, xdata, ydata, [], [], options); 

assert(exitflag > 0);

%% Use that fit to create the final filter in the spatial domain
fltGuessF = abs(fft2(fltGuess));
fltFinalF = abs(fft2(evaldog2d([round(res/2) round(res/2) dogparams(1) dogparams(2) 1 dogparams(3) 0],xx,yy)));  % get amp spectrum of DOG

fltDesiredTrunc = fouriertospace(fltDesiredF,-1*fltsz);
fltGuessTrunc = fouriertospace(fltGuessF,-1*fltsz);
fltFinalTrunc = fouriertospace(fltFinalF,-1*fltsz);

%% Comparison time!
if doplot
    fltGuessFshift = ifftshift(fltGuessF);
    fltFinalFshift = ifftshift(fltFinalF);
    
    figure(1); clf; hold all;
    plot(calccpfov1D(res), fltDesiredFshift(mid, :));
    plot(calccpfov1D(res), fltGuessFshift(mid, :));
    plot(calccpfov1D(res), fltFinalFshift(mid, :));
    legend('Desired', 'Approximate', 'Minimized');
 
    figure(2); clf; hold all;
    plot(calccpfov1D(fltsz), fltDesiredTrunc(ceil((fltsz+1)/2), :), 'o-');
    plot(calccpfov1D(fltsz), fltGuessTrunc(ceil((fltsz+1)/2), :), 'o-');
    plot(calccpfov1D(fltsz), fltFinalTrunc(ceil((fltsz+1)/2), :), 'o-');
    legend('Desired', 'Approximate', 'Minimized');
end

end
