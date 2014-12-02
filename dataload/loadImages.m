function imStack = loadImages(imFile, imNums)
% LOAD IMAGES: Load unprocessed stimulus images.
%
% Input:
%   imFile: path to the stimuli.mat file from the SOC project,
%           e.g. fullfile(rootpath, 'data/input/stimuli.mat');
%   imNums: which image categories to load, C categories. These images must
%           be stimulus categories which have the same raw image size and
%           same number of frames.
%
% Output:
%   imStack: a matrix of images, X * Y * C * F

    assert(ischar(imFile), 'imFile must be a string');
    assert(isvector(imNums), 'imNums must be a vector');
    
    load(imFile, 'images');
    
    stimCell = images(imNums);
    imStack = cellToStack(stimCell);
    
end