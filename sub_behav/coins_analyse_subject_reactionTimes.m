function coins_analyse_subject_reactionTimes( subID, options )
%COINS_ANALYSE_SUBJECT_REACTIONTIMES Collect responses after mean jumps for
%all blocks of one participant and plot them

details = coins_subjects(subID, options);
load(details.analysis.behav.responseData, 'subData');
excludedBlocks = details.excludedBlocks;

allDurs = [];
volDurs = [];
staDurs = [];
allCounts = [];
volCounts = [];
staCounts = [];
allJumps = [];
volJumps = [];
staJumps = [];
allVars = [];
volVars = [];
staVars = [];
for iSess = 1: details.nSessions
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
            allDurations{iSess, iBlock} = [];
            allRespCounts{iSess, iBlock} = [];
            allJumpSizes{iSess, iBlock} = [];
            allVariances{iSess, iBlock} = [];
        else
        % compute movement durations after mean change
            [allDurations{iSess, iBlock}, allRespCounts{iSess, iBlock}, ...
                allJumpSizes{iSess, iBlock}, allVariances{iSess, iBlock}] = ...
                coins_compute_blockReactionTimes(blockData, options);
        end

        allDurs = [allDurs; allDurations{iSess,iBlock}];
        allCounts = [allCounts; allRespCounts{iSess,iBlock}];
        allJumps = [allJumps; allJumpSizes{iSess,iBlock}];
        allVars = [allVars; allVariances{iSess,iBlock}];

        if unique(blockData.volatility) == 1
            volDurs = [volDurs; allDurations{iSess, iBlock}];
            volCounts = [volCounts; allRespCounts{iSess, iBlock}];
            volJumps = [volJumps; allJumpSizes{iSess, iBlock}];
            volVars = [volVars; allVariances{iSess, iBlock}];
        else
            staDurs = [staDurs; allDurations{iSess, iBlock}];
            staCounts = [staCounts; allRespCounts{iSess, iBlock}];
            staJumps = [staJumps; allJumpSizes{iSess, iBlock}];
            staVars = [staVars; allVariances{iSess, iBlock}];
        end
    end
end

% Turn move durations (in frames) into distance travelled (in radians)
% Participants are moving 1 deg/frame
allDists = allDurs *pi/180;
staDists = staDurs *pi/180;
volDists = volDurs *pi/180;

save(details.analysis.behav.movements, 'staJumps', 'volJumps', 'staCounts', 'volCounts', ...
    'staDists', 'volDists', 'staVars', 'volVars');

% Plot the number of responses within 2.5s (options.behav.maxRTsamples) and
% the distance travelled by the 1) first response, 2) longest response, and
% 3) sum of all responses within 2.5s, per jump size and split into sta/vol

figure;
subplot(4, 2, 1)
title('N responses within 2.5s - stable blocks')
h1 = coins_plot_rt_subplots( staJumps, staCounts, 0 );

subplot(4, 2, 2)
title('N responses within 2.5s - volatile blocks')
h2 = coins_plot_rt_subplots( volJumps, volCounts, false );

subplot(4, 2, 3)
title('Distance by 1st response - stable blocks')
[h3, p] = coins_plot_rt_subplots( staJumps, staDists(:,1), 1 );
legend(p, 'distance to travel')

subplot(4, 2, 4)
title('Distance by 1st response - volatile blocks')
h4 = coins_plot_rt_subplots( volJumps, volDists(:,1), 1 );

subplot(4, 2, 5)
title('Longest distance - stable blocks')
h5 = coins_plot_rt_subplots( staJumps, max(staDists,[],2), 1 );

subplot(4, 2, 6)
title('Longest distance - volatile blocks')
h6 = coins_plot_rt_subplots( volJumps, max(volDists,[],2), 1 );

subplot(4, 2, 7)
title('Total distance within 2.5s - volatile blocks')
h7 = coins_plot_rt_subplots( staJumps, nansum(staDists,2), 1 );
xlabel('jump size (radians)')

subplot(4, 2, 8)
title('Total distance within 2.5s - stable blocks')
h8 = coins_plot_rt_subplots( volJumps, nansum(volDists,2), 1 );
xlabel('jump size (radians)')



end