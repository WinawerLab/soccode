% visualizesamplestimuli
%
% Load and view a subset of images from soc experiments
imFile = fullfile(rootpath, 'data', 'input', 'stimuli.mat');
imNums = [70:173 175:225];
imStack = loadImages(imFile, imNums);

%
figure; 
for ii = 1:length(imNums)
    imagesc(imStack(:,:,ii,1), [0 255]); 
    colormap gray; 
    axis image; off
    title(ii); 
    pause(.1); 
end