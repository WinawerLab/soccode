function resized = resizeStack(imStack, sz, padding)
%RESIZE STACK: Resize image, truncate values, and pad boundaries
%
% Inputs:
%   imStack - a stack of images, x * y * c * f, in [0, 255], square (x = y)
%   sz - the size to resize the central part to (square - one number)
%   padding - how much total padding to add (symmetrically - one
%       number). The total size will be sz+padding. Ideally should be an
%       even number, or else more padding will end up on the top and left.
%
% Outputs:
%   resized - images, after loading, resizing, truncating, shifting to [-0.5
%       0.5] and padding with zeros
    
    assert(ndims(imStack) < 5, 'MATLAB:assertion:failed', 'imStack cannot be more than 4D');
    assert(size(imStack, 1) == size(imStack, 2), 'MATLAB:assertion:failed', 'images must start square');
    
    ims = zeros(sz, sz, size(imStack, 3), size(imStack, 4));
    for f = 1:size(imStack, 4)
        im = single(imresize(imStack(:, :, :, f), [sz, sz], 'cubic'));
        im(im < 0) = 0;
        im(im > 254) = 254;
        im = im/254 - 0.5;
        ims(:, :, :, f) = im;
    end
    resized = placematrix(zeros(sz+padding, sz+padding, size(ims,3),size(ims,4),'single'),ims);
end