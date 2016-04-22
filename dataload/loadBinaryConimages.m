function imStack = loadBinaryConimages(imNums)
% LOAD BINARY CONTRAST IMAGES: Load the pRF contrast images from png
% TODO THIS IS NOT DONE YET!
%
% Input:
%   imNums: which image categories to load, C categories
%
% Output:
%   imStack: a matrix of images, X * Y * C (no frames)

    assert(ischar(imFile), 'imFile must be a string');
    assert(isvector(imNums), 'imNums must be a vector');
    
    load(imFile, 'images');
    
    stimCell = images(imNums);
    imStack = cellToStack(stimCell);
    
end