function [ betasCon, nTrialsCon, fh ] = ...
    coins_blockKernels_regression( subData, excludedBlocks, options )
%COINS_BLOCKKERNELS_REGRESSION Computes behavioural integration kernels
%using regression from the data in subData, excluding blocks listed in
%excludedBlocks

nSessions = max(subData.sessID);
nBlocksPerSession = 4;
nSamples = options.behav.kernelPreSamplesEvi;

% count the number of blocks in each condition
nBlocks = zeros(2,1);

betas = NaN(nSessions, nBlocksPerSession, nSamples);
nTrials = NaN(nSessions, nBlocksPerSession);

for iSess = 1: nSessions
    for iBlock = 1: nBlocksPerSession
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        
        % check whether current block is excluded
        if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
            betas(iSess, iBlock, :) = NaN(1, nSamples);
            nTrials(iSess, iBlock) = 0;
        else
            % compute integration kernels using regression method
            [betas(iSess, iBlock, :), nTrials(iSess, iBlock)] ...
                = coins_compute_regressionKernels(blockData, options);
        end
       
        % allocate kernels to different conditions
        vol = unique(blockData.volatility)+1;
        nBlocks(vol) = nBlocks(vol) + 1;
        betasCon{vol}(nBlocks(vol), :) = betas(iSess, iBlock, :);
        nTrialsCon{vol}(nBlocks(vol)) = nTrials(iSess, iBlock);
    end
end
fh = coins_plot_subject_betas_by_volatility(betasCon, nTrialsCon, options);

end