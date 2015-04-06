% inherits from prepareimages_wn.m and prepareimages.m.
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXECUTIVE SUMMARY
% 
% MONSTER:
% 
% 1. prf apertures using zebras [69]
% 
% 70. grating orientations [8]
% 78. contrast response using gratings [4] (1 shared, the 100% contrast)
% 82. contrast response using plaid [4]
% 86. contrast response using circular [4]
% 90. contrast response using zebra [10] (1 shared, the 100% contrast)
% 
% 100. objects [1]
% 101. phase-scrambled objects [1]
% 102. faces [1]
% 103. houses [1]
% 104. letters [1]
% 105. polygons, filled [1]
% 106. natural images [1]
% 
% 107. sparse [5]
% 112. zebra scales [4] (1 shared)
% 
% 116. prf apertures using wn, reduced set [24]
% 
% 140. WN contrast [5]
% 145. VV [3], HH [3], VH [1], HV [1], WNV [1], VWN [1], WNH [1], HWN [1]
% 
% % 156 stimuli, 39 per run. 4 run types. repeated 3 times each, 12 runs total per session.
% % 800 px, 12.5¡, 64 px/¡, aim for 3 cpd, 37.5 cycles total. minimum 37.5*4 = 150 pixel analysis.
% % 0.5¡Êouter edge ramp, 1 cyc/¡ in the ramp; 11.5¡Êvalid stimulus / 1¡Êramp
% % central objects should be 4¡Êtotal.
% % in general, 9 unique frames would be nice.
% % for PRF stimuli, transition zone should be 1/6 deg (which corresponds to 3 cyc/deg)
% 
%   prf  grator  v1calib  crf    classes  sparse    scale     2ndorder  focus
% [1:69  70:77   78:89    90:99  100:106  107:111   112:115   116:139   140:156]
% 
% MONSTERSUB:
% 
% 1-3. zebra [3]
% 4-6. horizontal [3]
% 7-9. vertical [3]
% 
% % 9 stimuli, all 9 and rep 2 per run. 1 run type. repeated 20 times each, 20 runs total per session.
% % same stimulus characteristics as MONSTER.
% 
%  zebra      H         V
% [43 59 47   145:147   148:150]
% % note: ALL STIMULI WERE ALREADY GENERATED IN MONSTER!
% 
% MONSTERTEST:
% 
% gain calibration:  [as taken from monster]
% 1. zebra
% 2. natural images
% 3. SP1
% 4. SP4
% 5. bandpass
% 
% single images:
% 6-17. objects [12]
% 18-29. natural images [12]
% 30-34. sparse coherence [5]
% 35-39. sparse additive [5]
% 40-45. traditional [6]
% 46-54. array of gabors [9]
% 55-59. angles [5]
% 60-64. connor [5]
% 
% % 5+59=64 stimuli, 32 per run. 2 run types. repeated 6 times each, 12 runs total per session.
% 
%   gain  obj   natim  coh    add    trad   array  angle  silh
% [ 1:5   6:17  18:29  30:34  35:39  40:45  46:54  55:59  60:64]
% 
% MONSTERTESTB:
% 
% single images:
% 1-35. objects [35]
% 
% % 35 stimuli, 35 per run. 1 run type. repeated 10 times each.
% 
% MONSTERB:
% 
% 1-10. zebra contrasts
% 11-20. bandpass contrasts
% 21-30. sparse1 contrasts
% 31-40. sparse2 contrasts
% 41-50. sparse3 contrasts
% 
% setnum 42 does the first four, setnum 43 does the first three and the fifth one.
% 
% % same as above, except: 40 stimuli, 40 per run. repeated 10 times, so 10 runs per session.
% % setnum 42: interpret wrt [0,252] because we leave last three for fixation colors.
% % setnum 43: interpret wrt [0,252] because we leave last three for white fixation color (repeated three).
% % special handling of contrast changes in ptviewmovie.m.
% % ***starting with MONSTERB, we do better setting of boost. to maximize contrast.
% 
% SUBADD:
% 
% 1. zebra (3)
% 2. zebra sep (3)
% 3. zebra bandpass (3)
% 4. zebra bandpass sep (3)
% 5. bandpass (3)
% 6. bandpass sep (3)
% 7. checker (3)
% 8. checker sep (3)
% 9. bars (3)
% 10. bars sep (3)
% 
% % 30 stimuli, 30 per run. 1 run type. repeated 6 times in a session.
% % 800 px, 12.5¡, 64 px/¡, aim for 3 cpd, 37.5 cycles total.
% % 0.5¡Êouter edge ramp, 1 cyc/¡ in the ramp; 11.5¡ valid stimulus / 1¡ ramp
% % 30 unique frames.
% % transition zone 1/6 deg (which corresponds to 3 cyc/deg)
% % range is [0,254]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETUP

% define
finalres = 800;                % target resolution for the stimuli
  res = 150;  % for simulations only
res = 256;                     % native resolution that we construct at
res = 300;       % FOR MONSTERB
res = 800;       % FOR SUBADD
totalfov = 12.5;               % total number of degrees for FOV
rfov = totalfov/2;             % radius of FOV in degrees
cpd = 3;                       % target cycles per degree
cpfov = totalfov*cpd;          % cycles per FOV that we are aiming for
spacing = res/cpfov;           % pixels to move from one cycle to the next
bandwidth = 1.5;               % bandwidth in octaves for the target SF band
band = 1;                      % fraction of linear bandwidth to use for transition zone of target SF band
bandexpt = 5;                  % exponent to apply to the amplitude spectrum of target SF band for fitting purposes
frac = 11.5/totalfov;          % what fraction of radius for the circular mask to start at
numframes = 9;                 % how many images from each class (if applicable)
numframes = 30;  % FOR SUBADD
fltsz = -21;                   % filter pixel size
  % FOR SUBADD
  fltsz = -51;
innerres = floor(4/totalfov * res/2)*2;       % pixels that results in 4¡ square.  round down until we get even number of pixels.
flatband = 1.5;                % bandwidth for local regression flattening
transzone = res/totalfov * 1/6;  % entire transition zone is this much in pixels
nb = 7;                        % number of cuts in between meridian and edge for main PRF stimuli
cpf = totalfov/2;              % cycles per field of view for standard zebra texture

% FOR SUBADD
spotecc = 1.5;
spotwidth = 1;

%%%%%%%%%%%%%%%%% PREPARE BANDPASS FILTER AND CIRCULAR MASK

% make bandpass DOG filter (flt, fltamp)
delta = cpfov * (2^bandwidth - 1) / (2^bandwidth + 1);
fltA = constructcosinefilter(res,[cpfov-delta cpfov+delta],band*(2*delta));  % this is the amp spectrum to match
fltB = fouriertospace(fltA,fltsz,1);
[xx,yy] = meshgrid(1:res,1:res);
options = optimset('Display','iter','MaxFunEvals',Inf,'MaxIter',1000,'TolFun',1e-6,'TolX',1e-6);
[dogparams,d,d,exitflag,output] = lsqcurvefit(@(a,b) flatten(abs(fft2(evaldog2d([round(res/2) round(res/2) a(1) a(2) 1 a(3) 0],b)))).^bandexpt, ...
  [5 2 3],[flatten(xx); flatten(yy)],flatten(fltA).^bandexpt,[],[],options);  % find DOG that best matches fltA
  % hint: [4.90746463574716            1.003407332782          2.60375841945078]
assert(exitflag > 0);
fltF = abs(fft2(evaldog2d([round(res/2) round(res/2) dogparams(1) dogparams(2) 1 dogparams(3) 0],xx,yy)));  % get amp spectrum of DOG
flt = fouriertospace(fltF,fltsz,1);  % convert to spatial domain.  this is the final DOG filter!!!
fltamp = abs(fft2(placematrix(zeros(res,res),flt,[])));  % this is the amp of the final DOG filter!!!
  % dogparams is 1.5678069947586          1.00901971507702          9.66656915269888

% detour save [note for the seed above, we temporarily change to [2 2 3]
save('~/inout/workspacesimulations.mat');

% make masks (mask,mask2)
mask = makecircleimage(res,res/2*frac,[],[],res/2);  % white (1) circle on black (0)
viewimage(mask);
mask2 = makecircleimage(innerres,res/2*frac-(res/2-innerres/2),[],[],innerres/2,1) .* ...
        makecircleimage(innerres,res/2*frac-(res/2-innerres/2),[],[],innerres/2,2);  % white (1) rectangle on black (0)
viewimage(mask2);

%%%%%%%%%%%%%%%%% CONSTRUCT STIMULI [SUBADD]

% define [WE OMIT IMRESIZE BECAUSE RES==FINALRES]
wtfun = @(x) max(abs(flatten(bsxfun(@plus,bsxfun(@times,placematrix(0*ones([size(mask) size(x,3)]),imagefilter(x,flt,2),[]),mask),(1-mask) * 0))));

% initialize
images = {};
conimages = {};
offset = 1;

% more
center = (1+res)/2;
cuts = center + [spotecc-spotwidth/2 spotecc spotecc+spotwidth/2] * (res/totalfov);

% more
  % no transition, center
masksA = {mask .* makecircleimage(res,cuts(2)-center,[],[],cuts(2)-center,4) ...
         mask .* (1-makecircleimage(res,cuts(2)-center,[],[],cuts(2)-center,4)) ...
         mask};
  % no transition, gap
masksB = {mask .* makecircleimage(res,cuts(1)-center,[],[],cuts(1)-center,4) ...
         mask .* (1-makecircleimage(res,cuts(3)-center,[],[],cuts(3)-center,4))};
masksB{3} = masksB{1} + masksB{2};
  % transition, center
masksC = {mask .* makecircleimage(res,cuts(2)-transzone/2-center,[],[],cuts(2)+transzone/2-center,4) ...
         mask .* (1-makecircleimage(res,cuts(2)-transzone/2-center,[],[],cuts(2)+transzone/2-center,4)) ...
         mask};
  % transition, gap
masksD = {mask .* makecircleimage(res,cuts(1)-transzone/2-center,[],[],cuts(1)+transzone/2-center,4) ...
         mask .* (1-makecircleimage(res,cuts(3)-transzone/2-center,[],[],cuts(3)+transzone/2-center,4))};
masksD{3} = masksD{1} + masksD{2};

% make zebras
im = (imagefilter(rand(1.5*res,1.5*res,numframes)-.5,constructbutterfilter(1.5*res,1.5*cpf,5)) > 0) - 0.5;  % values either -.5 or .5
im = placematrix(zeros(res,res,numframes),im,[]);
imORIG = im;  % save a copy
%im doesn't need boost

masks = masksA;
str = 'zebra';
fltUSE = [];
% NOW DO A

masks = masksB;
str = 'zebrasep';
fltUSE = [];
% NOW DO A

% make bandpass zebras
imALT = imORIG;
imALT = -detectedges(imALT,0.1);  % black lines
imALT = placematrix(zeros(res,res,numframes),imALT,[]);
boostALT = .5 / feval(wtfun,imALT);
imALT = boostALT * imALT;
im = imALT;

masks = masksC;
str = 'zebraband';
fltUSE = flt;
% NOW DO A

masks = masksD;
str = 'zebrabandsep';
fltUSE = flt;
% NOW DO A

% make bandpass noise
im = rand(res,res,numframes) - 0.5;
boost = .5 / feval(wtfun,im);
im = boost * im;

masks = masksC;
str = 'bandpass';
fltUSE = flt;
% NOW DO A

masks = masksD;
str = 'bandpasssep';
fltUSE = flt;
% NOW DO A

% make checkerboards
%cuts - center is 64    96    128
sz = res/totalfov;
im = repmat([zeros(sz,sz) ones(sz,sz);
            ones(sz,sz) zeros(sz,sz)],[ceil(res/(2*sz))+2 ceil(res/(2*sz))+2]);
swpl = 96;
im = placematrix(zeros(res,res),im,[mod(swpl,sz)-2*sz-47 -47]);
%clf; plot([im(401 - 96,:); im(401 - 97,:)]','o-');
im = repmat(cat(3,im,1-im),[1 1 15]) - 0.5;

masks = masksA;
str = 'checker';
fltUSE = [];
% NOW DO A

masks = masksB;
str = 'checkersep';
fltUSE = [];
% NOW DO A

% make bars
im = repmat(im(:,200,:),[1 res]);

masks = masksA;
str = 'bar';
fltUSE = [];
% NOW DO A

masks = masksB;
str = 'barsep';
fltUSE = [];
% NOW DO A

% A
for qq=1:length(masks)
  mask0 = masks{qq};
  images{offset} = postprocess(sprintf('%s%02d',str,qq),im,fltUSE,mask0,[],1);  % we pass finalres as [] because we do not need upsampling
  conimages{offset} = mask0;
  offset = offset + 1;
end

%%%%%%%%%%%%%%%%% CONSTRUCT STIMULI [MONSTERB]

% define
wtfun = @(x) max(abs(flatten(processmulti(@imresize,bsxfun(@plus,bsxfun(@times,placematrix(0*ones([size(mask) size(x,3)]),imagefilter(x,flt,2),[]),mask),(1-mask) * 0),[finalres finalres],'lanczos3'))));

% initialize
images = {};
imagecontrasts = [];
offset = 1;

%%%% TYPE 1 [for each type, run the POST]

% make base zebra texture
im = (imagefilter(rand(1.5*res,1.5*res,numframes)-.5,constructbutterfilter(1.5*res,1.5*cpf,5)) > 0) - 0.5;  % values either -.5 or .5
im = -detectedges(im,0.1);  % black lines
im = placematrix(zeros(res,res,numframes),im,[]);
boost = .5 / feval(wtfun,im);
im = boost * im;
baseim = postprocess(sprintf('basezebra'),im,flt,mask,finalres,1,[],252);

%%%% TYPE 2 [for each type, run the POST]

% make white noise
im = rand(res,res,numframes) - 0.5;
boost = .5 / feval(wtfun,im);
im = boost * im;
baseim = postprocess(sprintf('basewn'),im,flt,mask,finalres,1,[],252);

%%%% TYPE 3 [for each type, run the POST]

% make sparse lines
  % note that we use the spacing variable as calculated earlier...
jump = 1;  % jump = 2; jump = 4;
largerres = 2*res;
pos = round(linspacecircular(1,1+spacing*jump,numframes));
im = zeros(largerres,largerres,numframes);
for q=1:length(pos)
  im(pos(q):spacing*jump:end,:,q) = -0.5;  % black bars
end
  % NOTE: RUN THIS LINE ONLY for jump=1.  jump=2 and 4 inherits the previous value.
boost = .5 / feval(wtfun,im);
  % NOTE END.
im = boost * im;
baseim = postprocess(sprintf('sparse1'),im,flt,mask,finalres,1,[],252);  % sparse2, sparse3

%%%% POST START

% fake copies for contrast
for p=1:10
  images{offset} = baseim;
  offset = offset + 1;
end

% setup the contrast values
cons = logspace(log10(1),log10(100),10);
imagecontrasts = [imagecontrasts upsamplematrix(cons,numframes,2,[],'nearest')];

%%%% POST END

%%%%%%%%%%%%%%%%% CONSTRUCT STIMULI [MONSTER]

% initialize
images = {};
conimages = {};

%%%%%% PRF [contrast: max it, bandpass: straight-up]

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

% make all the textures [WN CASE]    (bandpassed uniform white noise)
im = rand(res,res,numframes) - 0.5;
bordersorig = borders;
borders = borders([1 6 8 9 10 12 17])
offset = 116;
sname = 'prfwn';
% NOW RUN START
imWN = im;  % keep a record!
borders = bordersorig;  % restore

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

% proceed to discs [ignore p, b1, b2]
for p=1:(length(borders)-3)/2
  midix = 1 + (length(borders)-3)/2 + 1;
  mask0 = makecircleimage(res,borders(midix+p)-transzone/2-center,[],[],borders(midix+p)+transzone/2-center,0);
  images{offset} = postprocess(sprintf('%sd%02d',sname,p),im,flt,mask0,finalres,1);
  conimages{offset} = mask0;
  offset = offset + 1;
end

%%%%%% GRATING [contrast: manual, bandpass: none]

% different orientation gratings (full-contrast)
ors = linspacecircular(0,pi,8);
offset = 70;
for p=1:8
  im = makegratings2d(res,cpfov,-ors(p),numframes)/2 + 0.5;  % in [0,1]
  images{offset} = postprocess(sprintf('orientation%d',p),im - 0.5,[],mask,finalres,1);
  offset = offset + 1;
end

% contrast modulation of horizontal grating
cons = round(logspace(log10(2),log10(20),4));  % 2 4 9 20
offset = 78;
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
offset = 82;
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
offset = 90;
for p=1:length(cons)  % NOTE THE USAGE OF images{16} !!
  images{offset} = postprocess(sprintf('zebra%02d',p),(double(images{16})-127)/127/2 * (cons(p)/100),[],[],[],1);
  offset = offset + 1;
end

%%%%%% CLASSES [contrast: see below, bandpass: see below]

% large-scale natural photos
% NOTE: each image is flattened and each image is individually contrast normalized
naturalphotosrec = randperm(2228);
im = zeros(res,res,numframes);
for p=1:numframes, p
  imfile = sprintf('/research/stimuli/natrev/photos.redogray/image%06d.png',naturalphotosrec(p));
  im(:,:,p) = flattenspectra(imresize((double(imread(imfile))/255) .^ 2,[res res],'lanczos3'),fltsz,0,flatband);
end
temp = bsxfun(@times,imagefilter(im,flt,2),mask);
ener = vectorlength(squish(temp,2),1);
boost = .5 / max(abs(flatten(bsxfun(@rdivide,temp,reshape(ener,[1 1 numframes])))));
im = bsxfun(@times,im,reshape(boost./ener,[1 1 numframes]));
images{106} = postprocess('naturalimages',im,flt,mask,finalres,1);

% faces
% NOTE: each image is flattened and each image is individually contrast normalized
im0 = loadmulti('/research/stimuli/objectcategories/faces.mat','images') .^ 2;
facesrec = randperm(size(im0,3));
im = zeros(innerres,innerres,numframes);
for p=1:numframes, p
  im(:,:,p) = flattenspectra(imresize(im0(:,:,facesrec(p)),[innerres innerres],'lanczos3'),fltsz,0,flatband);
end
im = imagefilter(im,flt,2);
im = bsxfun(@minus,im,reshape(median(squish(im,2),1),[1 1 numframes]));
im = bsxfun(@times,im,mask2);
ener = vectorlength(squish(im,2),1);
boost = .5 / max(abs(flatten(bsxfun(@rdivide,im,reshape(ener,[1 1 numframes])))));
im = bsxfun(@times,im,reshape(boost./ener,[1 1 numframes]));
im = placematrix(zeros(res,res,numframes),im,[]);
images{102} = postprocess('faces',im,[],mask,finalres,1);

% houses
% NOTE: each image is flattened and each image is individually contrast normalized
im0 = loadmulti('/research/stimuli/objectcategories/houses.mat','images') .^ 2;
load('data.mat');
ix = find(recHOUSE==30);
housesrec = permutedim(ix,0);  %housesrec = randperm(size(im,3));
im = zeros(innerres,innerres,numframes);
for p=1:numframes, p
  im(:,:,p) = flattenspectra(imresize(im0(:,:,housesrec(p)),[innerres innerres],'lanczos3'),fltsz,0,flatband);
end
im = imagefilter(im,flt,2);
im = bsxfun(@times,im,mask2);
ener = vectorlength(squish(im,2),1);
boost = .5 / max(abs(flatten(bsxfun(@rdivide,im,reshape(ener,[1 1 numframes])))));
im = bsxfun(@times,im,reshape(boost./ener,[1 1 numframes]));
im = placematrix(zeros(res,res,numframes),im,[]);
images{103} = postprocess('houses',im,[],mask,finalres,1);

% objects
% NOTE: each image is flattened and each image is individually contrast normalized
im0 = reshape(loadmulti('/research/stimuli/kriegeskorte/images.mat','images')',[175 175 92]) .^ 2;
load('data.mat');
[d,ix] = sort(recJW+recHH+recMB+recAM+recKK);
ix2 = find(recFILTER==32);
objectsrec = ix(ismember(ix,ix2));  %objectsrec = randperm(92);
im = zeros(res,res,numframes);
for p=1:numframes, p
  % note that this is slightly different from the case of faces and houses.  here we use flatband at a different image resolution.  probably ok?
  im(:,:,p) = flattenspectra(placematrix(im0(1,1,1)*ones(res,res),imresize(im0(:,:,objectsrec(p)),[innerres innerres],'lanczos3'),[]),fltsz,0,flatband);
end
im = imagefilter(im,flt,2);
ener = vectorlength(squish(im,2),1);
boost = .5 / max(abs(flatten(bsxfun(@rdivide,im,reshape(ener,[1 1 numframes])))));
im = bsxfun(@times,im,reshape(boost./ener,[1 1 numframes]));
images{100} = postprocess('objects',im,[],mask,finalres,1);

% phase-scrambled objects
% NOTE that there is no rescaling (but we lose a little energy when cropping).
% NOTE that this line relies on the images{100} variable from above
temp = processmulti(@imresize,(double(images{100})-127)/127/2,[res res],'lanczos3');
im = placematrix(zeros(88,88,numframes),temp,[]);  % NOTE THE HAND CODED VALUE
im0 = placematrix(zeros(res,res,numframes),phasescrambleimage(im,0),[]);
images{101} = postprocess('phasescramble',im0,[],mask,finalres,1);

% polygons (filled)
% NOTE: the whole ensemble is contrast scaled.  and straight up bandpassing.
rots = [pi/2 pi/4 2*pi/5/4 0 2*pi/7/4*3 2*pi/8/2 0];
im = drawclosedcontours(res,0,0,innerres/res,rots,[0 0 0],0,[],[1 1 1],encapsulate(@coordpolygon,[3:8 100]));  % black on white
for p=1:size(im,3)
      %  com = centerofmass(abs(imagefilter(im(:,:,p),flt,2)));  % WE COULD HAVE FILTERED FIRST, BUT EITHER WAY, THE CENTER OF MASS DIDN'T CHANGE ANYTHING!
        %  com = centerofmass(1-im(:,:,p));
  com = [mean(find(sum(1-im(:,:,p),2) > 1)) mean(find(sum(1-im(:,:,p),1) > 1))];  % A BIT UGLY, BUT EMPIRICALLY IT WORKS
  im(:,:,p) = placematrix(ones(res,res),im(:,:,p),[1 1] + round(repmat((res+1)/2,1,2) - com));
end
im = im - 0.5;
fillmask = im<0;
im(fillmask) = rand(1,count(fillmask)) - 0.5;
im(~fillmask) = 0.5;
boost = .5 / max(abs(flatten(imagefilter(im,flt,2))));
im = boost * im;
images{105} = postprocess('polygons',im,flt,mask,finalres,1);

% letters
% NOTE: the whole ensemble is flattened (and then bandpassed). then contrast boosted as an ensemble.
if 0
  dy = -1/res;                   % font y-offset
  fontsize = innerres/190 * .7;
  temp = subscript(permutedim(mat2cell('A':'Z',1,ones(1,26))),1:numframes);
  im = drawtexts(res,0,dy,'Helvetica',fontsize,[0 0 0],[1 1 1],temp)/2 - 0.5;  % black (-.5) on gray (0)
  im = flattenspectra(im,fltsz,1,flatband);
end
boost = .5 / max(abs(flatten(imagefilter(im,flt,2))));
im = boost * im;
images{104} = postprocess('letters',im,flt,mask,finalres,1);

%%%%%% SPARSE [contrast: max it (based on the first one), bandpass: just do it]

% sparse bandpassed line
spacing = 7;  % it was originally 6.82667.  SO THIS IS AN IMPERFECTION
jumps = [1 2 4 8 16];
largerres = 2*res;
offset = 107;
for p=1:length(jumps)
  pos = round(linspacecircular(1,1+spacing*jumps(p),numframes));  % IMPERFECT!
  im = zeros(largerres,largerres,numframes);
  for q=1:length(pos)
    im(pos(q):spacing*jumps(p):end,:,q) = -0.5;  % black bars
  end
  if p==1
    boost = .5 / max(abs(flatten(imagefilter(im,flt,2))));
  end
  im = boost * im;
  images{offset} = postprocess(sprintf('sparse%d',p),im,flt,mask,finalres,1);
  offset = offset + 1;
end

%%%%%% ZEBRASCALE [contrast: inherit from original zebra, bandpass: straight-up]

temp = log(logspace(log10(0.35),log10(2),4));  % manual selection
temp = [temp temp(end)+(temp(2)-temp(1))];
temp = exp(temp);
temp(4) = [];
cpftodo = totalfov ./ temp;
offset = 112;
for p=1:length(cpftodo)
  im = (imagefilter(rand(1.5*res,1.5*res,numframes)-.5,constructbutterfilter(1.5*res,1.5*cpftodo(p),5)) > 0) - 0.5;  % values either -.5 or .5
  im = -detectedges(im,0.1);  % black lines
  im = placematrix(zeros(res,res,numframes),im,[]);
  boost = boostZEBRA;
  im = boost * im;
  images{offset} = postprocess(sprintf('zebrascale%d',p),im,flt,mask,finalres,1);
  offset = offset + 1;
end

%%%%%% COMBO [contrast: inherit from original, bandpass: none except the usual]

% collect up the carriers [each 256 x 256 x 9]
wngrat = imagefilter(imWN,flt,2);
hgrat = makegratings2d(res,cpfov,-0,numframes)/2;  % in -.5 .5
vgrat = makegratings2d(res,cpfov,-pi/2,numframes)/2;  % in -.5 .5

% match contrast energy for fun
wnenergy = mean(vectorlength(squish(bsxfun(@times,wngrat,mask),2),1));
henergy = mean(vectorlength(squish(bsxfun(@times,hgrat,mask),2),1));
venergy = mean(vectorlength(squish(bsxfun(@times,vgrat,mask),2),1));
hgrat = hgrat * (wnenergy / henergy);
vgrat = vgrat * (wnenergy / venergy);

% prepare masks
b1 = 13; b2 = 13;
mask0a = mask .* makecircleimage(res,borders(b2)-transzone/2-center,[],[],borders(b2)+transzone/2-center,4);
mask0b = mask .* (1-makecircleimage(res,borders(b1)-transzone/2-center,[],[],borders(b1)+transzone/2-center,4));

% define function
cfun = @(x,y) bsxfun(@plus,bsxfun(@times,x,mask0a),bsxfun(@times,y,mask0b));

% do it
images{140} = postprocess('titrate1',feval(cfun,.2*wngrat,0),[],[],finalres,1);
images{141} = postprocess('titrate2',feval(cfun,0,.2*wngrat),[],[],finalres,1);
images{142} = postprocess('titrate3',feval(cfun,.2*wngrat,.2*wngrat),[],[],finalres,1);
images{143} = postprocess('titrate4',feval(cfun,.2*wngrat,wngrat),[],[],finalres,1);
images{144} = postprocess('titrate5',feval(cfun,wngrat,.2*wngrat),[],[],finalres,1);
images{145} = postprocess('vv1',feval(cfun,vgrat,0),[],[],finalres,1);
images{146} = postprocess('vv2',feval(cfun,0,vgrat),[],[],finalres,1);
images{147} = postprocess('vv3',feval(cfun,vgrat,vgrat),[],[],finalres,1);
images{148} = postprocess('hh1',feval(cfun,hgrat,0),[],[],finalres,1);
images{149} = postprocess('hh2',feval(cfun,0,hgrat),[],[],finalres,1);
images{150} = postprocess('hh3',feval(cfun,hgrat,hgrat),[],[],finalres,1);
images{151} = postprocess('vh',feval(cfun,vgrat,hgrat),[],[],finalres,1);
images{152} = postprocess('hv',feval(cfun,hgrat,vgrat),[],[],finalres,1);
images{153} = postprocess('wnv',feval(cfun,wngrat,vgrat),[],[],finalres,1);
images{154} = postprocess('vwn',feval(cfun,vgrat,wngrat),[],[],finalres,1);
images{155} = postprocess('wnh',feval(cfun,wngrat,hgrat),[],[],finalres,1);
images{156} = postprocess('hwn',feval(cfun,hgrat,wngrat),[],[],finalres,1);

%%%%%%%%%%%%%%%%% CONSTRUCT STIMULI [MONSTERTEST]

% define [x is res x res x n.  filter x, mask it, resize to final res, then figure out max abs value]
wtfun = @(x) max(abs(flatten(processmulti(@imresize,bsxfun(@plus,bsxfun(@times,placematrix(0*ones([size(mask) size(x,3)]),imagefilter(x,flt,2),[]),mask),(1-mask) * 0),[finalres finalres],'lanczos3'))));
wtfunB = @(x) max(abs(flatten(bsxfun(@plus,bsxfun(@times,placematrix(0*ones([size(mask) size(x,3)]),x,[]),mask),(1-mask) * 0))));

% load
tempload = load('workspace_monster.mat');

% initialize
images = {};
offset = 1;

% steal gain calibration
images{1} = tempload.images{16};   % zebra
images{2} = tempload.images{106};  % natural images
images{3} = tempload.images{107};  % SP1
images{4} = tempload.images{110};  % SP4
images{5} = tempload.images{121};  % bandpass
offset = 6;

% objects [12 of them] [each image is flattened and each image is individually contrast normalized]
im0 = reshape(loadmulti('/research/stimuli/kriegeskorte/images.mat','images')',[175 175 92]) .^ 2;
t1 = load('data.mat');
[d,ix] = sort(t1.recJW+t1.recHH+t1.recMB+t1.recAM+t1.recKK);
ix2 = find(t1.recFILTER==32);
objectsrec = ix(ismember(ix,ix2));  %objectsrec = randperm(92);
objoffset = 9;  % WE ALREADY USED THE FIRST 9!
innerres = 200;
      %save('~/inout/tete.mat','im','im0','res','objectsrec','objoffset','innerres','fltsz','flatband');
im = zeros(res,res,12);
for p=1:size(im,3), p
  % note that this is slightly different from the case of faces and houses.  here we use flatband at a different image resolution.  probably ok?
  im(:,:,p) = flattenspectra(placematrix(im0(1,1,1)*ones(res,res),imresize(im0(:,:,objectsrec(objoffset+p)),[innerres innerres],'lanczos3'),[]),fltsz,0,flatband);
end
    %save('~/inout/tete2.mat','im');
    %load('~/inout/tete2.mat','im');
imobj = im;  % keep a record
boostobj = [];
for p=1:size(im,3), p
  boostobj(p) = .5 / feval(wtfun,im(:,:,p));
  images{offset} = postprocess(sprintf('object%02d',p),boostobj(p) * im(:,:,p),flt,mask,finalres,1,[]);
  offset = offset + 1;
end

% natural images [12 of them] [each image is flattened and each image is individually contrast normalized]
naturalphotosrec = tempload.naturalphotosrec;
naturalphotosoffset = 9;  % WE ALREADY USED THE FIRST 9!
    save('~/inout/teB.mat','naturalphotosrec','naturalphotosoffset','res','fltsz','flatband');
im = zeros(res,res,12);
for p=1:size(im,3), p
%  imfile = sprintf('/research/stimuli/natrev/photos.redogray/image%06d.png',naturalphotosrec(p));
  imfile = sprintf('~/ext/stimuli/natrev/photos.redogray/image%06d.png',naturalphotosrec(naturalphotosoffset+p));
  im(:,:,p) = flattenspectra(imresize((double(imread(imfile))/255) .^ 2,[res res],'lanczos3'),fltsz,0,flatband);
end
    save('~/inout/teB2.mat','im');
    load('~/inout/teB2.mat','im');
imnatural = im;  % keep a record
boostnatural = [];
for p=1:size(im,3), p
  boostnatural(p) = .5 / feval(wtfun,im(:,:,p));
  images{offset} = postprocess(sprintf('natural%02d',p),boostnatural(p) * im(:,:,p),flt,mask,finalres,1,[]);
  offset = offset + 1;
end

% sparse coherence [be wary that cropping loses energy]
spacing = 7;  % it was originally 6.82667.  SO THIS IS AN IMPERFECTION
jumps = [1 2 4 8 16];
largerres = 2*res;
p = 4;
pos = 4;  % manually figure out the best position.  ever so slightly off center
im = zeros(largerres,largerres);
im(pos:spacing*jumps(p):end,:) = -0.5;  % black bars
  %find(im(:,100))
imsparse = im;  % keep a record
boostsparse = 0.955444533091907;  % this was what we got when we did sparse in monster.  preserve it.
cohlevels = linspace(0,100,5);  %fliplr(100-[0 100/1.5^3 100/1.5^2 100/1.5 100])   %
im = phasescrambleimage(imagefilter(boostsparse * im,flt,2),cohlevels);
imsparseB = im;
for p=1:size(im,3)
  images{offset} = postprocess(sprintf('sparsecoherence%02d',p),im(:,:,p),[],mask,finalres,1,[]);
  offset = offset + 1;
end

% sparse additive noise
addlevels = linspace(0,100,5);  % 100 means all of SP4.  0 means all of bandpass.
imA = imagefilter(boostsparse * imsparse,flt,2);
imtemp = rand(largerres,largerres) - 0.5;
boostaddnoise = .5 / feval(wtfun,imtemp);
imB = imagefilter(boostaddnoise * imtemp,flt,2);
imadditive = imB;  % keep a record
for p=1:length(addlevels)
  images{offset} = postprocess(sprintf('sparseadditive%02d',p), ...
    imA*(addlevels(p)/100) + imB*(1-addlevels(p)/100),[],mask,finalres,1,[]);
  offset = offset + 1;
end

% traditional 2nd order
  % horizontal grating modulator
maskmod = makegratings2d(res,cpfov/4,-0,1)/2;  % in -.5 .5
images{offset} = postprocess(sprintf('traditional%02d',1),                  tempload.hgrat(:,:,5),[],mask,finalres,1,[]);
offset = offset + 1;
images{offset} = postprocess(sprintf('traditional%02d',2),(maskmod + .5) .* tempload.hgrat(:,:,5),[],mask,finalres,1,[]);
offset = offset + 1;
images{offset} = postprocess(sprintf('traditional%02d',3),                  tempload.vgrat(:,:,5),[],mask,finalres,1,[]);
offset = offset + 1;
images{offset} = postprocess(sprintf('traditional%02d',4),(maskmod + .5) .* tempload.vgrat(:,:,5),[],mask,finalres,1,[]);
offset = offset + 1;
images{offset} = postprocess(sprintf('traditional%02d',5),                  tempload.wngrat(:,:,5),[],mask,finalres,1,[]);
offset = offset + 1;
images{offset} = postprocess(sprintf('traditional%02d',6),(maskmod + .5) .* tempload.wngrat(:,:,5),[],mask,finalres,1,[]);
offset = offset + 1;

% array of gabors

  % figure out appropriate gabor parameters
pp = [37.5 1];  % cycles per FOV; sfbandwidth in octave fwhm. [initial seed]
xx = []; yy = [];
[test,d,xx,yy] = makegabor2d(res,[],[],pp(1),0,pi,-pp(2),xx,yy);
options = optimset('Display','iter','MaxFunEvals',Inf,'MaxIter',1000,'TolFun',1e-6,'TolX',1e-6);
ggfun =  @(a) abs(fft2(makegabor2d(res,[],[],a(1),0,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),pi/8,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),2*pi/8,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),3*pi/8,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),4*pi/8,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),5*pi/8,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),6*pi/8,pi,-a(2),xx,yy))) + ...
              abs(fft2(makegabor2d(res,[],[],a(1),7*pi/8,pi,-a(2),xx,yy)));
[gbrparams,d,d,exitflag,output] = lsqcurvefit(@(a,b) a(3)*flatten(feval(ggfun,a)).^bandexpt, ...
  [pp 1/20],[],flatten(fltamp).^bandexpt,[],[],options);  % find Gabor that best matches fltamp

  % OK. let's proceed.
arraygrid = linspace((1+res)/2 - (1.2*(1+res)/2), ...
                     (1+res)/2 + (1.2*(1+res)/2),1000);
[arrayrr,arraycc] = meshgrid(arraygrid,arraygrid);
arrayspacing = [10 20 40];
arraycoherence = [0 20 100];
xx = []; yy = []; arrayrec = {}; orval = {};
for p=1:length(arrayspacing)

  % figure out arrayrec first
  ix = find(ones(numel(arrayrr),1));  % these are the valid ones currently
  arrayrec{p} = [];
  while ~isempty(ix)
    fprintf('.');
    wh = picksubset(ix,1,sum(100*clock));
    arrayrec{p} = [arrayrec{p} wh];
    good = sqrt((arrayrr(ix) - arrayrr(wh)).^2 + (arraycc(ix) - arraycc(wh)).^2) >= arrayspacing(p);
    ix = ix(good);
  end

  % continue
  for q=1:length(arraycoherence)
    orval{p,q} = zeros(1,length(arrayrec{p}));
    im = 0;
    for r=1:length(arrayrec{p})
      if arraycoherence(q)==0
        orval{p,q}(r) = rand*pi;
      elseif arraycoherence(q)==100
        orval{p,q}(r) = 0;
      else
        orval{p,q}(r) = 0 + randn*arraycoherence(q)/180*pi;
      end
      [gbrfilter,d,xx,yy] = makegabor2d(res,arrayrr(arrayrec{p}(r)),arraycc(arrayrec{p}(r)), ...
                                        gbrparams(1),orval{p,q}(r),pi,-gbrparams(2),xx,yy);
      im = im + gbrfilter;
    end
    images{offset} = postprocess(sprintf('array%02d_%02d',p,q),im/2,[],mask,finalres,1,[]);
    offset = offset + 1;
  end
end

% array of angles (ito)
arrayspacingANG = logspace(log10(25),log10(100),5);
anglesize = .2;
xx = []; yy = []; arrayparamsANG = {}; arraygridANG = {}; arrayrrANG = {}; arrayccANG = {};
for p=1:length(arrayspacingANG)

  xmin = (1+res)/2 - arrayspacingANG(p)/2;
  while xmin > (1+res)/2 - (1.2*(1+res)/2)
    xmin = xmin - arrayspacingANG(p);
  end

  xmax = (1+res)/2 + arrayspacingANG(p)/2;
  while xmax < (1+res)/2 + (1.2*(1+res)/2)
    xmax = xmax + arrayspacingANG(p);
  end
  
  arraygridANG{p} = xmin:arrayspacingANG(p):xmax;
  [arrayrrANG{p},arrayccANG{p}] = meshgrid(arraygridANG{p},arraygridANG{p});

  % continue
  arrayparamsANG{p} = zeros(length(arraygridANG{p}),length(arraygridANG{p}),2);  % overall angle orientation; angle separation
  im = 0;
  for q=1:length(arraygridANG{p}), q
    for r=1:length(arraygridANG{p})
      arrayparamsANG{p}(q,r,:) = reshape([rand*2*pi (rand*160 + 10)/180*pi],[1 1 2]);
      xpos = normalizerange(arrayccANG{p}(q,r),-.5,.5,.5,res+.5,0);
      ypos = normalizerange(arrayrrANG{p}(q,r),.5,-.5,.5,res+.5,0);

      angim = drawclosedcontours(res,0,0,1,arrayparamsANG{p}(q,r,1),[], ...
                                 -1,[0 0 0],[1 1 1],anglesize*coordangle(0,arrayparamsANG{p}(q,r,2)));
      com = centerofmass(1-angim);
      xposhack = ((1+res)/2 - com(2)) / res;  % negative means to the right
      yposhack = ((1+res)/2 - com(1)) / res;  % negative means to the down

      angim = drawclosedcontours(res,xpos+xposhack,ypos-yposhack,1,arrayparamsANG{p}(q,r,1),[], ...
                                 -1,[0 0 0],[1 1 1],anglesize*coordangle(0,arrayparamsANG{p}(q,r,2)));

      angim = imagefilter(angim/2 - 0.5,flt,2);
      im = im + angim;
    end
  end
  if p==1
    boostangle = .5 / feval(wtfunB,im);
  end
  images{offset} = postprocess(sprintf('angle%02d',p),boostangle * im,[],mask,finalres,1,[]);
  offset = offset + 1;
end

% array of connor
  % read in preprocessed images
temp = matchfiles({'/research/berkeley/notebook/AAE. papers/2009 population coding chapter/figures/STIMCLASS/connor2/images/*.png'});
connorims = zeros(64,64,length(temp));
for p=1:length(temp)
  connorims(:,:,p) = double(imread(temp{p}));
end
connorims = connorims/255;  % 64 x 64 x 366.  range is [0,1].  background is white.  disc is black.  figure is white.
  % blank out the circle   [so that we have white figure on black background]
blackcircle = makecircleimage(64,28);
for p=1:size(connorims,3)
  okok = connorims(:,:,p);
  okok(blackcircle==0) = 0;
  connorims(:,:,p) = okok;
end
  % edge detect
connorims = detectedges(connorims,0.1);  % values are non-negative.  bright indicates the edges.
  % calculate center of mass and filter
connorxhack = []; connoryhack = [];
for p=1:size(connorims,3)
  com = centerofmass(connorims(:,:,p));
  connorxhack(p) = ((1+64)/2 - com(2));  % negative means to the right
  connoryhack(p) = ((1+64)/2 - com(1));  % negative means to the down
  connorims(:,:,p) = imagefilter(-connorims(:,:,p),flt,2);
end
  % go on
arrayspacingCNR = logspace(log10(25),log10(100),5);
xx = []; yy = []; arraygridCNR = {}; arrayrrCNR = {}; arrayccCNR = {}; arraywhichCNR = {};
for p=1:length(arrayspacingCNR)

  xmin = (1+res)/2 - arrayspacingCNR(p)/2;
  while xmin > (1+res)/2 - (1.2*(1+res)/2)
    xmin = xmin - arrayspacingCNR(p);
  end

  xmax = (1+res)/2 + arrayspacingCNR(p)/2;
  while xmax < (1+res)/2 + (1.2*(1+res)/2)
    xmax = xmax + arrayspacingCNR(p);
  end
  
  arraygridCNR{p} = xmin:arrayspacingCNR(p):xmax;
  [arrayrrCNR{p},arrayccCNR{p}] = meshgrid(arraygridCNR{p},arraygridCNR{p});

  % continue
  arraywhichCNR{p} = [];
  im = 0;
  for q=1:length(arraygridCNR{p}), q
    for r=1:length(arraygridCNR{p})
    
      arraywhichCNR{p}(q,r) = randint(1,1,[1 366]);

      cpx = round(arrayccCNR{p}(q,r) - 31.5 + connorxhack(arraywhichCNR{p}(q,r)));
      rpx = round(arrayrrCNR{p}(q,r) - 31.5 + connoryhack(arraywhichCNR{p}(q,r)));
      
      angim = zeros(3*res,3*res);
      angim(res + (rpx-1 + (1:64)),res + (cpx-1 + (1:64))) = connorims(:,:,arraywhichCNR{p}(q,r));
      angim = placematrix(zeros(res,res),angim,[]);
      
      im = im + angim;
    end
  end
  if p==1
    boostconnor = .5 / feval(wtfunB,im);
  end
  images{offset} = postprocess(sprintf('connor%02d',p),boostconnor * im,[],mask,finalres,1,[]);
  offset = offset + 1;
end

%%%%%%%%%%%%%%%%% CONSTRUCT STIMULI [MONSTERTESTB]

% define [x is res x res x n.  filter x, mask it, resize to final res, then figure out max abs value]
wtfun = @(x) max(abs(flatten(processmulti(@imresize,bsxfun(@plus,bsxfun(@times,placematrix(0*ones([size(mask) size(x,3)]),imagefilter(x,flt,2),[]),mask),(1-mask) * 0),[finalres finalres],'lanczos3'))));
wtfunB = @(x) max(abs(flatten(bsxfun(@plus,bsxfun(@times,placematrix(0*ones([size(mask) size(x,3)]),x,[]),mask),(1-mask) * 0))));

% load
tempload = load('workspace_monster.mat');

% initialize
images = {};
offset = 1;

% objects [35 of them] [each image is flattened and each image is individually contrast normalized]
im0 = reshape(loadmulti('/research/stimuli/kriegeskorte/images.mat','images')',[175 175 92]) .^ 2;
t1 = load('data.mat');
[d,ix] = sort(t1.recJW+t1.recHH+t1.recMB+t1.recAM+t1.recKK);
ix2 = find(t1.recFILTER==32);
objectsrec = ix(ismember(ix,ix2));  %objectsrec = randperm(92);

    % match the first test dataset and add some more objects
  whtoselect = [9+(1:12) permutedim(setdiff(1:length(objectsrec),9+(1:12)))];
  numobjectstodo = 35;

innerres = 200;
      %save('~/inout/tete.mat','im','im0','res','objectsrec','objoffset','innerres','fltsz','flatband');
im = zeros(res,res,numobjectstodo);
for p=1:numobjectstodo, p
  % note that this is slightly different from the case of faces and houses.  here we use flatband at a different image resolution.  probably ok?
  im(:,:,p) = flattenspectra(placematrix(im0(1,1,1)*ones(res,res),imresize(im0(:,:,objectsrec(whtoselect(p))),[innerres innerres],'lanczos3'),[]),fltsz,0,flatband);
end
    %save('~/inout/tete2.mat','im');
    %load('~/inout/tete2.mat','im');
imobj = im;  % keep a record
boostobj = [];
for p=1:size(im,3), p
  boostobj(p) = .5 / feval(wtfun,im(:,:,p));
  images{offset} = postprocess(sprintf('object%02d',p),boostobj(p) * im(:,:,p),flt,mask,finalres,1,[]);
  offset = offset + 1;
end

%%%%%%%%%%%%%%%%% SAVE AND INSPECT

save('workspace_monster.mat','-v7.3');
save('workspace_monstertest.mat','-v7.3');
save('workspace_monstertestB.mat','-v7.3');
save('workspace_monsterB.mat','-v7.3');
save('workspace_subadd.mat','-v7.3');

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

% inspect for fun
figure; imagesc(sum(double(images{16}),3));

%%%%%%%%%%%%%%%%% CHECK DISCRETIZATION [MONSTERB]

for stim=[1 11 21 31 41];
  con = 1;
  test = normalizerange(double(images{stim}(:,:,1)),0.5 - 0.5*(con/100),0.5 + 0.5*(con/100),0,252);
  test2 = round(test*256)/256;
  test3 = round(test*1024)/1024;
  
  cc = round(rand*800);
  figure; hold on;
  plot(test(:,cc),'r-');
  %plot(test2(:,400),'g.');
  plot(test3(:,cc),'b-');
  title(sprintf('%d',stim));
  
  figure; imagesc(test);
  figure; imagesc(test3);
end

%%%%%%%%%%%%%%%%% CHECK SPATIAL FREQUENCY OF SUBADD

load('workspace_subadd.mat');

% 4 deg square is this many pixels
sqpx = round(4 * (800/12.6))  % 254

% square extraction
ceil(400.5 - 96 - 254/2)  % row start (178)
floor(400.5 - 96 + 254/2)  % row end (431)
ceil(400.5 - 254/2)       % column start (274)
floor(400.5 + 254/2)       % column end (527)

% prep
win = hanning(sqpx)*hanning(sqpx)';

% do it
ps = 1:10;  % stimulus set
for ppp=1:length(ps)
  p = (ps(ppp)-1)*3 + 1;

  ft1 = zeros(254,254,30);
  ft2 = zeros(254,254,30);
  ft3 = zeros(254,254,30);
  for q=1:30
    ft1(:,:,q) = log(abs(fft2(win.*(double(images{p}(178:431,274:527,q)) - 127))));
    ft2(:,:,q) = log(abs(fft2(win.*(double(images{p+1}(178:431,274:527,q)) - 127))));
    ft3(:,:,q) = log(abs(fft2(win.*(double(images{p+2}(178:431,274:527,q)) - 127))));
  end
  
  ft1m = calcmdse(ft1(:,1,:),3);
  ft2m = calcmdse(ft2(:,1,:),3);
  ft3m = calcmdse(ft3(:,1,:),3);
  
  figureprep; hold on;
  errorbar3((1:254/2+1)-1,real(ft1m(1:254/2+1))',imag(ft1m(1:254/2+1))','v',[1 .7 .7]);
  errorbar3((1:254/2+1)-1,real(ft2m(1:254/2+1))',imag(ft2m(1:254/2+1))','v',[.7 1 .7]);
  errorbar3((1:254/2+1)-1,real(ft3m(1:254/2+1))',imag(ft3m(1:254/2+1))','v',[.7 .7 1]);
  figurewrite(sprintf('wtf%02d',ppp),[],[],'~/inout');
  
end

%%%%%%%%%%%%%%%%%%% JUNK:

% noncartesian noise
ncnnum = 70;
ncnrad = 1/5;
[im,ncnrecord,ncnreport] = noncartesian_noise(0,2*res,2*res,ncnnum,res * ncnrad,res * ncnrad,6,4,0.5,0,5,0);
im = flattenspectra(placematrix(zeros(res,res),im),fltsz,0,flatband);
imncn = im;  % keep a record
boostncn = .5 / feval(wtfun,im);
images{offset} = postprocess('ncn',boostncn * im,flt,mask,finalres,1,[]);
offset = offset + 1;
