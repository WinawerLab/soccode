%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visualization: Generate images of different divisive normalization params
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function divnormImages(r, s, a, e)
    rstr = strrep(num2str(r), '.', 'pt');
    sstr = strrep(num2str(s), '.', 'pt');
    astr = strrep(num2str(a), '.', 'pt');
    estr = strrep(num2str(e), '.', 'pt');

    file = ['divnormbands_r', rstr, '_s', sstr, '_a', astr, '_e', estr];
    load(fullfile(rootpath, '/data/preprocessing/2015-03-11/', file));

    nFrames = 9;
    bands = flatToStack(preprocess.bands, nFrames);

    %% Grab subset of images
    gratingNums = 176:180; gratingIdx = 1:5;
    patternNums = 181:184; patternIdx = 6:9;

    gratingIms = bands(:, :, convertIndex(preprocess.imNums, gratingNums), 1, :);
    patternIms = bands(:, :, convertIndex(preprocess.imNums, patternNums), 1, :);
    allIms = cat(3, gratingIms, patternIms);

    %% Create a mask, to prepare to grab the mean and variance within this region
    mask = makeCircleMask(34, 90);

    %% Plot images
    figure;

    numIms = size(allIms, 3); % number of image types
    numBands = size(allIms, 5); % number of bands

    for imIdx = 1:numIms
        for bandIdx = 1:numBands
            subplot(numIms, numBands, (imIdx-1)*numBands + bandIdx);

            im = allIms(:, :, imIdx, :, bandIdx);
            imshow(im, [0 1]);

            pixels = im(mask);
            title([num2str(mean(pixels(:))), 10, num2str(var(pixels(:)))]);
        end
    end
    set(gca,'LooseInset',get(gca,'TightInset'))
    setfigurepos(2);
end
