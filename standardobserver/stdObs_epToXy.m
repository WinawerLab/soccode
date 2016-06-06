function xy = stdObs_epToXy(ep, imSz, pxPerDeg)
% STANDARD CORTICAL OBSERVER: [(eccentricity, polar angle), imSz, pxPerDeg] -> SOC parameters
%
% Convert eccentricity and polar angle (both in degrees) to x,y position in
% the contex of images of a certain pixel size at a certain scale
%
% Polar angle is measured in degrees away from the upper vertical meridian,
% with the left visual hemifield (right cortical hemisphere) counting
% negative from 0 at the top to -180, and the right hemifield positive.
% (i.e. the left horiz. meridian is -90, the right horiz. meridian is 90)
%
% x,y is output in matrix coordinates, such that (0,0) is the top left of
% the image
%
% In: voxs x 2 (ecc, polar angle), 1 (size), 1 (px per deg)
% Out: voxs x 2 (x, y)
    
    eccPx = ep(:,1) * pxPerDeg; % length of radial component in pixels
    angleRad = deg2rad(ep(:,2));
    xyCentered = [eccPx.*sin(angleRad) eccPx.*cos(angleRad)];
    
    mid = [(imSz+1)/2, (imSz+1)/2]; % TODO verify that this is right
    xy = xyCentered + repmat(mid, size(xyCentered,1), 1);
end

% TEST:
% [e,p] = meshgrid(linspace(0,20,10), linspace(0, 180, 21));
%    % 0 to 20 degrees eccentricity, right hemifield of polar angle
% epTest = [e(:), p(:)];
% imSz = 400; pxPerDeg = 10;
% xy = stdObs_epToXy(epTest, imSz, pxPerDeg);
% figure; plot(xy(:,1), xy(:,2), 'o'); axis ij; 
% xlim([0, imSz]), ylim([0, imSz])
%     % verify that this is right hemifield only