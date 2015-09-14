function idx=strInCellArray(str, cellArray)
% STR IN CELL ARRAY - return the first index if the given str is an element
% of the given cell array, zero otherwise
    locations = cellfun(@(cell) (strcmp(str, cell)), cellArray);
    if any(locations);
        idx = find(locations, 1, 'first');
    else
        idx = 0;
    end
    