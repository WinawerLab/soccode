function xlabels = addXlabels(xlabels, rotate)
%ADD X LABELS - Generate X-axis labels
%
%   Adds labels to the x axis, based on the names of the categories as
%   stored in stimuliNames.mat. For example, categories 70:131 are curvy
%   pattern stimuli, at varying positions in space, so are named
%   "pattern_space". The x label at 70 is set to "pattern\_space" and
%   71:131 are left blank to avoid overcrowding. A vertical line is drawn
%   to the left of label 70. Then at 132, a new line and label are
%   established. This helps to visually break up a plot into conceptual
%   categories.
%
%   This function does not create a plot, but modifies an existing plot.
%
%       xlabels - A cell array of labels
%       rotate - (optional) if 1, rotate labels 90 degrees, else don't
    
    if ~exist('rotate', 'var')
        rotate = true;
    end
    
    curr = '';
    for i = 1:length(xlabels)
        if ~strcmp(xlabels{i}, curr)
            curr = xlabels{i};  
            plot([i-0.5, i-0.5], get(gca, 'YLim'), 'r') % make a vertical line
        else
            xlabels{i} = '';
        end
    end
    xlabels = strrep(xlabels, '_', '\_');
    set(gca,'XTick', 1:length(xlabels), 'XTickLabel', xlabels);
    if rotate
        xticklabel_rotate([], 90);
    end
    xlabel('Stimulus category');
end

