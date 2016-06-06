%% Conversion from sigma_n to sigma_p

%% Set up image size parameters
res = 400;                     % native resolution that we construct at
totalfov = 12;                 % total number of degrees for image
cpd = 3;
pxPerDeg = res/totalfov;
degPerPx = totalfov/res;

maskFrac = 11.5/12; 

radius = totalfov/2;           % radius of image in degrees
cpim = totalfov*cpd;           % cycles per image that we are aiming for
spacing = res./cpim;            % pixels to move from one cycle to the next

span = [-0.5, 0.5];             % dynamic range, to put into 'imshow' etc.

%% Choose which bandpass filter to use
bandwidth = 1;
fltsz = 31;
flt = mkBandpassCosine(res, cpim, bandwidth, fltsz, 0);

%% Parameters for spots spaced apart
dotSizeDeg = 0.25; 
dotSizePx = dotSizeDeg * pxPerDeg;

mid = ceil(([res,res]+1)/2);

dotPosDeg = -totalfov/2+dotSizeDeg/2:dotSizeDeg:totalfov/2-dotSizeDeg/2;
dotPosPx = dotPosDeg * pxPerDeg + res/2;

%% Create spots spaced apart
imStack = zeros(res, res, length(dotPosPx).^2);
whichIm = 1;
for x = 1:length(dotPosPx)
    disp(x)
    for y = 1:length(dotPosPx)
        imStack(:,:,whichIm) = mkDisc([res,res], dotSizePx/2, [dotPosPx(x), dotPosPx(y)], 0, [0.5, 0]);
        whichIm = whichIm + 1;
    end
end

%%
outputSz = 150; padSz = 30;
imStack = imresize(imStack, [outputSz, outputSz]);
imStack = padarray(imStack, [padSz/2, padSz/2, 0], 0, 'both');

imFlat = stackToFlat(imStack);
%imFilt = imfilter(im, flt, 'circular');

resizedPxPerDeg = outputSz/totalfov;
resizedDegPerPx = 1/resizedPxPerDeg;

%% Put through gabor pipeline
numor = 8; numph = 2;
gaborFlat = gaborenergy(imFlat, numor, numph, cpim);
gaborStack = flatToStack(gaborFlat, 1);

% Save out
outputdir = fullfile(rootpath, 'data', 'preprocessing', datestr(now,'yyyy-mm-dd'));
if ~exist(outputdir, 'dir')
    mkdir(outputdir);
end
gaborSpots = {};
gaborSpots.bandwidth = bandwidth;
gaborSpots.numor = numor;
gaborSpots.numph = numph;
gaborSpots.function = 'gaborenergy';
gaborSpots.inputImStack = imStack;
gaborSpots.gaborStack = gaborStack;
gaborSpots.generatingFile = 'createSpots.m';
gaborSpots.dateSaved = datestr(now);

outputFile = 'gaborSpots.mat';
save(fullfile(outputdir, outputFile), 'gaborSpots');

%% OR just start here and load them
loadDir = fullfile(rootpath, 'data', 'preprocessing', '2016-04-22');
load(fullfile(loadDir, 'gaborSpots.mat'), 'gaborSpots');
gaborFlat = stackToFlat(gaborSpots.gaborStack);

%% Choose parameters for sResults
R = 1; S = .5;
X = 45; Y = 45;
G = 1;
C = 0.93; % for example

dVals = [1, 1.5, 2, 2.5, 3];
nVals = linspace(0.1,2,20);

%% Compute sResults
% (NOTE: these are saved in the scripts directory and can be loaded)
sResults = zeros(length(dVals), length(nVals));
for dd = 1:length(dVals)
    disp(dd);
    for nn = 1:length(nVals)
        disp(nn);

        N = nVals(nn);  
        D = dVals(dd);
        params = [R, S, X, Y, D, G, N, C];

        predictions = socmodel_nogaborstep(params, gaborFlat);

        %
        predIm = reshape(predictions, length(dotPosPx), length(dotPosPx));
        %figure; imshow(predIm, []);

        %
        [xPts,yPts] = meshgrid(dotPosDeg);

        my2dGauss = fittype(@(b,s,X,Y)(b*exp(-(X.^2+Y.^2)/(2*s^2))), ...
                        'independent', {'X', 'Y'},...
                        'coefficients', {'b', 's'});
        opt = fitoptions(my2dGauss);
        opt.startpoint = [1, 1];
        fitobj = fit([xPts(:),yPts(:)], predIm(:), my2dGauss, opt);

        %figure, plot(fitobj), hold on,
        %plot3(X(:), Y(:), predIm(:), '.')

        sResults(dd, nn) = fitobj.s;
    end
end

%% Fit D/sqrt(n) model for each D
aFit = zeros(size(dVals));
bFit = zeros(size(dVals));

for dd = 1:length(dVals)
    nsFit = fit(dVals(dd)*sqrt(nVals).^(-1)', sResults(dd, :)', 'poly1');
    aFit(dd) = nsFit.p1;
    bFit(dd) = nsFit.p2;
end

%% Plot slices
figure; hold all;

for dd = 1:length(dVals)
    plot(sResults(dd, :), 'o-')
end

for dd = 1:length(dVals)
    %plot(aFit(dd)*dVals(dd)*sqrt(nVals).^(-1) + bFit(dd), '-')
    plot(0.16*dVals(dd)*sqrt(nVals).^(-1)  - 0.05*dVals(dd) + 0.23, '-')
end
legend([arrayfun(@(x)(['sigma\_s = ', num2str(x)]), dVals, 'UniformOutput', false), arrayfun(@(x)(['sigma\_s = ', num2str(x)]), dVals, 'UniformOutput', false)]);

xlabel('n parameter')
ylabel('measured pRF size (sigma\_p)')
title('Relationship between n and sigma\_p for varying sigma\_s');


%% Plot the other slices
figure; hold all;
for nn = 1:length(nVals)
    plot(sResults(:, nn), 'o-')
end
xlabel('parameter for pRF size (sigma\_s)')
ylabel('measured pRF size (sigma\_p)')
title('Relationship between sigma\_p and sigma\_s for varying n');
legend(arrayfun(@(x)(['n = ', num2str(x)]), nVals, 'UniformOutput', false))



