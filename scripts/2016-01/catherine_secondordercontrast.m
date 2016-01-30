function totalresponse = catherine_secondordercontrast(stimulus, doplot)

if ~exist('doplot', 'var')
    doplot = false;
end

if doplot; figure; subplot(2,2,1); imshow(stimulus, []); colormap('gray'); freezeColors; title('Stimulus'); end;

% Bank of Gabors
x = -10:1:10;
y = -10:1:10;
[X,Y] = meshgrid(x,y);
sig4 = 5;
Gauss = exp(-(X.^2 + Y.^2)/2/sig4^2)/2/pi/sig4^2;

N = 8;
thetavec = 180 * (0:N-1)/N;
sfvec = 1.2.^(-3:2)*0.5;

outfirst = NaN(501,501,N, length(sfvec));
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
respfirst = squeeze(sum(sum(outfirst,2),1));

if doplot; subplot(2,2,2); imagesc(respfirst'); axis xy; title('Filtered response, summed across space, varying by ori and SF'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF'); end;
popresp = squeeze(sum(sum(outfirst,4),3));
if doplot; subplot(2,2,3); imshow(popresp,[]); colormap('gray'); freezeColors; title('Population response, summed across ori and SF'); end;

outsecond = NaN(401,401,N, length(sfvec));
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
        out_stim1 = conv2(popresp,newGabor_c,'valid').^2 +conv2(popresp,newGabor_s,'valid').^2  ;
        mid = ceil(size(out_stim1,1)/2);
        range = mid-200 : mid+200;
        outsecond(:,:,thetaind, sfind) = out_stim1(range, range);
        
    end
end

respsecond = squeeze(sum(sum(outsecond,2),1));

if doplot; subplot(2,2,4); imagesc(respsecond'); axis xy; title('SECOND-order response, summed across space, varying by ori and SF'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF'); end;

respfirstnew = respfirst./repmat(sum(respsecond,2),[1, length(sfvec)]);

totalresponse = sum(respfirstnew(:));