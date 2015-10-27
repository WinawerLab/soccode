%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment: Process the results for the grid search on a and e:
%   - Load data for multiple a and e values, and compare best R^2 with each
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataloc = fullfile(rootpath, 'data', 'modelfits', '2015-05-08');

datasetNum = 3;

% Subj 3 batch 1:
voxNums = [509,198,181,83,97,183,353,82,339,359,367,366,518,210,310,227,779,459,786,111,959,851,953,859,861,949,781,965,694,856];

% Subj 4 batch 1:
%voxNums = [167,44,100,308,172,17,171,84,101,16,94,200,619,190,105,204,191,309,274,746,205,954,390,106,315,797,795,389,327,482];

avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 4, 8, 16]; 

aggregateResults = ones(length(avals), length(evals), length(voxNums));
aggregateResults = aggregateResults * NaN;

% %% Fix concat predictions
% for voxIdx = 1:length(voxNums)
%     voxNum = voxNums(voxIdx);
%     fixConcatPredictions(datasetNum, voxNum);
% end
%%
for voxIdx = 1:length(voxNums)
    voxNum = voxNums(voxIdx);
    folder = ['subj', num2str(datasetNum), '-vox', num2str(voxNum)];

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
                
                aggregateResults(aidx, eidx, voxIdx) = results.accumR2;
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

% TAKEAWAYS: All of these are better

%% For each voxel, how big is the best minus worst difference?
mins = min(min(aggregateResults, [], 2), [], 1);
maxs = max(max(aggregateResults, [], 2), [], 1);
diffs = maxs - mins;

figure; hist(diffs(:));

%% What if we just pick one, which one do we pick?
origs = squeeze(aggregateResults(1, 1, :));
%new = squeeze(aggregateResults(2, 2, :));
new = squeeze(aggregateResults(4, 5, :));

figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(origs(origs > new), new(origs > new), 'ro');
plot(origs(origs <= new), new(origs <= new), 'go');
xlabel('Original'); ylabel('New');