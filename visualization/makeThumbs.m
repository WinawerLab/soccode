% Make regular and high-contrast thumbnails
stimfilename = 'stimuli-2015-10-05';
load(fullfile(rootpath, 'data', 'stimuli', [stimfilename, '.mat']));

thumbsdir = fullfile(rootpath, 'data', 'stimuli', [stimfilename, '-thumbs']);
contrastdir = fullfile(rootpath, 'data', 'stimuli', [stimfilename, '-highcontrast']);

if ~exist(thumbsdir, 'dir')
    mkdir(thumbsdir);
end
if ~exist(contrastdir, 'dir')
    mkdir(contrastdir);
end

for cat = 1:size(stimuli.imStack, 3)
    % regular
    im = stimuli.imStack(:, :, cat, 1);
    im = double(im)/255;
    imwrite(im, fullfile(thumbsdir, [sprintf('%02d', cat), '.png']));
    
    % maximize contrast
    im = im-0.5;
    mx = max(abs(max(im(:))), abs(min(im(:))));
    im = im * (0.5/mx) + 0.5;
    
    imwrite(im, fullfile(contrastdir, [sprintf('%02d', cat), '.png']));
end
