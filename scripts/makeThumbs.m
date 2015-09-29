% make high-contrast thumbnails
load(fullfile(rootpath, 'data', 'stimuli', 'stimuli-2015-06-19.mat'));
for cat = 1:size(stimuli.imStack, 3)
    im = stimuli.imStack(:, :, cat, 1);
    
    % maximize contrast
    im = double(im)-127;
    mx = max(abs(max(im(:))), abs(min(im(:))));
    im = im * (128/mx);
    im = uint8(round(im + 127));
    
    imwrite(im, fullfile(rootpath, 'data', 'stimuli', 'stimuli-2015-06-highcontrast', [sprintf('%02d', cat), '.png']));
end