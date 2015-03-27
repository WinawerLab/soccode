function plotTwoBarSets(cat1Values, cat2Values, cat1Name, cat2Name)
% PLOT TWO BAR SETS - Plot category 1 bars in red, and category 2 in blue
%
% Inputs:
%   cat1Values - 

    figure; setfigurepos([10 100 600 200]);
    
    % Determine a reasonable scale for ylim
    ymin = 0; 
    ymax = max([cat1Values(:), cat2Values(:)]);
    
    % Plot
    cat1Size = size(cat1Values, 1);
    cat2Size = size(cat2Values, 1);
        
    % Bar plot: average for each stimulus; different color for each category
    bar(1:cat1Size, mean(cat1Values, 2), 'r');
    bar(cat1Size+1:cat1Size+cat2Size, mean(cat2Values, 2), 'b');

    % Error bars: standard error of the means, each stimulus
    errorbar2(1:cat1Size,mean(cat1Values, 2),sqrt(var(cat1Values, 1, 2))/sqrt(size(cat1Values, 2)),'v','g-','LineWidth',2);
    errorbar2(cat1Size+1:cat1Size+cat2Size,mean(cat2Values, 2),sqrt(var(cat2Values, 1, 2))/sqrt(size(cat2Values, 2)),'v','g-','LineWidth',2);
    % TODO QUESTION: I'm not using the betase's here at all; this is
    % just the standard error of the means, not taking into account the
    % variation of the numbers that were used to compute the means.
    % Should I do something different?

    % Set the bounds to the same thing across plots
    ylim([ymin*1.1 ymax*1.2]);
    xlim([0 cat1Size+cat2Size]);

    % Draw lines along the means of each category
    xlimits=get(gca,'xlim');
    plot(xlimits,[mean(cat1Values{roiIdx}(:)), mean(cat1Values{roiIdx}(:))], 'r');
    plot(xlimits,[mean(cat2Values{roiIdx}(:)), mean(cat2Values{roiIdx}(:))], 'b');
    title(rois{roiIdx});

    % Add y-axis label at the far left and legend at the far right
    if roiIdx == 1
        ylabel('Values');
        legend({cat1Name, cat2Name}, 'Location', 'North');
    end

end

