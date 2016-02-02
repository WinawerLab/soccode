function plotWithColors(data, plotOrder, plotNames, catColors)
% PLOT WITH COLORS - Given data, a reordering, a set of un-reordered names,
% and a set of *re*ordered colors, make a bar plot

    for ii = 1:numel(plotOrder)
      h = bar(ii, data(plotOrder(ii)), 1);
      %h = bar(ii, data(ii), 1);
      if ii == 1, hold on, end
      set(h, 'FaceColor', catColors(ii, :)) 
    end

    addXlabels(plotNames,1);
end

%% TEST:
%data = [1:5, 11:15, 21:25];
%[plotOrder, plotNames, catColors] = getTestPlotInfo();

%figure; title('Regular bar'); bar(data(plotOrder));
%figure; title('With coloration'); plotWithColors(data, plotOrder, plotNames, catColors);
%figure; title('WRONG'); plotWithColors(data(plotOrder), plotOrder, plotNames, catColors); % WRONG