function outfirst = tempGabor(stimulus)
    % Bank of Gabors
    x = -10:1:10;
    y = -10:1:10;
    [X,Y] = meshgrid(x,y);
    sig4 = 5;
    Gauss = exp(-(X.^2 + Y.^2)/2/sig4^2)/2/pi/sig4^2;

    Nor = 8;
    thetavec = 180 * (0:Nor-1)/Nor;
    sfvec = 1.2.^(-3:2)*0.5;

    outfirst = NaN(501,501,Nor, length(sfvec));
    for sfind = 1:length(sfvec)
        sf = sfvec(sfind);
        wave_c = cos(sf*X);
        wave_s = sin(sf*X);

        Gabor_c = Gauss .* wave_c;
        Gabor_s = Gauss .* wave_s;
        for thetaind = 1:length(thetavec)
            theta = thetavec(thetaind);
            newGabor_c = imrotate(Gabor_c, theta);
            newGabor_s = imrotate(Gabor_s, theta);
            out_stim1 = conv2(stimulus,newGabor_c,'valid').^2 +conv2(stimulus,newGabor_s,'valid').^2  ;
            mid = ceil(size(out_stim1,1)/2);
            range = mid-250 : mid+250;
            outfirst(:,:,thetaind, sfind) = out_stim1(range, range);
        end
    end
end