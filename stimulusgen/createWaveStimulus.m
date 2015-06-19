function [wavesThresh, wavesUnthresh] = createWaveStimulus(edgeStimuli, angle, bpfilter, cpim, contrastCutoff, smoothness, targetVar)
% CREATE WAVE STIMULUS - Filter pattern stimuli to have one orientation,
% and thresholded to only contain high contrast activations
%
%   edgeStimuli - a stack of edge stimuli, e.g. the second return value of
%        createPatternStimulus
%   angle - from 0 to 2pi
%   bpfilter - the bandpass filter used in constructing the pattern
%   contrastCutoff - minimum pixel value to define the neighborhood to retain
%       in the thresholding step
%   smoothness - how smoothly to define the transition to the neighborhood

% Gabor filter the edge stimuli
res = size(edgeStimuli, 1);
fltsz = size(bpfilter, 1);
cpflt = (cpim/res)*fltsz;
gaborflt = makegabor2d(fltsz, [], [], cpflt, angle, 0, -1);

waves = imfilter(edgeStimuli, gaborflt, 'circular');
waves = waves * (0.5 / max(abs(waves(:))));

% Create a mask to identify regions of high pixel values
highcontrast = waves;
highcontrast(abs(highcontrast) > contrastCutoff) = 1;
highcontrast(highcontrast < 1) = 0;

% Blur that mask, to delineate neighborhoods of high contrast
[~, width] = min(bpfilter(ceil(fltsz+1)/2, :));
blurflt = mkDisc(fltsz, width, [ceil(fltsz+1)/2, ceil(fltsz+1)/2], smoothness);

highcontrast = imfilter(highcontrast, blurflt, 'circular');
highcontrast(highcontrast > 1) = 1; % truncate the mask

% Mask the waves to remove low contrast regions
wavesThresh = waves .* highcontrast;

% Fix the contrast of both to the same value
wavesVar = var(wavesThresh(wavesThresh ~= 0));
contrastBoostWaves = sqrt(targetVar / wavesVar);

wavesUnthresh = waves * contrastBoostWaves;
wavesUnthresh(wavesUnthresh > 0.5) = 0.5;
wavesUnthresh(wavesUnthresh < -0.5) = -0.5;

wavesThresh = wavesThresh * contrastBoostWaves;
wavesThresh(wavesThresh > 0.5) = 0.5;
wavesThresh(wavesThresh < -0.5) = -0.5;

end

