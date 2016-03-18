% It's coding time. Let's do this
% It's like an essay. You write out the structure

% Load the x
x = randn(10, 1);
x = x - 1.1*min(x); % some positive numbers

% Create the y
errsd = 0.1;
y = x.^2 + 2*x + errsd*randn(size(x));
y2 = x.^2 + 2*x + errsd*randn(size(x));

% Use nonlinear fitting
% Options:
%   - fit
%   - lsqcurvefit and lsqnonlin
%   - nlinfit (and its wrapper fitnlm) (stats toolbox) (provides statistics, but won't accept bounds)
%
% "fit" is a wrapper to a lot of things.
% I want to try out lots of ways to fit things, so why not use the
% higher-level wrapper?
%
% I'm going to assume that the stuff in KNK's fitnonlinear model are useful
% at some point, but not immediately, not for the proof-of-concept

%% EXAMPLE using "fit"
myeqn = fittype(@(a,n,b,x)(a*x.^n + b*x), ...
                'independent', 'x', ...
                'coefficients', {'a', 'n', 'b'});
opt = fitoptions(myeqn);
opt.lower = [-100, 0, -100];
opt.upper = [100, 10, 100];
opt.startpoint = [1, 1, 1];
[fitobj, goodness] = fit(x, y, myeqn, opt);

figure; hold on;
plot(x, y, 'ro'); plot(x, fitobj(x), 'bo'); plot(x, myeqn(1,2,2,x), 'go');

legend('data', ['Fit, ', num2str(sum(x-fitobj(x)).^2)], ['Generating seq, ', num2str(sum(x-myeqn(1,2,2,x)).^2)]);

%% EXAMPLE using "lsqfit"
myfn = @(params, xdata)(params(1)*xdata.^params(2) + params(3)*xdata);
params = lsqcurvefit(myfn,[1,1,1],x,y,[-100, 0, -100],[100, 10, 100]);

figure; hold on;
plot(x, y, 'ro'); plot(x, myfn(params,x), 'bo'); plot(x, myfn([1,2,2],x), 'go');

legend('data', ['Fit, ', num2str(sum(x-myfn(params,x)).^2)], ['Generating seq, ', num2str(sum(x-myfn([1,2,2],x)).^2)]);
