inherits from prepareimages_monster.m

SPACE (38)
ORIENTATION (8)
GRATING (4)
PLAID (4)
CIRCULAR (4)
CONTRAST (10)
SPARSEBAR (5)
SPARSEZEBRA (5)
COHERENCEBAR (4)
COHERENCEZEBRA (4)

- don't randomize very much!
- 1 frame of each
- 800 x 800 x 86, uint8, [0,254]
- 500 ms ON, 500 ms OFF
- aim for 20 degrees stimulus size

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXECUTIVE SUMMARY

% 86 stimuli
% 800 px, 20¡, 40 px/¡, aim for 3 cpd, 60 cycles total. minimum 60*4 = 240 pixel analysis.
% 0.5¡Êouter edge ramp, 1 cyc/¡ in the ramp; 19¡Êvalid stimulus / 1¡Êramp
% for PRF stimuli, transition zone should be 1/6 deg (which corresponds to 3 cyc/deg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP

% define
finalres = 800;                % target resolution for the stimuli
res = 512;                     % native resolution that we construct at
totalfov = 20;                 % total number of degrees for FOV
rfov = totalfov/2;             % radius of FOV in degrees
cpd = 3;                       % target cycles per degree
cpfov = totalfov*cpd;          % cycles per FOV that we are aiming for
spacing = res/cpfov;           % pixels to move from one cycle to the next
bandwidth = 1.5;               % bandwidth in octaves for the target SF band
band = 1;                      % fraction of linear bandwidth to use for transition zone of target SF band
bandexpt = 5;                  % exponent to apply to the amplitude spectrum of target SF band for fitting purposes
frac = 19/totalfov;            % what fraction of radius for the circular mask to start at
numframes = 1;                 % how many images from each class (if applicable)
fltsz = -33;                   % filter pixel size
transzone = res/totalfov * 1/6;  % entire transition zone is this much in pixels
nb = 4;                        % number of cuts in between meridian and edge for main PRF stimuli
cpf = totalfov/2;              % cycles per field of view for standard zebra texture

%%%%%%%%%%%%%%%%% PREPARE BANDPASS FILTER AND CIRCULAR MASK

% make bandpass DOG filter (flt, fltamp)
delta = cpfov * (2^bandwidth - 1) / (2^bandwidth + 1);
fltA = constructcosinefilter(res,[cpfov-delta cpfov+delta],band*(2*delta));  % this is the amp spectrum to match
fltB = fouriertospace(fltA,fltsz,1);
[xx,yy] = meshgrid(1:res,1:res);
options = optimset('Display','iter','MaxFunEvals',Inf,'MaxIter',1000,'TolFun',1e-6,'TolX',1e-6);
[dogparams,d,d,exitflag,output] = lsqcurvefit(@(a,b) flatten(abs(fft2(evaldog2d([round(res/2) round(res/2) a(1) a(2) 1 a(3) 0],b)))).^bandexpt, ...
  [5 2 3],[flatten(xx); flatten(yy)],flatten(fltA).^bandexpt,[],[],options);  % find DOG that best matches fltA
assert(exitflag > 0);
fltF = abs(fft2(evaldog2d([round(res/2) round(res/2) dogparams(1) dogparams(2) 1 dogparams(3) 0],xx,yy)));  % get amp spectrum of DOG
flt = fouriertospace(fltF,fltsz,1);  % convert to spatial domain.  this is the final DOG filter!!!
fltamp = abs(fft2(placematrix(zeros(res,res),flt,[])));  % this is the amp of the final DOG filter!!!
  % dogparams is 1.95360480514469          1.00837160126556          6.70156505548397

% make masks (mask,mask2)
mask = makecircleimage(res,res/2*frac,[],[],res/2);  % white (1) circle on black (0)
viewimage(mask);

%%%%%%%%%%%%%%%%% CONSTRUCT STIMULI [MONSTER]

% initialize
images = {};
conimages = {};

%%%%%% PRF [contrast: max it]

% figure out the locations of the borders (spaceparams)
options = optimset('Display','iter','MaxFunEvals',Inf,'MaxIter',Inf,'TolFun',1e-10,'TolX',1e-10);
for slope=[1/3]
  spaceparams = lsqnonlin(@(x) spatialscaling(x,slope),rand(1,nb),zeros(1,nb),rfov*ones(1,nb),options);
  [d,ecc,width] = spatialscaling(spaceparams,slope);
  figure; hold on;
  plot(ecc,width,'ro-');
  plot([0 rfov],[0 rfov*slope],'g-');
  ax = axis; axis([0 rfov 0 rfov]);
  straightline([0 spaceparams rfov],'v','b-');
  axis square;
  title(sprintf('slope=%.3f',slope));
end

% calculate some stuff
borders = ([0 spaceparams rfov]/rfov)*(res/2) + (res/2+1);         % this is going to the right including 0 (vertical lines); for val V, a border should be the very left of pixel V
borders = [borders -([spaceparams rfov]/rfov)*(res/2)+(res/2+1)];  % this is going to the left (vertical lines)
borders = sort(borders - 0.5);  % now this means the actual location of the borders (in pixel units), sorted
ncond = (length(borders)-1) + (length(borders)-1-1);  % number of different spatial configurations for each of horizontal and vertical bars

% make all the textures [ZEBRA CASE]
im = (imagefilter(rand(1.5*res,1.5*res,numframes)-.5,constructbutterfilter(1.5*res,1.5*cpf,5)) > 0) - 0.5;  % values either -.5 or .5
im = -detectedges(im,0.1);  % black lines
im = placematrix(zeros(res,res,numframes),im,[]);
offset = 1;
sname = 'prf';
% NOW RUN START
boostZEBRA = boost;  % keep a record!

%%% START

% boost
boost = .5 / max(abs(flatten(imagefilter(im,flt,2))));
im = boost * im;

% proceed
center = (1+res)/2;
p = 1;
b1 = 1;
for b2=2:length(borders)  % modulate in horizontal direction.  move from left to right.
  if b2==length(borders)
    mask0 = mask;
  else
    mask0 = mask .* makecircleimage(res,borders(b2)-transzone/2-center,[],[],borders(b2)+transzone/2-center,3);
  end
  images{offset} = postprocess(sprintf('%sh%02d',sname,p),im,flt,mask0,finalres,1);
  conimages{offset} = mask0;
  offset = offset + 1;
  p = p + 1;
end
b2 = length(borders);
for b1=2:length(borders)-1  % now the gap moves from left to right.
  mask0 = mask .* (1-makecircleimage(res,borders(b1)-transzone/2-center,[],[],borders(b1)+transzone/2-center,3));
  images{offset} = postprocess(sprintf('%sh%02d',sname,p),im,flt,mask0,finalres,1);
  conimages{offset} = mask0;
  offset = offset + 1;
  p = p + 1;
end
p = 1;
b1 = 1;
for b2=2:length(borders)  % modulate in the vertical direction.  move from bottom to top.
  if b2==length(borders)
    mask0 = mask;
  else
    mask0 = mask .* makecircleimage(res,borders(b2)-transzone/2-center,[],[],borders(b2)+transzone/2-center,4);
  end
  images{offset} = postprocess(sprintf('%sv%02d',sname,p),im,flt,mask0,finalres,1);
  conimages{offset} = mask0;
  offset = offset + 1;
  p = p + 1;
end
b2 = length(borders);
for b1=2:length(borders)-1  % now the gap moves from ?
  mask0 = mask .* (1-makecircleimage(res,borders(b1)-transzone/2-center,[],[],borders(b1)+transzone/2-center,4));
  images{offset} = postprocess(sprintf('%sv%02d',sname,p),im,flt,mask0,finalres,1);
  conimages{offset} = mask0;
  offset = offset + 1;
  p = p + 1;
end

% % % % proceed to discs [ignore p, b1, b2]
% % % for p=1:(length(borders)-3)/2
% % %   midix = 1 + (length(borders)-3)/2 + 1;
% % %   mask0 = makecircleimage(res,borders(midix+p)-transzone/2-center,[],[],borders(midix+p)+transzone/2-center,0);
% % %   images{offset} = postprocess(sprintf('%sd%02d',sname,p),im,flt,mask0,finalres,1);
% % %   conimages{offset} = mask0;
% % %   offset = offset + 1;
% % % end

%%%%%% GRATING [contrast: manual, bandpass: none]

% different orientation gratings (full-contrast)
ors = linspacecircular(0,pi,8);
offset = 39;
for p=1:8
  im = makegratings2d(res,cpfov,-ors(p),numframes)/2 + 0.5;  % in [0,1]
  images{offset} = postprocess(sprintf('orientation%d',p),im - 0.5,[],mask,finalres,1);
  offset = offset + 1;
end

% contrast modulation of horizontal grating
cons = round(logspace(log10(2),log10(20),4));  % 2 4 9 20
offset = 39+8;
im = makegratings2d(res,cpfov,0,numframes)/2 + 0.5;  % in [0,1]
im = varycontrast(im,cons,1);
for p=1:length(im)
  images{offset} = postprocess(sprintf('single%d',p),im{p} - 0.5,[],mask,finalres,1);
  offset = offset + 1;
end

% contrast modulation of plaid and circular, matched to contrast of the single-grating case
ornums = [1 2 16];
confactors = [20 100 100];
energies = [];
im = {};
for pp=1:length(ornums)
  ors = linspacecircular(0,pi,ornums(pp));
  for rep=1:numframes
    im0 = 0;
    for p=1:length(ors)
      im0 = im0 + makegrating2d(res,[cpfov],ors(p),rand*2*pi)/2;  % in [-.5,.5], but then summed across orientations
    end
    im{pp}(:,:,rep) = confactors(pp)/100 * im0;
  end
  energies(pp) = mean(vectorlength(squish(bsxfun(@times,im{pp},mask),2),1));
end
offset = 39+8+4;
for qq=1:length(cons)
  images{offset} = postprocess(sprintf('plaid%d',qq),im{2} * energies(1)/energies(2) * cons(qq)/20,[],mask,finalres,1);
  offset = offset + 1;
end
for qq=1:length(cons)
  images{offset} = postprocess(sprintf('circularplaid%d',qq),im{3} * energies(1)/energies(3) * cons(qq)/20,[],mask,finalres,1);
  offset = offset + 1;
end

% contrast modulation of zebra
cons = round(logspace(log10(1),log10(50),10));
cons(3) = 3;  % 1 2 3 4 6 9 14 21 32 50
offset = 39+8+4+4+4;
for p=1:length(cons)  % NOTE THE USAGE OF images{10} !!
  images{offset} = postprocess(sprintf('zebra%02d',p),(double(images{10})-127)/127/2 * (cons(p)/100),[],[],[],1);
  offset = offset + 1;
end

%%%%%% SPARSE [contrast: max it (based on the first one), bandpass: just do it]

% sparse bandpassed line
spacing = 9;  % it was originally 8.53333333333333.  SO THIS IS AN IMPERFECTION
jumps = [1 2 4 8 16];
largerres = 2*res;
offset = 39+8+4+4+4+10;
hackoffset = 79;%%%HACK
for p=1:length(jumps)
  pos = hackoffset + round(linspacecircular(1,1+spacing*jumps(p),numframes));  % IMPERFECT!
  im = zeros(largerres,largerres,numframes);
  for q=1:length(pos)
    im(pos(q):spacing*jumps(p):end,:,q) = -0.5;  % black bars
  end
  if p==1
    boost = .5 / max(abs(flatten(imagefilter(im,flt,2))));
  end
  boostSPARSE = boost;
  im = boost * im;
  images{offset} = postprocess(sprintf('sparse%d',p),im,flt,mask,finalres,1);
  offset = offset + 1;
end

%%%%%% ZEBRASCALE [contrast: inherit from original zebra, bandpass: straight-up]

temp = log(logspace(log10(0.35),log10(2),4));  % manual selection
temp = [temp temp(end)+(temp(2)-temp(1))];
temp = exp(temp);
%%%%%COMMENT OUT SO WE GET A FULL SET.   temp(4) = [];
cpftodo = totalfov ./ temp;
offset = 39+8+4+4+4+10+5;
for p=1:length(cpftodo)
  im = (imagefilter(rand(1.5*res,1.5*res,numframes)-.5,constructbutterfilter(1.5*res,1.5*cpftodo(p),5)) > 0) - 0.5;  % values either -.5 or .5
  im = -detectedges(im,0.1);  % black lines
  im = placematrix(zeros(res,res,numframes),im,[]);
  boost = boostZEBRA;
  im = boost * im;
  if p==4
    imzsc = im;
  end
  images{offset} = postprocess(sprintf('zebrascale%d',p),im,flt,mask,finalres,1);
  offset = offset + 1;
end

%%%%%% SPARSECOHERENCE [be wary that cropping loses energy]

spacing = 9;  % SO THIS IS AN IMPERFECTION
jumps = [1 2 4 8 16];
largerres = 2*res;
p = 4;
pos = 79 + 1;  % manually figure out the best position.  ever so slightly off center
im = zeros(largerres,largerres);
im(pos:spacing*jumps(p):end,:) = -0.5;  % black bars
  %find(im(:,100))
imsparse = im;  % keep a record
cohlevels = linspace(0,100,5);  %fliplr(100-[0 100/1.5^3 100/1.5^2 100/1.5 100])   %
cohlevels(end) = [];
im = phasescrambleimage(imagefilter(boostSPARSE * im,flt,2),cohlevels);
imsparseB = im;
offset = 39+8+4+4+4+10+5+5;
for p=1:size(im,3)
  images{offset} = postprocess(sprintf('sparsecoherence%02d',p),im(:,:,p),[],mask,finalres,1,[]);
  offset = offset + 1;
end

%%%%%% ZEBRACOHERENCE [be wary that cropping loses energy]

cohlevels = linspace(0,100,5);
cohlevels(end) = [];
im = phasescrambleimage(imagefilter(imzsc,flt,2),cohlevels);
imzcoh2 = im;
offset = 39+8+4+4+4+10+5+5+4;
for p=1:size(im,3)
  images{offset} = postprocess(sprintf('zebracoherence%02d',p),im(:,:,p),[],mask,finalres,1);
  offset = offset + 1;
end

%%%%%%%%%%%%%%%%% SAVE AND INSPECT

save('workspace_monsterecog.mat','-v7.3');

% thumbnails [show one of each on one image; repeat for all frames]
for p=1:1   %30  %9
  ok = {};
  for q=1:length(images)
    if p > size(images{q},3)
      ok{end+1} = zeros(128,128);
    else
      ok{end+1} = imresize(double(images{q}(:,:,p)),[128 128]);
    end
  end
  imwrite(uint8(255*makeimagestack(cat(3,ok{:}),[0 254])),sprintf('thumbnails%d.png',p));
end

% thumbalt [write out first frame of each as individual image]
for p=1:length(images)
  imwrite(uint8(imresize(double(images{p}(:,:,1)),[res res])),sprintf('thumbalt%03d.png',p));
end

%%%%%%%%%%%%%%%%% EXPORT

% export
stimuli = cat(3,images{:});
save('socforecog.mat','stimuli');
