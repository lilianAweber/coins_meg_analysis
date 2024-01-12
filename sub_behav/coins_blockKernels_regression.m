function [ betasCon, nTrialsCon, avgKernelsCon, nKernelsCon, fh1, fh2 ] = ...
    coins_blockKernels_regression( subData, excludedBlocks, options )

% Go through data block-wise, extract kernels
nBlocks = zeros(2,1);
for iSess = 1: max(subData.sessID)
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        % check whether current block is excluded
        if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
            betas(iSess, iBlock, :) = NaN(1, options.behav.kernelPreSamplesEvi);
            nTrials(iSess, iBlock) = 0;
        else
            % compute integration kernels using regression method
            [betas(iSess, iBlock, :), nTrials(iSess, iBlock)] ...
                ...avgKernels(iBlock, :), nKernels(iBlock)] ...
                = coins_compute_regressionKernels(blockData, options);
        end
       
        % allocate kernels to different conditions
        vol = unique(blockData.volatility)+1;
        nBlocks(vol) = nBlocks(vol) + 1;
        betasCon{vol}(nBlocks(vol), :) = betas(iSess, iBlock, :);
        nTrialsCon{vol}(nBlocks(vol)) = nTrials(iSess, iBlock);
        %avgKernelsCon{vol,sto}(nBlocks(vol,sto), :) = avgKernels(iBlock, :);
        %nKernelsCon{vol,sto}(nBlocks(vol,sto)) = nKernels(iBlock);
    end
end
%fh1 = coins_plot_subject_kernels_by_volatility(avgKernelsCon, nKernelsCon, options);
avgKernelsCon = [];
nKernelsCon = [];
fh1 = [];
fh2 = coins_plot_subject_betas_by_volatility(betasCon, nTrialsCon, options);


end