function bool=strInCellArray(str, cellArray)
% STR IN CELL ARRAY - return true if the given str is an element
% of the given cell array
    bool = any(cellfun(@(cell) (strcmp(str, cell)), cellArray));
    