function memoized = get_divnormpointwise_memoized()

    mappings = [];
    
    function output = divnormpointwise_memoized(imFlat, r, s)
        imHash = num2str(sum(imFlat(:)), '%10.20f');
        rHash = num2str(r, '%10.20f');
        sHash = num2str(s, '%10.20f');
        hash = ['i', imHash, 'r', rHash, 's', sHash];
        hash = strrep(hash, '-', 'm');
        hash = strrep(hash, '.', 'p');
        hash = ['h', hash];
        
        if isfield(mappings, hash)
            output = mappings.(hash);
        else
            output = divnormpointwise(imFlat, r, s);
            mappings.(hash) = output;
        end
    end

    memoized = @divnormpointwise_memoized;
end
