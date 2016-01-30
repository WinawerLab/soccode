clear all; close all;
stimdir = fullfile(rootpath, 'data', 'stimuli');
load(fullfile(stimdir, 'stimuli-2015-10-05.mat'));

%% Choose a stimulus
%stimulus = double(stimuli.imStack(:,:,8,1));
stimulus = double(stimuli.imStack(:,:,29,1)); %stimulus = imrotate(stimulus,90);

stimulus = (stimulus-min(stimulus(:)))/(max(stimulus(:))-min(stimulus(:))) - 0.5;

doplot = true;
if doplot; figure; imshow(stimulus, []); title('Stimulus'); end;

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

outsecond = NaN(501,501,Nor, length(sfvec));
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
        outsecond(:,:,thetaind, sfind) = out_stim1(range, range);
    end
end
respfirst = squeeze(sum(sum(outsecond,2),1));

if doplot; figure; imagesc(respfirst'); title('Filtered response, summed across space, varying by ori and SF'); xlabel('Orientation'); ylabel('SF'); end;
popresp1 = squeeze(sum(sum(outsecond,4),3));
if doplot; figure; imshow(popresp1,[]); title('Population response, summed across ori and SF'); end;

%% Ok, let's play with this
figure;
plotct = 1;
for ii = 1:Nsf
    for jj = 1:Nor
        subplot(Nor, Nsf, plotct); imshow(outsecond(:, :, jj, ii), [0, max(outsecond(:))]);
        plotct = plotct + 1;
    end
end

%% For a single given band, what do I want to measure?
% Assuming we're talking just about the vertical filter

% TODO: allow this to rotate to match the dominant energy
sidesFilt = [Gauss, zeros(size(Gauss,1), ceil(size(Gauss,2)/2)), Gauss];
endsFilt = [Gauss; zeros(ceil(size(Gauss,1)/2), size(Gauss,2)); Gauss];
%endsFilt = [Gauss, Gauss];
%sidesFilt = [Gauss; Gauss];

sameOr = 1; % horizontal
orthOr = 5; % vertical
mainSF = 5; 

endsEnergySame = conv2(outsecond(:, :, sameOr, mainSF), endsFilt, 'same');
endsEnergyOrth = conv2(outsecond(:, :, orthOr, mainSF), endsFilt, 'same');
sidesEnergySame = conv2(outsecond(:, :, sameOr, mainSF), sidesFilt, 'same');
sidesEnergyOrth = conv2(outsecond(:, :, orthOr, mainSF), sidesFilt, 'same');

figure;
subplot(2, 2, 1); imshow(endsEnergySame, [0 0.15]); title(['Ends, same ori, ', num2str(sum(endsEnergySame(:)))]);
subplot(2, 2, 2); imshow(endsEnergyOrth, [0 0.15]); title(['Ends, orth ori, ', num2str(sum(endsEnergyOrth(:)))]);
subplot(2, 2, 3); imshow(sidesEnergySame, [0 0.15]); title(['Sides, same ori, ', num2str(sum(sidesEnergySame(:)))]);
subplot(2, 2, 4); imshow(sidesEnergyOrth, [0 0.15]); title(['Sides, orth ori, ', num2str(sum(sidesEnergyOrth(:)))]);

%% what filter was that
plusme = zeros(size(stimulus));
plusme(50:(49+size(endsFilt, 1)), 50:(49+size(endsFilt,2))) = endsFilt*100;
figure; imshow(stimulus + plusme, []);

%% Divide the activation by the total suppression

w = 0.5; % how much to 

outsecond = NaN(501,501,Nor,Nsf);
for sfind = 1:Nsf
    [~, peakOr] = max(respfirst(:, sfind));
    
    endsEnergy % TODO restart here stuck
    
    for thetaind = 1:Nor
        theta = thetavec(thetaind);
        newGabor_c = imrotate(Gabor_c, theta);
        newGabor_s = imrotate(Gabor_s, theta);
        out_stim1 = conv2(stimulus,newGabor_c,'valid').^2 +conv2(stimulus,newGabor_s,'valid').^2  ;
        mid = ceil(size(out_stim1,1)/2);
        range = mid-250 : mid+250;
        outsecond(:,:,thetaind, sfind) = out_stim1(range, range);
    end
end

respsecond = squeeze(sum(sum(outsecond,2),1));

if doplot; figure; imagesc(respsecond'); title('SUPPRESSED response, summed across space, varying by ori and SF'); xlabel('Orientation'); ylabel('SF'); end;

totalresponse = sum(respsecond(:));
