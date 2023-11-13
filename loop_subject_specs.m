options = coins_options;
specTable = [];

for subID = options.subjectIDs
    details = coins_subjects(subID, options);
    load(details.analysis.behav.responseData, 'subData');
    excludedBlocks = details.excludedBlocks;
    
    % N responses / block
    %load(details.analysis.behav.blockMoves, 'blockMoves', 'staMoves', 'volMoves');
    load(details.analysis.behav.nResponses, 'nResponses');

    % Reward / block, total reward
    load(details.analysis.behav.performance, 'perform');
    blockReward = []; volReward = []; staReward = [];
    for iSess = 1:details.nSessions
        for iBlock = 1:4
            blockReward = [blockReward perform{iSess,iBlock}.reward];
            if perform{iSess,iBlock}.volatility
                volReward = [volReward perform{iSess,iBlock}.reward];
            else
                staReward = [staReward perform{iSess,iBlock}.reward];
            end
        end
    end

    specTable = [specTable; ...
        [subID nResponses.move nResponses.size sum(blockReward) mean(blockReward) ...
        nResponses.stable.move nResponses.stable.size sum(staReward) mean(staReward) ...
        nResponses.volatile.move nResponses.volatile.size sum(volReward) mean(volReward) ]];

    T = array2table(specTable,...
    'VariableNames',{'SubID','nMove','nSize', 'totalReward', 'rewardPerBlock', ...
    'nMoveStable', 'nSizeStable', 'totalRewardStable', 'rewardPerBlockStable', ...
    'nMoveVolatile', 'nSizeVolatile', 'totalRewardVolatile', 'rewardPerBlockVolatile'});

    % Kernel plots
    %load(details.analysis.behav.blockKernels, 'avgKernels', 'nKernels', ...
    %    'volKernels', 'staKernels');
    % Adjustment plots
    %load(details.analysis.behav.meanAdjustments, 'meanAdjusts');

end