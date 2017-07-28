a0=load('/Volumes/server/Projects/SOC/data/preprocessing/2015-03-11/divnormbands_r1_s0pt5_a0_e16.mat');
a1=load('/Volumes/server/Projects/SOC/data/preprocessing/2015-03-11/divnormbands_r1_s0pt5_a0pt5_e16.mat');

a0.imStack = flatToStack(a0.preprocess.contrast,9);
a1.imStack = flatToStack(a1.preprocess.contrast,9);
a0.imStack = a0.imStack / mean(a0.imStack(:));
a1.imStack = a1.imStack / mean(a1.imStack(:));

[numrows, numcols, numcats, numexemplars] = size(a0.imStack);

% mask out edges
[x, y] = meshgrid(-44.5:44.5);
R = sqrt(x.^2 + y.^2);
Mask = R>35;

tmp = stackToFlat(a0.imStack);
tmp(Mask,:) = NaN;
a0.imStack = flatToStack(tmp, 9);

tmp = stackToFlat(a1.imStack);
tmp(Mask,:) = NaN;
a1.imStack = flatToStack(tmp, 9);

% %%
% figure(1); set(gcf, 'Color', 'w'), colormap gray, 
% for ii = [106:110 111 112  113 16 114] % [16 70:155] 
%     subplot(1,3,1), 
%     imagesc(a0.imStack(:,:,ii,1), [0 1]); axis image off, 
%     title(sprintf('A=0, stim %d', ii), 'Color', 'r', 'FontSize', 20);
%     
%     subplot(1,3,2), 
%     imagesc(a1.imStack(:,:,ii,1), [0 1]); axis image off; 
%     title(sprintf('A=1, stim %d', ii), 'Color', 'k', 'FontSize', 20);
% 
%     subplot(1,3,3)
%     plot(1:90, a0.imStack(45,:,ii,1), 'r', 1:90, a1.imStack(45,:,ii,1), 'k', 'LineWidth', 4)
%     axis([0 90 0 1]);
%     
%     waitforbuttonpress; 
% end

%%
gratings = 106:110;
patterns = [111 112  113 16 114] ;

for a = 0:1
    figure(a+1); set(gcf, 'Color', 'w'), colormap gray,
    if a == 0, data = a0; else data = a1; end
    
    for ii = 1:5
        subplot(2,5,ii),
        thisim = data.imStack(:,:,gratings(ii),1);
        thisim(Mask)=NaN;
        imagesc(data.imStack(:,:,gratings(ii),1), [0 1]); axis image off,
        title(sprintf('Sum %5.2f\tVar %5.3f', nanmean(thisim(:)), nanvar(thisim(:))), ...
            'Color', 'k', 'FontSize', 20);
        
        subplot(2,5,ii+5),
        thisim = data.imStack(:,:,patterns(ii),1);
        thisim(Mask)=NaN;
        imagesc(thisim, [0 1]); axis image off;
        title(sprintf('Sum %5.2f\tVar %5.3f', nanmean(thisim(:)), nanvar(thisim(:))),...
            'Color', 'k', 'FontSize', 20);
        
    end
end

%% means, variance

a0.mns = reshape(nanmean(stackToFlat(a0.imStack),1), numexemplars, numcats);
a1.mns = reshape(nanmean(stackToFlat(a1.imStack),1), numexemplars, numcats);

a0.var = reshape(nanvar(stackToFlat(a0.imStack),[], 1), numexemplars, numcats);
a1.var = reshape(nanvar(stackToFlat(a1.imStack),[], 1), numexemplars, numcats);

figure(101),clf, 

subplot(2,2,1)
bar(1:5, median(a0.mns(:,gratings),1), 'r'), hold on
bar(7:11, median(a0.mns(:,patterns),1)', 'b')
title('A = 0, mean in contrast images');

subplot(2,2,3)
bar(1:5, median(a1.mns(:,gratings),1), 'r'), hold on
bar(7:11, median(a1.mns(:,patterns),1)', 'b')
title('A = 1, mean in contrast images');

subplot(2,2,2)
bar(1:5, median(a0.var(:,gratings),1), 'r'), hold on
bar(7:11, median(a0.var(:,patterns),1)', 'b')
title('A = 0, variance in contrast images');

subplot(2,2,4)
bar(1:5, median(a1.var(:,gratings),1), 'r'), hold on
bar(7:11, median(a1.var(:,patterns),1)', 'b')
title('A = 1, variance in contrast images');


%% means, variance

figure(102),clf, 

subplot(1,2,1)
bar(1:5, [median(a0.mns(:,gratings),1); median(a1.mns(:,gratings),1)]', 'r'), hold on
bar(7:11,[median(a0.mns(:,patterns),1); median(a1.mns(:,patterns),1)]', 'b')
title('mean in contrast images');

subplot(1,2,2)
bar(1:5, [median(a0.var(:,gratings),1); median(a1.var(:,gratings),1)]', 'r'), hold on
bar(7:11,[median(a0.var(:,patterns),1); median(a1.var(:,patterns),1)]', 'b')
title('variance in contrast images');
