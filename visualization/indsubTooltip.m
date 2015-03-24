function updateFcn = indsubTooltip(xname, yname, sz)
%IND2SUB TOOLTIP - Like an indexing tooltip, but the index is converted
% using ind2sub on the provided sz

    function txt = myUpdateFcn(~, event_obj)
        pos = get(event_obj, 'Position');
        idx = get(event_obj, 'DataIndex');
        sub = cell(length(sz), 1);
        [sub{:}] = ind2sub(sz, idx);
        txt = {[xname, ': ', num2str(pos(1))], ...
               [yname, ': ', num2str(pos(2))], ...
               ['idx: ', num2str([sub{:}])]};
    end

    updateFcn = @myUpdateFcn;

end

