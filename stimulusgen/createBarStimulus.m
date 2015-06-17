function [output, contrastBoost] = createBarStimulus(sz, bpfilter, spacing, jumpvals, nframes)
% CREATE BAR STIMULUS
%   sz - the desired image size
%   bpfilter - the convolutional bandpass filter to use, in space domain
%   jumpvals - which stripe interleavings to use. Must start with 1.
%   spacing - the computed pixel spacing between cycles (need not be an
%            integer)
%   nFrames - number of exemplars per class
%   toplot - (optional) whether to visualize or not
%
%   output - a stack of X*Y*category*frame
%   contrastBoost - the necessary contrast boost factor to bring the dense
%           grating to a maximum absolute pixel value of <=0.5
    
    output = zeros(sz, sz, length(jumpvals), nframes);
    
    for ii = 1:length(jumpvals)
        jump = jumpvals(ii);
        im = zeros(sz, sz, nframes);
        barstarts = round(linspacecircular(1, 1+spacing*jump, nframes));

        for frame = 1:length(barstarts)
          barlocs = barstarts(frame):(spacing*jump):sz;
          im(round(barlocs), :, frame) = -0.5;  % black bars
        end
        
%        display(['Total black pixels: ', num2str(sum(

        im = imfilter(im, bpfilter, 'circular');

        contrastBoost = .5 / max(abs(flatten(im(round(sz/4):round(3*sz/4), :)))); % separately for each
        
        output(:, :, ii, :) = contrastBoost * im;
    end
end