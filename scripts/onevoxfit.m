%% Acquire a dataset
dataset = 'dataset03.mat';
load(fullfile(rootpath, ['data/input/fmri_datasets/', dataset]),'betamn','betase');
% betamn is 1323 voxels * 156 betamn values

%% Which images are in the dataset?
imNumsDataset = 70:225;
imNumsToUse = [70:173, 175:225]; % skip the category with only 7 frames

%% Load and resize images
imFile = fullfile(rootpath, 'data/input/stimuli.mat');   
imStack = loadImages(imFile, imNumsToUse);
imStack = resizeStack(imStack, 150, 30);
imPxv = stackToPxv(imStack);
imToUse = permute(imPxv, [2 1 3]);
    
%% Pick a demo voxel
voxNum = 33;
fh = setupBetaFig();
bar(betamn(voxNum, :));

%% Extract the relevant voxel and images
betamnIdx = arrayfun(@(x) find(imNumsDataset == x,1,'first'), imNumsToUse);
betamnToUse = betamn(voxNum, betamnIdx);

%% Guerilla model fitting
res = 90; % I think?
R = 1;
S = 0.5;
X = (1+res)/2;
Y = (1+res)/2;
D = res/4*sqrt(0.5);
G = 10;
Ns = [.05 .1 .3 .5];
Cs = [.4 .7 .9 .95];
seeds = [];
for p=1:length(Ns)
  for q=1:length(Cs)
    seeds = cat(1,seeds,[R S X Y D G Ns(p) Cs(q)]);
  end
end

bounds = [0 0 1-res+1 1-res+1 0   -Inf 0   0;
          Inf Inf 2*res-1 2*res-1 Inf  Inf Inf 1];
boundsFIX = bounds;
boundsFIX(1,5:6) = NaN; % fix the N and C

modelfun = wrapmodel(@socmodel_co);
% modelfun = wrapmodel(@degeneratemodel);
model = {{[]         boundsFIX   modelfun} ...
         {@(ss) ss   bounds      @(ss) modelfun}};
     % First row is seeds, bounds (NaN is "fixed"), modelfun
     % Second row reuses params without transformation.  The @(ss) ss
     % are no-ops.

optimoptions = {'Algorithm' 'levenberg-marquardt' 'Display' 'off'};
resampling = 0;
metric = @(a,b) calccod(a,b,[],[],0);

% construct the options struct
opt = struct( ...
  'stimulus',     imToUse, ...
  'data',         betamnToUse', ...
  'model',        {model}, ...
  'seed',         seeds, ...
  'optimoptions', {optimoptions}, ...
  'resampling',   resampling, ...
  'metric',       metric);

results = fitnonlinearmodel(opt);



