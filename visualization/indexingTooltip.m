function updateFcn = indexingTooltip(xname, yname)
%BETTER TOOLTIP - Get an "UpdateFcn" for a datacursormode object
%which also shows the index of the point

    function txt = myUpdateFcn(~, event_obj)
        pos = get(event_obj, 'Position');
        idx = get(event_obj, 'DataIndex');
        txt = {[xname, ': ', num2str(pos(1))], ...
               [yname, ': ', num2str(pos(2))], ...
               ['idx: ', num2str(idx)]};
    end

    updateFcn = @myUpdateFcn;

end

