function memoized = get_divnormneighbors_memoized()

    mappings = [];
    
    function output = divnormneighbors_memoized(imFlat, r, s, t)
        imHash = num2str(sum(imFlat(:)), '%10.20f');
        rHash = num2str(r, '%10.20f');
        sHash = num2str(s, '%10.20f');
        tHash = num2str(t, '%10.20f');
        hash = ['i', imHash, 'r', rHash, 's', sHash, 't', tHash];
        hash = strrep(hash, '-', 'm');
        hash = strrep(hash, '.', 'p');
        hash = ['h', hash];
        
        if isfield(mappings, hash)
            display(['Memoized: ', hash]);
            output = mappings.(hash);
        else
            display(['Not memoized: ', hash]);
            output = divnormneighbors(imFlat, r, s, t);
            mappings.(hash) = output;
        end
    end

    memoized = @divnormneighbors_memoized;
end
