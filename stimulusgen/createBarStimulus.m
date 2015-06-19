function [output, lines, contrastBoost] = createBarStimulus(sz, bpfilter, spacing, jumpvals, nframes, angle)
% CREATE BAR STIMULUS - sparse gratings
%   sz - the desired image size
%   bpfilter - the convolutional bandpass filter to use, in space domain
%   jumpvals - which stripe interleavings to use. Must start with 1.
%   spacing - the computed pixel spacing between cycles (need not be an
%            integer)
%   nframes - number of exemplars per class
%   angle - from zero to 2 pi
%
%   output - a stack of X*Y*category*frame
%   contrastBoost - the necessary contrast boost factor to bring the dense
%           grating to a maximum absolute pixel value of <=0.5

    assert(angle <= 2*pi, 'Define angle in radians')
    
    output = zeros(sz, sz, length(jumpvals), nframes);
    lines = zeros(sz, sz, length(jumpvals), nframes);
    
    buffer = ceil((sz+1)/2);
    consz = sz + buffer*2; % construct lines at a larger size so rotation works
    for ii = 1:length(jumpvals)
        jump = jumpvals(ii);
        lineIm = zeros(consz, consz, nframes);
        barstarts = round(linspacecircular(1, 1+spacing*jump, nframes));

        for frame = 1:length(barstarts)          
          barlocs = barstarts(frame):(spacing*jump):consz;
          lineIm(round(barlocs), :, frame) = -0.5;  % black bars
        end
        
        lineIm = imrotate(lineIm, rad2deg(angle), 'bicubic', 'crop');
        lineIm = lineIm(buffer:buffer+sz-1, buffer:buffer+sz-1, :);
        
        filtered = imfilter(lineIm, bpfilter); % nothing specified -> zero-padded boundaries        
        
        contrastBoost = .5 / max(abs(flatten(filtered(round(sz/4):round(3*sz/4), :)))); % separately for each
            % I expect 0.8526 for the dense ones
            % and 1.3232 for the sparser ones
        output(:, :, ii, :) = contrastBoost * filtered;
        lines(:, :, ii, :) = lineIm;
    end
end