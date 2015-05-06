%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare x-val R^2 computation
%   - The average R^2 across folds is an underestimate of the R^2 of the 
%     concatenated results
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 1;
s = 0.5;
avals = [0, 0.25, 0.5, 0.75, 1];
evals = [1, 2, 4, 8, 16]; 

voxNum = 31;
outputdir = ['data/modelfits/2015-05-04/vox', num2str(voxNum)];

badR2 = [];
goodR2 = [];
for a = avals
    for e = evals
        if (a == 0) && (e > 1)
            continue;
        end
        load(fullfile(rootpath, outputdir, ...
        ['aegridsearch-a', num2str(a), '-e', num2str(e), '-subj', num2str(datasetNum), '.mat']), ...
        'results');
    
        badR2 = [badR2, results.xvalr2];
        goodR2 = [goodR2, results.concatR2];
    end
end

figure; hold on;
unityline = linspace(0, 1, 100);
plot(unityline, unityline, 'k-');
plot(badR2, goodR2, 'o');