function [totalresponse, outfirst, outsecond] = catherine_secondordercontrast(stimulus, doplot)

if ~exist('doplot', 'var')
    doplot = false;
end

if doplot; figure; subplot(2,2,1); imshow(stimulus, []); colormap('gray'); freezeColors; title('Stimulus'); end;

% Bank of Gabors
N = 8;
thetavec = 180 * (0:N-1)/N;
sfvec = [1.2.^(-5:3)]*0.5;

outfirst = NaN(501,501,N, length(sfvec));
for sfind = 1:length(sfvec)
    sf = sfvec(sfind);
    sig = (2*pi)/sf;
    
    x = -round(sig*3):1:round(sig*3); % construct extra-big so rotating isn't a problem
    y = -round(sig*3):1:round(sig*3);
    [X,Y] = meshgrid(x,y);
    
    wave_c = cos(sf*X);
    wave_s = sin(sf*X);
    

    Gauss = exp(-(X.^2 + Y.^2)/2/sig^2)/2/pi/sig^2;
    
    Gabor_c = Gauss .* wave_c;
    Gabor_s = Gauss .* wave_s;
    for thetaind = 1:length(thetavec)
        theta = thetavec(thetaind);
        newGabor_c_large = imrotate(Gabor_c, theta);
        newGabor_s_large = imrotate(Gabor_s, theta);
        
        % Crop to smaller after rotation
        largemid = ceil((size(newGabor_c_large,1)+1)/2);
        newGabor_c = newGabor_c_large(round(largemid-sig*2):round(largemid+sig*2), round(largemid-sig*2):round(largemid+sig*2));
        newGabor_s = newGabor_s_large(round(largemid-sig*2):round(largemid+sig*2), round(largemid-sig*2):round(largemid+sig*2));
        
        out_stim1 = sqrt(conv2(stimulus,newGabor_c,'same').^2 +conv2(stimulus,newGabor_s,'same').^2);
        mid = ceil(size(out_stim1,1)/2);
        range = mid-250 : mid+250;
        outfirst(:,:,thetaind, sfind) = out_stim1(range, range);
    end
end

respfirst = squeeze(sum(sum(outfirst,2),1));

if doplot; subplot(2,2,2); imagesc(respfirst'); axis xy; title('Filtered response, summed across space, varying by ori and SF'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF'); end;

popresp = squeeze(sum(sum(outfirst,4),3));
%popresp = popresp - mean(popresp(:)); % NEW STEP
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
        out_stim1 = sqrt(conv2(popresp,newGabor_c,'valid').^2 +conv2(popresp,newGabor_s,'valid').^2);
        mid = ceil(size(out_stim1,1)/2);
        range = mid-200 : mid+200;
        outsecond(:,:,thetaind, sfind) = out_stim1(range, range);
        
    end
end

respsecond = squeeze(sum(sum(outsecond,2),1));

if doplot; subplot(2,2,4); imagesc(respsecond'); axis xy; title('SECOND-order response, summed across space, varying by ori and SF'); colormap('parula'); freezeColors; xlabel('Orientation'); ylabel('SF'); end;

%respfirstnew = respfirst./repmat(sum(respsecond,2),[1, length(sfvec)]);
respfirstnew = (respfirst.^2)./(1000+(repmat(sum(respsecond,2),[1, length(sfvec)]).^2));

totalresponse = sum(respfirstnew(:));