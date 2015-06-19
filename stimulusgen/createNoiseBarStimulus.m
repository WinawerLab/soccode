function [noiseBars, aperture] = createNoiseBarStimulus(noiseStimuli, lineStimuli, blursize, compareVar)
% CREATE NOISE BAR STIMULUS
% Stimulus using sparse gratings apertures onto filtered noise
%
%   noiseStimuli - a stack of filtered noise stimuli, e.g. from
%       createFilteredNoiseStimulus
%   lineStimuli - a stack of thin line stimuli, e.g. the second return
%       value of createBarStimulus
%   blurSize - how wide to blur the lines; must be determined by eye
%       in the current implementation
%   compareVar - the target variance of the set of nonzero pixels

assert(all(size(noiseStimuli) == size(lineStimuli)));

blurfilt = makegaussian2d(blursize * 6, [], [], blursize, blursize);
blurfilt = blurfilt / (0.5/max(blurfilt(:)));

aperture = imfilter(lineStimuli, blurfilt);
noiseBars = aperture .* noiseStimuli;

for dim3 = 1:size(noiseBars, 3)
    for dim4 = 1:size(noiseBars, 4)
        tmp = noiseBars(:, :, dim3, dim4);
        noiseLineVar = var(tmp(tmp~=0));
        contrastBoost = sqrt(compareVar / noiseLineVar);

        noiseBars(:, :, dim3, dim4) = contrastBoost * noiseBars(:, :, dim3, dim4);
    end
end

noiseBars(noiseBars > 0.5) = 0.5;
noiseBars(noiseBars < -0.5) = -0.5;

end

