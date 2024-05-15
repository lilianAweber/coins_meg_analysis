function coins_subjectKernels( details, options )
%COINS_SUBJECTKERNELS Computes behavioural integration kernels using
%regression for all blocks of all sessions of one participant in the COINS
%study

load(details.analysis.behav.responseData, 'subData');

excludedBlocks = details.excludedBlocks;

[betasCon, nTrialsCon, avgKernelsCon, nKernelsCon, ~, fh2] = ...
    coins_blockKernels_regression(subData, excludedBlocks, options);
save(details.analysis.behav.blockRegKernels, ...
    'betasCon', 'nTrialsCon', 'avgKernelsCon', 'nKernelsCon');

%savefig(fh1, details.analysis.regKernelConditionPlot)
savefig(fh2, details.analysis.behav.regBetaConditionPlot)


end