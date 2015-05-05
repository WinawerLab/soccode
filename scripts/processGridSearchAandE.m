%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Process the results for the grid search on a and e:
%   - Load data for multiple a and e values, and compare best R^2 with each
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-04');

datasetNum = 3;

voxNums = [31,42,59,71,72,77,81,83,89,90,10,19,22,29,30,33,35,36,38,47,1,3,7,8,9,12,15,16,18,20,...
           94,104,115,116,122,125,131,142,143,148,57,60,62,65,68,69,73,76,78,79,24,25,26,28,32,34,37,40,41,43];
avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 4, 8, 16]; 

aggregateResults = ones(length(avals), length(evals), length(voxNums));
aggregateResults = aggregateResults * NaN;
%%
for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['vox', num2str(voxNum)];

    for aidx = 1:length(avals)
        for eidx = 1:length(evals)

            a = avals(aidx);
            e = evals(eidx);

            if (a == 0) && (e > 1)
                continue;
            end

            filename = ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat'];
            try
                load(fullfile(dataloc, folder, filename));
                
                aggregateResults(aidx, eidx, voxIdx) = results.xvalr2;
            end
            
        end
    end
end

%%
agg = aggregateResults(:);
figure; hist(agg);

%% Take the mean over A and E
im = nanmean(aggregateResults, 3);
figure; colormap(hot); imagesc(im);

byA = nanmean(im, 2);
figure; plot(avals, byA, 'o-'); title('Results by A')

byE = nanmean(im(2:end,:), 1);
figure; plot(evals, byE, 'o-'); title('Results by E')

%% For each voxel, how big is the best minus worst difference?
mins = min(min(aggregateResults, [], 2), [], 1);
maxs = max(max(aggregateResults, [], 2), [], 1);
diffs = maxs - mins;

figure; hist(diffs(:));

%% What if we just pick one, which one do we pick?
origs = squeeze(aggregateResults(1, 1, :));
%new = squeeze(aggregateResults(2, 2, :));
new = squeeze(aggregateResults(3, 2, :));

figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(origs, new, 'o');
xlabel('Original'); ylabel('New');

