%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus generation for 2015-04-06
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the bpfilter and the base images
load(fullfile(rootpath, 'data', 'input', 'stimuli.mat'), 'bpfilter');

imFile = fullfile(rootpath, 'data', 'input', 'stimuli.mat');
gratingNums = [176:180];
patternNums = [181, 182, 183, 85, 184];
existingIms = loadImages(imFile, [gratingNums, patternNums]);

existingIms = (double(existingIms) / 255) - 0.5;

% Define numbers for bookkeeping:
horizPatternNums = 260:264;
noiseStripeNums = 265:269;

%% Put all in a single stack
sz = size(existingIms);
sz(3) = sz(3) * 2; % there will be twice as many classes
fullStack = zeros(sz);
fullStack(:, :, 1:10, :) = existingIms;
% we will fill in 11:20 later

%% Validation that we should be working at 800x800: compare it to construction at 256
%[output, edge, thresh, res] = createPatternStimulus([800, 800], 1/20, bpfilter);
% % versus
%[output, edge, thresh, res] = createPatternStimulus([256, 256], 1/20, bpfilter);
% output = imresize(output, [800, 800]);
% % nope, this is definitely worse!
% hm, but still doesn't seem right????

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Use the existing sparse gratings as apertures onto noise 
for ii = 1:5
    for frame = 1:size(fullStack,4)
        %noise = randn(800, 800); % Gaussian noise
        %noise = noise./(max(noise(:) - min(noise(:)))) + 0.5;
        %noise(noise<0) = 0; % usually only a few pixels
        %noise(noise>1) = 1;
        %filterednoise = conv2(noise, bpfilter, 'same');
        
        % Use a dense pattern instead
        filterednoise = fullStack(:, :, 6, frame);
        % This works better because the bpfilter is NOT actually the right
        % band size at this resolution
        
        aperture = -1 * fullStack(:, :, ii, frame);
        aperture(aperture < 0) = 0; % remove the flanking stripes

        blursize = 9; % tuned by hand to be correct size
        blurfilt = makegaussian2d(blursize * 6, [], [], blursize, blursize);
            % this ignores scale factors for the above Gaussian
        aperturePad = padarray(aperture, floor(size(blurfilt)/2), 'circular', 'both');
        aperturePad = aperturePad(1:end-1, 1:end-1);
        apertureBroad = conv2(aperturePad, blurfilt, 'valid');
        apertureBroad = apertureBroad - apertureBroad(1, 1); % bring 50% grey back to zero

        noiseLines  = apertureBroad .* filterednoise;
        
        fullStack(:, :, 10 + ii, frame) = noiseLines;
    end
end

% Save it before fussing with scales
saveme = fullStack(:, :, 11:15, :);

%% Scale that down
slice = saveme;
%dynamicRange = [-10, 10]; % TODO make sure this is appropriate for all the images
dynamicRange = [-20, 20];
slice(slice < dynamicRange(1)) = dynamicRange(1);
slice(slice > dynamicRange(2)) = dynamicRange(2);
slice = slice / (dynamicRange(2) - dynamicRange(1));
fullStack(:, :, 11:15, :) = slice;

%% Visualize it
figure; hold on;
imshow(fullStack(:, :, 13, 1), []);

%% Check appropriate width:
figure; hold on;
plot(fullStack(:, 400, 3, 1), 'r-');
plot(fullStack(:, 400, 13, 1), 'g-');

% Check that 50% grey hasn't moved:
% fullStack(1, 1, 13, 1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filter the existing pattern images with one gabor
gaborCpfovs = 45;
fovs = 800;
gaborFiltSize = 32;
cpFiltsize = (gaborCpfovs/ fovs)*gaborCpfovs;

for ii = 6:10
    for frame = 1:size(fullStack,4)
        gaborfilt = makegabor2d(gaborFiltSize, [], [], cpFiltsize, 0, 0, -1);
        
        aperture = -1 * fullStack(:, :, ii, frame);
        aperture(aperture < 0) = 0; % remove the flanking stripes
        aperturePad = padarray(aperture, floor(size(gaborfilt)/2), 'circular', 'both');
        aperturePad = aperturePad(1:end-1, 1:end-1);
        horizPattern  = conv2(aperturePad, gaborfilt, 'valid');
        
        fullStack(:, :, 10 + ii, frame) = horizPattern;
    end
end

savemetoo = fullStack(:, :, 16:20, :);

%% Scale that down
slice = savemetoo;
dynamicRange = [-8, 8];
slice(slice < dynamicRange(1)) = dynamicRange(1);
slice(slice > dynamicRange(2)) = dynamicRange(2);
slice = slice / (dynamicRange(2) - dynamicRange(1));
fullStack(:, :, 16:20, :) = slice;

%% Visualize it
figure; hold on;
imshow(fullStack(:, :, 16, 9), []);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bring everything back into [0 255]
fullStackInt = uint8(round((fullStack + 0.5) * 254));

%% Check local gabor energy
toAnalyze = {fullStackInt(:, :, 3, 1), ...
             fullStackInt(:, :, 8, 1), ...
             fullStackInt(:, :, 13, 1), ...
             fullStackInt(:, :, 18, 1)};
power = cell(size(toAnalyze));

figure;
for ii = 1:length(toAnalyze)
    imStack = toAnalyze{ii};

    outputSz = 150; padSz = 30;
    imStack = resizeStack(imStack, outputSz, padSz);
    imFlat = stackToFlat(imStack);
    output = gaborenergy(imFlat, 8, 2, gaborCpfovs);
    output = flatToStack(output, 1);
    output = sum(output, 5); % summed across orientations

    % Summarize
    maskSize = 34;
    mask = makeCircleMask(maskSize, 90); % Smaller mask, misses the edges; only correct for the 90x90 images
    subplot(1, length(toAnalyze), ii);
    imshow(output, []);
    
    power{ii} = sum(output(mask));
    title(power{ii});
end

%% Check fourier power
showFourier(toAnalyze);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final export!
stimuli = {};

imNums = [gratingNums, patternNums, horizPatternNums, noiseStripeNums];
stimuli.imNums = imNums;

whichOnes = [2:4, 7:9, 12:14, 17:19];
stimuli.imNumsDisplay = imNums(whichOnes);

stimuli.imStack = fullStackInt(:, :, whichOnes, :);

displayRes = [400, 400];
stimuli.imsDisplay = reshape(permute(stimuli.imStack, [1 2 4 3]), size(stimuli.imStack, 1), size(stimuli.imStack, 2), []);
stimuli.imsDisplay = imresize(stimuli.imsDisplay, displayRes);
stimuli.imsDisplay(:, :, end+1) = ones(displayRes) * 127;

save(fullfile(rootpath, 'data', 'input', 'stimuli_2015_04_06'), 'stimuli');

%% Review the final images
figure;
for ii = 1:size(stimuli.imsDisplay, 3)
    imshow(stimuli.imsDisplay(:, :, ii));
    pause();
end
    