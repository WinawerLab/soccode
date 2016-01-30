function fh = setupBetaFig(fignum)
    if exist('fignum', 'var')
        fh = figure(fignum); clf;
    else
        fh = figure();
    end
%    setfigurepos([2000 500 1000 500]);
    hold on;
end