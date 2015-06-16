res = 400;

cpd = 3; % cycles per degree
dpim = 24; % degrees per image

cpim = cpd * dpim;

% slow:
filtsz = 31;
bw_octaves = 1;
[dog, cs] = mkBandpassDog(res, cpim, bw_octaves, filtsz, 0);

%% fast:
patternDog = createPatternStimulus([res,res], 1/20, dog);
patternCs = createPatternStimulus([res,res], 1/20, cs);
patternMx = max([abs(patternDog(:)); abs(patternCs(:))]);

fourierDog = abs(fftshift(fft2(patternDog)));
fourierCs = abs(fftshift(fft2(patternCs)));
fourierMn = min([fourierDog(:); fourierCs(:)]);
fourierMx = max([fourierDog(:); fourierCs(:)]);

figure(1); clf;
subplot(2, 2, 1); imshow(patternDog, [-patternMx, patternMx]);
subplot(2, 2, 2); imshow(patternCs, [-patternMx, patternMx]);
subplot(2, 2, 3); imshow(fourierDog, [fourierMn, fourierMx]);
subplot(2, 2, 4); imshow(fourierCs, [fourierMn, fourierMx]); % why is there a broadband term?

%%
csBroad = mkBandpassCosine(res, cpim, 1, filtsz, 0);
csMid = mkBandpassCosine(res, cpim, 0.75, filtsz, 0);
csNarrow = mkBandpassCosine(res, cpim, 0.5, filtsz, 0);

fDogFilt = abs(fftshift(fft2(dog)));
fCsBroad = abs(fftshift(fft2(csBroad)));
fCsMid = abs(fftshift(fft2(csMid)));
fCsNarrow = abs(fftshift(fft2(csNarrow)));

%%
filtmid = ceil((filtsz+1)/2);
figure(2); clf;

subplot(2, 4, 1); plot(calccpfov1D(filtsz),dog(filtmid, :)); yaxis([-0.2, 0.7]);
subplot(2, 4, 2); plot(calccpfov1D(filtsz),csBroad(filtmid, :)); yaxis([-0.2, 0.7]);
subplot(2, 4, 3); plot(calccpfov1D(filtsz),csMid(filtmid, :)); yaxis([-0.2, 0.7]);
subplot(2, 4, 4); plot(calccpfov1D(filtsz),csNarrow(filtmid, :)); yaxis([-0.2, 0.7]);

subplot(2, 4, 5); plot(calccpfov1D(filtsz),fDogFilt(filtmid, :)); yaxis([0, 4]);
subplot(2, 4, 6); plot(calccpfov1D(filtsz),fCsBroad(filtmid, :)); yaxis([0, 4]);
subplot(2, 4, 7); plot(calccpfov1D(filtsz),fCsMid(filtmid, :)); yaxis([0, 4]);
subplot(2, 4, 8); plot(calccpfov1D(filtsz),fCsNarrow(filtmid, :)); yaxis([0, 4]);

