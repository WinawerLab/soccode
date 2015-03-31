function updateFcn = subfigureTooltip(xname, yname, sz, indexinto, figmaker, fhandle)
%SUBFIGURE TOOLTIP - Updates a subfigure

    function txt = myUpdateFcn(~, event_obj)
        pos = get(event_obj, 'Position');
        idx = get(event_obj, 'DataIndex');
        sub = cell(length(sz), 1);
        [sub{:}] = ind2sub(sz, idx);
        idxValues = arrayfun(@(ii)(indexinto{ii}(sub{ii})), 1:length(sub));
        txt = {[xname, ': ', num2str(pos(1))], ...
               [yname, ': ', num2str(pos(2))], ...
               ['idx: ', num2str(idxValues)]};
        clf(fhandle);  
        figmaker(sub, fhandle);
    end

    updateFcn = @myUpdateFcn;

end

