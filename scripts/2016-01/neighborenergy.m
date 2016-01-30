%function totalresponse = neighborenergy(stimulus, doplot)

stimdir = fullfile(rootpath, 'data', 'stimuli');
load(fullfile(stimdir, 'stimuli-2015-10-05.mat'));

stims = [8, 29];

for ss = 1:length(stims);
    stim = stims(ss);
    
    stimulus{ss} = double(stimuli.imStack(:,:,stim,1));
    stimulus{ss} = (stimulus{ss}-min(stimulus{ss}(:)))/(max(stimulus{ss}(:))-min(stimulus{ss}(:))) - 0.5;

    % figure; imshow(stimulus, []); colormap('gray'); freezeColors; title('Stimulus'); end;

    %% Compute gabor
    outfirst{ss} = tempGabor(stimulus{ss});

%     %% Ok now what to do with outfirst
%     relevantSF = 5;
%     figure;
%     for ii = 1:size(outfirst, 3);
%         subplot(2, 4, ii);
%         imshow(outfirst(:, :, ii, relevantSF), [min(outfirst(:)), max(outfirst(:))]);
%     end

    %% Focus on area around a peak
    sameOri = 1;
    relevantSF = 5;
    if stim == 8; center = [245, 263]; elseif stim == 29; center = [241, 237]; else assert(false); end;

    extent = 50;
    endsSameOri{ss} = zeros(1,extent); sidesSameOri{ss} = zeros(1,extent);%obliqueSameOri{ss} = zeros(1,extent);

    for ii = 1:extent;
        endsSameOri{ss}(ii) = (outfirst{ss}(center(1)+ii, center(2), sameOri, relevantSF)...
                        + outfirst{ss}(center(1)-ii, center(2), sameOri, relevantSF))/2;
        sidesSameOri{ss}(ii) = (outfirst{ss}(center(1), center(2)+ii, sameOri, relevantSF)...
                        + outfirst{ss}(center(1), center(2)-ii, sameOri, relevantSF))/2;            
%         obliqueSameOri{ss}(ii) = (outfirst{ss}(center(1)+ii, center(2)+ii, sameOri, relevantSF)...
%                         + outfirst{ss}(center(1)+ii, center(2)-ii, sameOri, relevantSF)...          
%                         + outfirst{ss}(center(1)-ii, center(2)+ii, sameOri, relevantSF)...
%                         + outfirst{ss}(center(1)-ii, center(2)-ii, sameOri, relevantSF))/4;
    end
end

%% Plots
figure;

tmp = outfirst{1}(:, :, sameOri, relevantSF);
tmp(245, 263) = 0;
subplot(2, 2, 1); imshow(tmp, []);
subplot(2, 2, 2); hold all; plot(endsSameOri{1}); plot(sidesSameOri{1}); %plot(obliqueSameOri{1});
legend('Ends', 'Sides'); %'Oblique');

tmp = outfirst{2}(:, :, sameOri, relevantSF);
tmp(241, 237) = 0;
subplot(2, 2, 3); imshow(tmp, []);
subplot(2, 2, 4); hold all; plot(endsSameOri{2}); plot(sidesSameOri{2}); %plot(obliqueSameOri{2});
legend('Ends', 'Sides'); % 'Oblique');
                                