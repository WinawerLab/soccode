function [knockout, aperture] = createKnockoutStimulus(barStimuli, lineStimuli, blurSize, keepLines)
% CREATE WAVE STIMULUS - Filter pattern stimuli to have one orientation,
% and thresholded to only contain high contrast activations
%
%   barStimuli - a stack of sparse bar stimuli, e.g. the first return
%       value of createBarStimulus; defines the main orientation
%   lineStimuli - a stack of thin line stimuli, e.g. the second return
%       value of createBarStimulus; will get rotated 90 degrees
%   blurSize - how wide to blur the lines; must be determined by eye
%       in the current implementation
%   smoothness - how smoothly to define the transition to the lines
%   keepLines - 1 if the lines define a mask of areas to keep, 0 if the
%       lines define a mask of areas to remove


lineStimuli = imrotate(lineStimuli, 90);

blurFilt = makegaussian2d(blurSize * 6, [], [], blurSize, blurSize); % gaussian
blurFilt = blurFilt / (0.5/max(blurFilt(:))); % gaussian

aperture = imfilter(lineStimuli, blurFilt);
aperture = -1 * aperture/max(abs(aperture(:)));
if ~keepLines
    aperture = 1 - aperture;
end

knockout = aperture .* barStimuli;

% restore the contrast by examining the middle half
sz = size(barStimuli, 1); % assume square
premx = max(abs(barStimuli(ceil(sz/4):3*ceil(sz/4), ceil(sz/4):3*ceil(sz/4))));
postmx = max(abs(knockout(ceil(sz/4):3*ceil(sz/4), ceil(sz/4):3*ceil(sz/4))));

knockout = knockout * (premx / postmx);
knockout(knockout > 0.5) = 0.5;
knockout(knockout < -0.5) = -0.5;

end