function imCell=loadManyDivnormIms(r, s, avals, evals)
    imCell = cell(length(avals), length(evals));
    for aIdx = 1:length(avals)
        for eIdx = 1:length(evals)
            imCell{aIdx, eIdx} = loadOneDivnormIm(r, s, avals(aIdx), evals(eIdx));
        end
    end
end