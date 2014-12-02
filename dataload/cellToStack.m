function imStack = cellToStack(stimCell)
% CELL TO STACK: Turn an image cell array (like stimulus.mat) into
% a matrix stack of images. Only works if all the images are the same size
% and same number of frames.
%
% Inputs:
%   stimCell - a cell array of C categories, each containing a matrix of
%       images shaped X pixels * Y pixels * F frames 
%
% Outputs:
%   stack - a matrix X * Y * C * F of the same data

    assert(iscell(stimCell), 'Stimuli must be cell array')
    
    C = length(stimCell);
    
    imStack = cell2mat(stimCell); % X * (Y*C) * F
    
    [X, YC, F] = size(imStack);
    imStack = reshape(imStack, [X, YC/C, C, F]);
end