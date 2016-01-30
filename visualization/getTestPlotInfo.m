function [plotOrder, plotNames, catColors] = getTestPlotInfo()
% GET TEST PLOT INFO - Get ordering, reordering, and colors, for
% testing the plotting code

% SETUP:
% Data is collected in three blocks of five ascending bars data.
% Data is displayed with the first block reversed, a pyramid inserted, a
% short second block, and no third block

% data = [1:5, 11:15, 21:25];

% Give category names to each image, according to the order they were collected
block1 = 5:-1:1;
pyramid = [3, 13, 8];
block2 = 6:10;
block3 = 11:15;

% Establish a canonical display order
plotOrder = [block1, pyramid, block2];
         
plotNames = [repmat({'block_one'}, length(block1), 1); ...
 repmat({'pyramid'}, length(pyramid), 1); ...
 repmat({'block_two'}, length(block2), 1)];

block1color = [80, 130, 220] ./ 255; % blue
block2color = [120, 98, 86] ./ 255; % brown
block3color = [0, 115, 130] ./ 255; % green

% colors, not in plot order; needs to be reordered:
catColors = [repmat(block1color, length(block1), 1); ...
 repmat(block2color, length(block2), 1); ...
 repmat(block3color, length(block3), 1)];