function totalresponse = catherine_endsuppression(stimulus, doplot)

if ~exist('doplot', 'var')
    doplot = false;
end

% Bank of Gabors
x = -10:1:10;
y = -10:1:10;
[X,Y] = meshgrid(x,y);
sig4 = 5;
Gauss = exp(-(X.^2 + Y.^2)/2/sig4^2)/2/pi/sig4^2;

Nor = 8;
thetavec = 180 * (0:Nor-1)/Nor;
sfspan = 1.2.^(-3:3);
Nsf = length(sfspan);
sfvec = sfspan*0.5;

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
respfirst = squeeze(sum(sum(outfirst,2),1));

if doplot; figure; imagesc(respfirst'); title('Filtered response, summed across space, varying by ori and SF'); xlabel('Orientation'); ylabel('SF'); end;
popresp = squeeze(sum(sum(outfirst,4),3));
% if doplot; figure; imshow(popresp,[]); title('Population response, summed across ori and SF'); end;

% %% Now compute end-dominated suppressive signal
% 
% %outsecond = zeros(size(outfirst));
% outsecond = zeros(size(outfirst,1), size(outfirst,2), size(outfirst,3)); % no ori
% for sfind = 1:Nsf
%     % Identify the dominant orientation, and use that to compute the
%     % suppression signal
%     [~, mainOr] = max(sum(sum(outfirst(:,:,:,sfind),1),2));
% 
%     % Build a convolutional filter that extracts energy in the "ends" of the RF
%     endsFilt = [Gauss, zeros(size(Gauss,1), ceil(size(Gauss,2)/2)), Gauss];
%     pad = (size(endsFilt,2) - size(endsFilt,1)) / 2;
%     endsFilt = [zeros(pad, size(endsFilt,2)); endsFilt; zeros(pad, size(endsFilt,2))];
% 
%     % Except rotate it as necessary to match the dominant orientation
%     endsFilt = imrotate(endsFilt, thetavec(mainOr));
% 
%     % Collect the energy to use for suppression
%     endsEnergySame = conv2(outfirst(:, :, mainOr, sfind), endsFilt, 'same');
% 
%     % Divide each orientation by the suppressive signal
%     % for thetaind = 1:Nor
%     %     outsecond(:,:,thetaind,sfind) = outfirst(:,:,thetaind,sfind) ./ (endsEnergySame + .01);
%     %     % the inclusion of +.01 above just prevents any 0's from blowing
%     %     % out of control
%     % end
% 
%     % Divide the total by the suppressive signal
%     % outsecond(:,:,sfind) = sum(outfirst(:,:,:,sfind), 3) ./ (endsEnergySame + .01);
%     % TODO, there are a few ways to do this, could try some others
% end

%%
%% Now compute end-dominated suppressive signal

outsecond = zeros(size(outfirst));
for sfind = 1:Nsf

    % Divide each orientation by the suppressive signal
    for thetaind = 1:Nor
        
        % Build a convolutional filter that extracts energy in the "ends" of the RF
        endsFilt = [Gauss, zeros(size(Gauss,1), ceil(size(Gauss,2)/2)), Gauss];
        pad = (size(endsFilt,2) - size(endsFilt,1)) / 2;
        endsFilt = [zeros(pad, size(endsFilt,2)); endsFilt; zeros(pad, size(endsFilt,2))];

        % Except rotate it as necessary to match the current orientation
        endsFilt = imrotate(endsFilt, thetavec(thetaind));

        % Collect the energy to use for suppression
        endsEnergySame = conv2(outfirst(:, :, thetaind, sfind), endsFilt, 'same');
    
        outsecond(:,:,thetaind,sfind) = outfirst(:,:,thetaind,sfind) ./ (endsEnergySame + .01);
        % the inclusion of +.01 above just prevents any 0's from blowing
        % out of control
    end
end

%%
if doplot
figure;
subplot(2, 2, 1); imshow(stimulus, []); title('Stimulus');
subplot(2, 2, 2); imshow(popresp, []); title('Unsuppressed');
subplot(2, 2, 3); imshow(sum(sum(outsecond,3),4), []); title('End suppression')
end

% Get a single number
totalresponse = sum(sum(outsecond(:)));

end
