function coins_group_regressionKernels_sessionWise(options)

nSubjects = numel(options.subjectIDs);
resultsDir = fullfile(options.workDir, 'behav');

% collect
for iSub = 1: numel(options.subjectIDs)
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.sessRegKernels5, ...
        'volBetas', 'staBetas', 'nTrialsVol', 'nTrialsSta');
    grpVolBetas(iSub, :, :) = volBetas;
    grpStaBetas(iSub, :, :) = staBetas;
    grpTrialsVol(iSub,:) = nTrialsVol;
    grpTrialsSta(iSub,:) = nTrialsSta;
end

save(fullfile(resultsDir, ['n' num2str(nSubjects) ...
    '_regressionBetas_sessionWise.mat']), 'grpVolBetas', 'grpStaBetas', ...
    'grpTrialsSta', 'grpTrialsVol');

% average over sessions
mVolBetas = squeeze(mean(grpVolBetas,2));
mStaBetas = squeeze(mean(grpStaBetas,2));
nBetas = size(mStaBetas,2);

% plot effects per subject
fh = coins_plot_subject_regKernels_sessionWise(mVolBetas, mStaBetas);
savefig(fh, fullfile(resultsDir, 'n22_regressionBetas.fig'))

% plot reliability over sessions
sub2use = 1:size(grpVolBetas,1);
%sub2use([6 8 21]) = [];
fh = coins_plot_betaWeights_across_subjects_sessions(grpVolBetas, sub2use);
fh = coins_plot_betaWeights_across_subjects_sessions(grpStaBetas, sub2use);

% visualise individidual differences in where the effect of volatility
% shows (sample -2 versus -3)
volEffects = mVolBetas - mStaBetas;
fh = figure;
plot(1:nBetas, volEffects, '-', 'color', col.highNoise);
hold on
yline(0);
for i=1:nBetas
    plot(i, squeeze(volEffects(:,i)), 'o', 'color', col.medNoise, 'MarkerFaceColor', col.medNoise);
    hold on
end
xlim([0.5 nBetas+0.5])
box off
ylabel('betas volatile - betas stable')
xticks(1:nBetas);

switch nBetas
    case 11
        xticklabels({'-5', '-4', '-3', '-2', '-1', ...
            'noise', ...
            'noise*(-5)', 'noise*(-4)', 'noise*(-3)', 'noise*(-2)', 'noise*(-1)'});
    case 7
        xticklabels({'-3', '-2', '-1', ...
            'noise', ...
            'noise*(-3)', 'noise*(-2)', 'noise*(-1)'});
end
title('Effect of volatility on betas')
fh.Children.LineWidth = 1;
fh.Children.FontSize = 14;
savefig(fh, fullfile(resultsDir, 'n22_volatilityEffects_onRegressionBetas.fig'))

end