function [imToUse, imName, imNums] = loadOneDivnormIm(inputdir, r, s, a, e)
    imName = ['divnormbands_r', strrep(num2str(r), '.', 'pt'), ...
                          '_s', strrep(num2str(s), '.', 'pt'), ...
                          '_a', strrep(num2str(a), '.', 'pt'), ...
                          '_e', strrep(num2str(e), '.', 'pt')];
    load(fullfile(rootpath, inputdir, imName));

    imStack = flatToStack(preprocess.contrast, 9);
    imPxv = stackToPxv(imStack);
    imToUse = permute(imPxv, [2 1 3]);
    
    imNums = preprocess.imNums;
end