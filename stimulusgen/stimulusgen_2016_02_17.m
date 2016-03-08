%% Stimulus generation for the October 2015 stimulus set

%% Set up image size parameters
res = 600; %400;                     % native resolution that we construct at
totalfov = 18; %12;                 % total number of degrees for image
%cpd = [0.75, 1.5, 3, 6];               % target cycles per degree (previously was only 3)
% cpd = [5.0, 2.5, 1.25, 0.6, 0.3];% 0.08, 0.04, 0.02];
% cpd = [0.02, 0.04, 0.08, 0.16, 0.3, 0.6, 1.25, 2.5, 5.0]; 
cpd = 10 * 0.5.^(1:0.5:5);
ncpd = length(cpd);

maskFrac = 17/18; %11.5/totalfov;      % what fraction of radius for the circular mask to start at

nframes = 9;                 % how many images from each class

radius = totalfov/2;           % radius of image in degrees
cpim = totalfov*cpd;           % cycles per image that we are aiming for
spacing = res./cpim;            % pixels to move from one cycle to the next

span = [-0.5, 0.5];             % dynamic range, to put into 'imshow' etc.

%% Choose which bandpass filter to use
bandwidth = 1;

clear flt;
for ii = 1:ncpd
    disp(ii)
    fltsz = (32 * 2^(ceil(ii/2)-1)) - 1;
    disp(fltsz)
    flt{ii} = mkBandpassCosine(res, cpim(ii), bandwidth, fltsz, 0);
end

%% Make circular stimulus masks
innerres = floor(4/totalfov * res/2)*2;
mask = makecircleimage(res,res/2*maskFrac,[],[],res/2);  % white (1) circle on black (0)

%% Patterns
%patvals = [0.125, 0.25, 0.5, 1] * 0.12;
%patvals = [0.0039, 0.0078, 0.0156, 0.0312, 0.0625, 0.125, 0.25, 0.5, 1] * 0.12;
%patvals = [1, 0.5, 0.25, 0.125, 0.0625] * 0.12;
patvals = cpd/42; % forty-two is just a good number that seems to work
patterns = zeros(res, res, ncpd, nframes);
edges = zeros(res, res, ncpd, nframes);
for ii = 1:ncpd
    disp(ii);
    tic
    for jj = 1:nframes
        [output, edge] = createPatternStimulus([res, res], patvals(ii), flt{ii});
        patterns(:, :, ii, jj) = output;
        edges(:, :, ii, jj) = edge;
    end
    toc
end

contrastBoostPats = 1.9342; % saved from a good run with smooth contours
patterns = patterns * contrastBoostPats;
patterns(patterns > 0.5) = 0.5;
patterns(patterns < -0.5) = -0.5;

display('Patterns done');

% CHECK - count blank pixels to match sparsity of patterns and bars
% barsum = squeeze(sum(sum(barsSparsity==0, 1), 2)); % can also do abs(barsOri) for another check
% patsum = squeeze(sum(sum(patterns==0, 1), 2)); % or include a square for a variance check
% 
% figure; hold on;
% %plot(patvals, patsum, 'o');
% plot(patvals, mean(patsum, 2), 'rx-');
% %plot(patvals, patsum, 'o');
% plot(patvals, mean(barsum, 2), 'bx-');

%% Bandpassed white noise
compareIms = patterns(:, :, 1:3, :);
compareVar = var(compareIms(compareIms ~= 0)); % 0.0325
noise = zeros(res, res, ncpd, nframes);
for ii = 1:ncpd
    disp(ii);
    tic
    noise(:,:,ii,:) = createFilteredNoiseStimulus(res, flt{ii}, compareVar, nframes);
    toc
end

display('Noise done');

%% Blank
blank = zeros(res, res, 1, nframes);

%% Combine everything
%canonicalContrast = 0.25;
canonicalContrast = 1;
everything = canonicalContrast * cat(3, patterns, noise, blank);
everything = bsxfun(@times, mask, everything);

%% Visualize everything
%showme = 1:size(everything, 3);%1:size(everything, 3); % 30:34
%figure; for ii = showme, imshow(everything(:, :, ii, 1), span); title(ii); waitforbuttonpress; end; %pause(0.5); end;

%% Add metadata and save
clear stimuli;
stimuli.imStack = uint8(round((everything+0.5)*255));
stimuliNames = [repmat({'patterns_SF'}, 1, ncpd), ...
 repmat({'noise_SF'}, 1, ncpd)];
stimuli.stimuliNames = stimuliNames;
stimuli.cpd = cpd;
stimuli.patvals = patvals;

% TODO: make sure to rename the filename below if you're rerunning this and
% don't want to overwrite
save(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-new.mat'), 'stimuli', '-v7.3');

%% Patterns only
everything = canonicalContrast * cat(3, patterns, blank); % patterns only
everything = bsxfun(@times, mask, everything);
clear stimuli;
stimuli.imStack = uint8(round((everything+0.5)*255));
stimuli.stimuliNames = repmat({'patterns_SF'}, 1, ncpd); % patterns only
stimuli.cpd = cpd;
stimuli.patvals = patvals;
save(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-patterns-new.mat'), 'stimuli', '-v7.3');

%% Noise only
everything = canonicalContrast * cat(3, noise, blank); % noise only
everything = bsxfun(@times, mask, everything);
clear stimuli;
stimuli.imStack = uint8(round((everything+0.5)*255));
stimuli.stimuliNames = repmat({'noise_SF'}, 1, ncpd); % noise only
stimuli.cpd = cpd;
save(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-noise-new.mat'), 'stimuli', '-v7.3');

%% FIX THE THING
load(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-noise.mat'));
stimuli.noise = permute(stimuli.imStack, [1 2 4 3]);
stimuli.noise = reshape(stimuli.noise, size(stimuli.noise,1), size(stimuli.noise,2), []);
save(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-noise.mat'), 'stimuli', '-v7.3');

load(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-patterns.mat'));
stimuli.patterns = permute(stimuli.imStack, [1 2 4 3]);
stimuli.patterns = reshape(stimuli.patterns, size(stimuli.patterns,1), size(stimuli.patterns,2), []);
save(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17-patterns.mat'), 'stimuli', '-v7.3');

load(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17.mat'));
stimuli.all = permute(stimuli.imStack, [1 2 4 3]);
stimuli.all = reshape(stimuli.all, size(stimuli.all,1), size(stimuli.all,2), []);
save(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2016-02-17.mat'), 'stimuli', '-v7.3');