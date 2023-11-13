options = coins_options;

for subID = options.subjectIDs
    details = coins_subjects(subID, options);
    load(details.analysis.behav.responseData, 'subData');
    excludedBlocks = details.excludedBlocks;
    % Go through data block-wise, extract kernels and compute performance

    for iSess = 1: details.nSessions
        for iBlock = 1: 4
            blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
            % check whether current block is excluded
            if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
                avgKernels(iSess, iBlock, :, :) = NaN(6, options.behav.kernelPreSamples + ...
                    options.behav.kernelPostSamples + 1);
                nKernels(iSess, iBlock, :) = 0;
                isMoves = false;
            else
                % compute integration kernels
                [avgKernels(iSess, iBlock, :, :), nKernels(iSess, iBlock, :), ...
                    blockMoves(iSess, iBlock)] = ...
                    coins_compute_blockKernels(blockData, options);
                isMoves = true;
            end
            
            % allocate kernels to different conditions
            conditionLabels(iSess, iBlock) = unique(blockData.volatility);
            if unique(blockData.volatility)==1
                volKernels(iSess, iBlock, :, :) = avgKernels(iSess, iBlock, :, :);
                staKernels(iSess, iBlock, :, :) = NaN(size(avgKernels, 3, 4));
                if isMoves
                    volMoves(iSess, iBlock) = blockMoves(iSess, iBlock);
                end
            else
                volKernels(iSess, iBlock, :, :) = NaN(size(avgKernels, 3, 4));
                staKernels(iSess, iBlock, :, :) = avgKernels(iSess, iBlock, :, :);
                if isMoves
                    staMoves(iSess, iBlock) = blockMoves(iSess, iBlock);
                end
            end
        end
    end
    save(details.analysis.behav.blockKernels, 'avgKernels', 'nKernels', ...
        'volKernels', 'staKernels');
    save(details.analysis.behav.blockMoves, 'blockMoves', 'staMoves', 'volMoves');

    nMoveKernels = squeeze(nKernels(:, :, 1));
    nSizeKernels = squeeze(nKernels(:, :, 2));
    nMoveKernelsLeft = squeeze(nKernels(:, :, 3));
    nMoveKernelsRight = squeeze(nKernels(:, :, 4));
    nSizeKernelsUp = squeeze(nKernels(:, :, 5));
    nSizeKernelsDown = squeeze(nKernels(:, :, 6));
    nResponses.move = sum(sum(nMoveKernels));
    nResponses.size = sum(sum(nSizeKernels));
    nResponses.sizeUp = sum(sum(nSizeKernelsUp));
    nResponses.sizeDown = sum(sum(nSizeKernelsDown));
    nResponses.volatile.move = sum(sum(nMoveKernels(conditionLabels==1)));
    nResponses.volatile.size = sum(sum(nSizeKernels(conditionLabels==1)));
    nResponses.volatile.sizeUp = sum(sum(nSizeKernelsUp(conditionLabels==1)));
    nResponses.volatile.sizeDown = sum(sum(nSizeKernelsDown(conditionLabels==1)));
    nResponses.stable.move = sum(sum(nMoveKernels(conditionLabels==0)));
    nResponses.stable.size = sum(sum(nSizeKernels(conditionLabels==0)));
    nResponses.stable.sizeUp = sum(sum(nSizeKernelsUp(conditionLabels==0)));
    nResponses.stable.sizeDown = sum(sum(nSizeKernelsDown(conditionLabels==0)));
    save(details.analysis.behav.nResponses, 'nResponses');

    steps.stepSizes = [];
    steps.smallSteps = [];
    steps.unifSteps = [];
    
    steps.stable.stepSizes = [];
    steps.stable.smallSteps = [];
    steps.stable.unifSteps = [];
    
    steps.volatile.stepSizes = [];
    steps.volatile.smallSteps = [];
    steps.volatile.unifSteps = [];
    
    for iSess = 1: details.nSessions
        for iBlock = 1: 4
            steps.stepSizes = [steps.stepSizes; blockMoves(iSess,iBlock).stepSizes];
            steps.smallSteps = [steps.smallSteps; blockMoves(iSess,iBlock).nSmallSteps];
            steps.unifSteps = [steps.unifSteps; blockMoves(iSess,iBlock).nUnifiedSteps];
            steps.stable.stepSizes = [steps.stable.stepSizes; staMoves(iSess,iBlock).stepSizes];
            steps.stable.smallSteps = [steps.stable.smallSteps; staMoves(iSess,iBlock).nSmallSteps];
            steps.stable.unifSteps = [steps.stable.unifSteps; staMoves(iSess,iBlock).nUnifiedSteps];
            steps.volatile.stepSizes = [steps.volatile.stepSizes; volMoves(iSess,iBlock).stepSizes];
            steps.volatile.smallSteps = [steps.volatile.smallSteps; volMoves(iSess,iBlock).nSmallSteps];
            steps.volatile.unifSteps = [steps.volatile.unifSteps; volMoves(iSess,iBlock).nUnifiedSteps];
        end
    end

    fh = coins_plot_subject_kernels_by_volatility(staKernels, volKernels, ...
    nResponses, details, options);
    savefig(fh, details.analysis.behav.kernelConditionPlot)

    clear avgKernels staKernels volKernels blockMoves staMoves volMoves
end