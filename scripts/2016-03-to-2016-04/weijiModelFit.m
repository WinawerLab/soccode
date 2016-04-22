%% Weiji model fitting

%% Load fMRI data
data = load_subj001_2015_10_22();
whichRoi = 'RV1_2to4deg';
targetVec = double(data.betamn{strInCellArray(whichRoi, data.roiNames)});

% TESTING: truncate categories to make sure it's working
whichClasses = [8, 9, 10, 29, 30, 31, 32, 33, 34, 35, 36];
subset = 'partial';
%whichClasses = 1:48;
%subset = 'all';

targetVec = targetVec(whichClasses);

%% Load raw image data
imFile = fullfile('data', 'stimuli', 'stimuli-2015-10-05.mat');
load(fullfile(rootpath, imFile), 'stimuli');
imStack = double(stimuli.imStack);
imStack = imStack/255 - 0.5;

%% Load preprocessed image data

%datadir = fullfile(rootpath, 'data', 'preprocessing', '2016-03-30');
datadir = fullfile(rootpath, 'data', 'preprocessing', '2016-04-05');

if ~exist(fullfile(datadir, ['A_outfirst_', subset, '.mat']), 'file')
    Amat = zeros(501, 501, 8, 9, length(whichClasses));
    for ii = 1:length(whichClasses)
        load(fullfile(datadir, ['A_outfirst_', num2str(whichClasses(ii)), '.mat']), 'outfirst'); % 501 * 501 * 8 * 9
        Amat(:,:,:,:,ii) = outfirst;
        clear outfirst;
    end
    save(fullfile(datadir, ['A_outfirst_', subset, '.mat']), 'Amat')
else
    load(fullfile(datadir, ['A_outfirst_', subset, '.mat']), 'Amat')
end

if ~exist(fullfile(datadir, ['B_outsecond_', subset, '.mat']), 'file')
    Bmat = zeros(401, 401, 8, 9, length(whichClasses));
    for ii = 1:length(whichClasses)
        load(fullfile(datadir, ['B_outsecond_', num2str(whichClasses(ii)), '.mat']), 'outsecond'); % 501 * 501 * 8 * 9
        Bmat(:,:,:,:,ii) = outsecond;
        clear outsecond;
    end
    save(fullfile(datadir, ['B_outsecond_', subset, '.mat']), 'Bmat')
else
    load(fullfile(datadir, ['B_outsecond_', subset, '.mat']), 'Bmat')
end

%% The old way versus the new old way
demostim = 29; %33;
stimulus = imStack(:,:,demostim,1);
[respOld, outfirstOld, outsecondOld] = catherine_secondordercontrast(stimulus, 1, 0);
[respOldFix, outfirstOldFix, outsecondOldFix] = catherine_secondordercontrast(stimulus, 1, 1);

%% Exact same plot as before
demostim = 29; %33;
stimulus = imStack(:,:,demostim,1);
datadir = fullfile(rootpath, 'data', 'preprocessing', '2016-04-05');
load(fullfile(datadir, ['A_outfirst_', num2str(demostim), '.mat']), 'outfirst');
load(fullfile(datadir, ['B_outsecond_', num2str(demostim), '.mat']), 'outsecond');

figure;
subplot(3,3,1); imshow(stimulus, []); colormap('gray'); freezeColors; title('Stimulus');

%
poprespfirst = squeeze(sum(sum(outfirst,4),3));
subplot(3,3,2); imshow(poprespfirst,[]); colormap('gray'); freezeColors; title('Population response, FIRST'); 

%respfirst = squeeze(sum(sum(outfirst,2),1));
%subplot(2,3,4); imagesc(respfirst'); axis xy; title('FIRST response, summed across space'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF');

allinone = reshape(permute(outfirst, [1 4 2 3]), size(outfirst,1)*size(outfirst,4), size(outfirst,2)*size(outfirst,3));
subplot(3,3,[5 8]); imshow(allinone, []); axis xy; colormap('gray'); freezeColors; title('All in one, FIRST');

% 
poprespsecond = squeeze(sum(sum(outsecond,4),3));
subplot(3,3,3); imshow(poprespsecond, []); colormap('gray'); freezeColors; title('Population response, SECOND'); 

%respsecond = squeeze(sum(sum(outsecond,2),1));
%subplot(2,3,6); imagesc(respsecond'); axis xy; title('SECOND-order response, summed across space'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF');

allinonesecond = reshape(permute(outsecond, [1 4 2 3]), size(outsecond,1)*size(outsecond,4), size(outsecond,2)*size(outsecond,3));
subplot(3,3,[6 9]); imshow(allinonesecond, []); axis xy; colormap('gray'); freezeColors; title('All in one, SECOND');


%% All in one with Amat, Bmat
totalresponses = zeros(1,length(whichClasses));
for ii = 1:length(whichClasses)
    outfirst = Amat(:,:,:,:,ii);
    outsecond = Bmat(:,:,:,:,ii);
    respfirst = squeeze(sum(sum(outfirst,2),1));
    respsecond = squeeze(sum(sum(outsecond,2),1));

    subplot(3,4,ii);
    imagesc(respsecond'); axis xy;
    title(num2str(whichClasses(ii)));
    colormap('parula'); freezeColors;
    xlabel('Orientation'); ylabel('SF');

    %respfirstnew = respfirst./repmat(sum(respsecond,2),[1, length(sfvec)]);
    respfirstnew = (respfirst.^2)./(1000+(repmat(sum(respsecond,2),[1, length(sfvec)]).^2));

    totalresponses(ii) = sum(respfirstnew(:));
end

%% Instantiate the cost-computing function
predFn = getMultibandSocPredFn(Amat, Bmat);
costFn = @(params)(sqrt(sum((targetVec - predFn(params)).^2)));

% TODO idea: use two output arguments, cost AND prediction

%% Use the cost-computing function
startparams = [0.1, 20, 2];
startcost = costFn(startparams)

% TODO make the same plots as before
% TODO make sure the shape is sensible; don't spend too much time

%% TODO RESTART HERE
finalparams = lsqcurvefit(predFn,startparams,[],targetVec); % TODO what goes in here

finalpred = myfn(params,gaborData);