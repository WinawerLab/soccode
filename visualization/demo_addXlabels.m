% Demonstration for addXlabels.m

% In my work, I show images to humans and gather fMRI data.
% For a given voxel, the data I collect is one regression weight per voxel
% per type of stimulus I showed. In a dataset with several dozen
% trial types, where the trial types come from related categories (like
% five types of grating, five types of plaid, etc.), labeling the x axis of
% the bar graph can be annoying. Here's how I fixed that.

% Simulated numerical data from fifteen trial types:
data = randn(1, 15) + 0.5;

% Category names we collected data from, for example several different types
% of grating, several types of plaid, etc.
categories = {'grating', 'grating', 'grating', ...
    'plaid', 'plaid', 'plaid',...
    'noise', 'noise', 'noise', 'noise', 'noise', ...
    'circle', 'circle', 'circle', 'circle'};

%% Plot all the data, without the helper function
% this looks horrible, and it's hard to see the category boundaries
figure; hold on;
bar(data);
set(gca,'XTick', 1:length(categories), 'XTickLabel', categories);

%% Plot all the data, with the addXlabels function
% This is pretty, yay!
figure; hold on;
bar(data);
addXlabels(1:length(categories), categories);

%% Drop the first 'plaid' condition, ignore all the 'noise' conditions,
% and it still draws the lines correctly!
subset = [1:3, 5:6, 12:15];
figure; hold on;
bar(data(subset));
addXlabels(subset, categories);