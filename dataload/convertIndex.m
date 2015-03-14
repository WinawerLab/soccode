function indexes = convertIndex(allNums, numsToUse)
%CONVERTINDEXING - Find the indexes of "numsToUse" in the list "allNums"
%
%   allNums - a vector of numbers to index into, such as imNums (70, 71, ... 225)
%   numsToUse - a vector of desired numbers, such as imNums 224 and 225.
%
%   indexes - an output vector of the indices of "numsToUse" in "allNums",
%       such as indices 155 and 156 in this example.
%
%   Example: convertIndex([4 5 6 7], [5 6]) --> [2 3]
%            convertIndex([4 5 6 7], [6 5]) --> [3 2]

    indexes = arrayfun(@(x) find(allNums == x,1,'first'), numsToUse);
end

