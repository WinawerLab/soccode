function memoized = get_gaborenergy_memoized()

    mappings = []; % the WORST hash table. THE WORST.
    
    function output = gaborenergy_memoized(imFlat, numor, numph)
        hash = num2str(sum(imFlat(:)), '%10.15f'); % this is pretty horrifying
        hash = strrep(hash, '-', 'm'); % yep, still horrifying
        hash = strrep(hash, '.', 'p');
        hash = ['h', hash];
        
        if isfield(mappings, hash)
            output = mappings.(hash);
        else
            output = gaborenergy(imFlat, numor, numph);
            mappings.(hash) = output;
        end
    end

    memoized = @gaborenergy_memoized;
end
