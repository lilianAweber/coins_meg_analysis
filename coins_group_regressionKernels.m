function coins_group_regressionKernels(options)

nSubjects = numel(options.subjectIDs);
resultsDir = fullfile(options.workDir, 'behav');

% collect
for iSub = 1: nSubjects
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.blockRegKernels, 'betasCon');
        
    groupKernels(iSub, 1, :) = squeeze(nanmean(betasCon{1},1));
    groupKernels(iSub, 2, :) = squeeze(nanmean(betasCon{2},1));
end
avgGroupKernels = squeeze(mean(groupKernels,1));
seGroupKernels = squeeze(std(groupKernels)./sqrt(nSubjects));
save(fullfile(resultsDir, ['n' num2str(nSubjects) '_regressionBetas.mat']), ...
    'groupKernels', 'avgGroupKernels', 'seGroupKernels');

% plot
fh = coins_plot_group_regressionKernels(avgGroupKernels, seGroupKernels, ...
    nSubjects, options);
savefig(fh, fullfile(resultsDir, ['n' num2str(nSubjects) ...
    '_regressionBetas_perCondition.fig']))
fh = coins_plot_group_regressionKernels_perSubject(groupKernels, nSubjects, options);
savefig(fh, fullfile(resultsDir, ['n' num2str(nSubjects) ...
    '_regressionBetas_perSubject_zoom.fig']))


end