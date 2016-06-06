%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing: Generate and save bands *at multiple SFs*
% co 2016-03-30
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the images
imFile = fullfile('data', 'stimuli', 'stimuli-2015-10-05.mat');
load(fullfile(rootpath, imFile), 'stimuli');

imStack = double(stimuli.imStack);
imStack = imStack/255 - 0.5;

numClasses = size(imStack,3);

% outputSz = 600;
% imStack = resizeStack(imStack, outputSz, 0); % was this the problem?
%cpd = 3;
%imfov = 12;
%cpim = cpd * imfov * ((outputSz+padSz)/outputSz);

%% Create output dir
outputdir = fullfile(rootpath, 'data', 'preprocessing', datestr(now,'yyyy-mm-dd'));
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end

%% Create a bank of Gabors
nor = 8;
thetavec = 180 * (0:nor-1)/nor;

sfvec = [1.2.^(-9:2:3)]*0.5;
%sfvec = [1.2.^(-5:3)]*0.5;
%sfvec = [1.2.^(-3:5)]*0.5; % higher frequencies
nsf = length(sfvec);

gabors_c = cell(nsf, nor);
gabors_s = cell(nsf, nor);

for sfind = 1:nsf
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
    for thetaind = 1:nor
        theta = thetavec(thetaind);
        newGabor_c_large = imrotate(Gabor_c, theta);
        newGabor_s_large = imrotate(Gabor_s, theta);
        
        % Crop to smaller after rotation
        largemid = ceil((size(newGabor_c_large,1)+1)/2);
        newGabor_c = newGabor_c_large(round(largemid-sig*2):round(largemid+sig*2), round(largemid-sig*2):round(largemid+sig*2));
        newGabor_s = newGabor_s_large(round(largemid-sig*2):round(largemid+sig*2), round(largemid-sig*2):round(largemid+sig*2));
        
        gabors_c{sfind, thetaind} = newGabor_c;
        gabors_s{sfind, thetaind} = newGabor_s;
    end
end

%% FIRST PASS

%outfirst = NaN(201,201,nor,nsf,numClasses); % use this if shrunk before
%running

%for cc = [8, 9, 10, 29, 30, 31, 32, 33, 34, 35, 36];
%for cc = 33
%for cc = 29
for cc = 1:numClasses
    outfirst = NaN(501,501,nor,nsf);

    disp(['Starting class ', num2str(cc), ' out of ', num2str(numClasses)]);
    
    stimulus = imStack(:,:,cc,1);
    tic
    for sfind = 1:nsf
        for thetaind = 1:nor
            out_stim1 = sqrt(conv2(stimulus,gabors_c{sfind,thetaind},'same').^2 +conv2(stimulus,gabors_s{sfind,thetaind},'same').^2);
            mid = ceil(size(out_stim1,1)/2);
            range = mid-250 : mid+250;
            outfirst(:,:,thetaind, sfind) = out_stim1(range, range);
        end
    end
    toc
    
    save(fullfile(outputdir,['A_outfirst_', num2str(cc), '.mat']), 'outfirst');
    clear outfirst;
end

%% SECOND PASS
%for cc = 29
%for cc = 33
%for cc = [8, 9, 10, 29, 30, 31, 32, 33, 34, 35, 36];
for cc = 1:numClasses
    disp(['Starting class ', num2str(cc), ' out of ', num2str(numClasses)]);
    
    load(fullfile(outputdir,['A_outfirst_', num2str(cc), '.mat']), 'outfirst');
    outsecond = NaN(301,301,nor,nsf); 
    % popresp = squeeze(sum(sum(outfirst(:,:,:,:),4),3)); GOTCHA! BUG FOUND!!
    popresp = squeeze(sum(sum(outfirst,4),3));
    
    tic
    for sfind = 1:nsf
        for thetaind = 1:nor
            out_stim1 = sqrt(conv2(popresp,gabors_c{sfind,thetaind},'same').^2 +conv2(popresp,gabors_s{sfind,thetaind},'same').^2);
            mid = ceil(size(out_stim1,1)/2);
            range = mid-150 : mid+150;
            outsecond(:,:,thetaind, sfind) = out_stim1(range, range);
        end
    end
    toc
   
    save(fullfile(outputdir,['B_outsecond_', num2str(cc), '.mat']), 'outsecond');
    clear outsecond
end
