function coins_subjectKernels_sessionWise( details, options )
%COINS_SUBJECTKERNELS Computes behavioural integration kernels using
%regression for all blocks of all sessions of one participant in the COINS
%study

load(details.analysis.behav.responseData, 'subData');

excludedBlocks = details.excludedBlocks;

options.behav.flagRegKernelSamples = 3;
for iSess = 1: details.nSessions
    sessData = subData(subData.sessID == iSess, :);
    [volBetas(iSess, :), staBetas(iSess, :), ...
        nTrialsVol(iSess), nTrialsSta(iSess)] = ...
        coins_compute_sessionwise_regressionKernels(sessData, options);
end
save(details.analysis.behav.sessRegKernels3, ...
    'volBetas', 'staBetas', 'nTrialsSta', 'nTrialsVol');
fh = coins_plot_subject_regKernels_sessionWise(volBetas, staBetas);
savefig(fh, details.analysis.behav.figSessRegKernels3);
clear volBetas staBetas nTrialsVol nTrialsSta

options.behav.flagRegKernelSamples = 5;
for iSess = 1: details.nSessions
    sessData = subData(subData.sessID == iSess, :);
    [volBetas(iSess, :), staBetas(iSess, :), ...
        nTrialsVol(iSess), nTrialsSta(iSess)] = ...
        coins_compute_sessionwise_regressionKernels(sessData, options);
end
save(details.analysis.behav.sessRegKernels5, ...
    'volBetas', 'staBetas', 'nTrialsSta', 'nTrialsVol');
fh = coins_plot_subject_regKernels_sessionWise(volBetas, staBetas);
savefig(fh, details.analysis.behav.figSessRegKernels5);


end