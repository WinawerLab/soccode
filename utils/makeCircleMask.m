function circ = makeCircleMask(radius, imsize)
% MAKE CIRCLE MASK - Returns an image which contains a circular region of
% 1's in a field of 0's.
%
%   radius - an scalar value for the radius of the circls
%   imsize - an integer, or a pair of integers, for the whole image size
%
%   circ - an image, containing the circular mask of 1's, centered on the
%   middle

    if size(imsize) == 1
        imsize = [imsize, imsize];
    end
    
    midx = ceil(imsize(1)/2);
    midy = ceil(imsize(2)/2);
    
    [x, y] = meshgrid(1:imsize(1), 1:imsize(2));
    circ = (x-midx).^2 + (y-midy).^2 < radius^2;
end

