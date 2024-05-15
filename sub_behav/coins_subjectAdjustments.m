function coins_subjectAdjustments( details, options )
%COINS_SUBJECTADJUSTMENTS Computes post mean jump adjustments in all blocks
%of all sessions of one participant in the COINS study.

load(details.analysis.behav.responseData, 'subData');
exBlks = details.excludedBlocks;

allAdjusts = [];
volAdjusts = [];
staAdjusts = [];
allJumps = [];
volJumps = [];
staJumps = [];
allVars = [];
volVars = [];
staVars = [];
allConds = [];

for iSess = 1: details.nSessions
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        
        % deal with excluded blocks
        if ~isempty(exBlks) && ismember([iSess iBlock], exBlks, 'rows')
            allAdjustments{iSess, iBlock} = [];
            allJumpSizes{iSess, iBlock} = [];
            allVariances{iSess, iBlock} = [];
        else
        % compute adjustments after mean change
            [allAdjustments{iSess, iBlock}, allJumpSizes{iSess, iBlock}, ...
                allVariances{iSess, iBlock}] = ...
                coins_compute_blockAdjustments(blockData, options);
        end

        allAdjusts = [allAdjusts; allAdjustments{iSess,iBlock}];
        allJumps = [allJumps; allJumpSizes{iSess,iBlock}];
        allVars = [allVars; allVariances{iSess,iBlock}];
        allConds = [allConds; unique(blockData.volatility)*ones(numel(allJumpSizes{iSess,iBlock}),1)];

        if unique(blockData.volatility) == 1
            volAdjusts = [volAdjusts; allAdjustments{iSess, iBlock}];
            volJumps = [volJumps; allJumpSizes{iSess, iBlock}];
            volVars = [volVars; allVariances{iSess, iBlock}];
        else
            staAdjusts = [staAdjusts; allAdjustments{iSess, iBlock}];
            staJumps = [staJumps; allJumpSizes{iSess, iBlock}];
            staVars = [staVars; allVariances{iSess, iBlock}];
        end
    end
end
save(details.analysis.behav.adjustments, 'allAdjusts', 'allJumps', 'allVars', 'allConds');
save(details.analysis.behav.adjustmentsVolatility, ...
    'staAdjusts', 'staJumps', 'staVars', 'volAdjusts', 'volJumps', 'volVars');


% Compute average / mean adjustments for this participant (to use in group
% analysis later)
jumpSizes = unique(allJumps);
variances = unique(allVars);
variances(isnan(variances)) = [];

% using the mean
meanAdjusts = NaN(3, 4, 5, 601);
for iJmp = 1: numel(jumpSizes)
    meanAdjusts(1, 1, iJmp, :) = nanmean(allAdjusts(allJumps==jumpSizes(iJmp), :));
    meanAdjusts(2, 1, iJmp, :) = nanmean(staAdjusts(staJumps==jumpSizes(iJmp), :));
    meanAdjusts(3, 1, iJmp, :) = nanmean(volAdjusts(volJumps==jumpSizes(iJmp), :));

    for iVar = 1: numel(variances)
        meanAdjusts(1, 1+iVar, iJmp, :) = ...
            nanmean(allAdjusts(allJumps==jumpSizes(iJmp) & allVars==variances(iVar), :));
        meanAdjusts(2, 1+iVar, iJmp, :) = ...
            nanmean(staAdjusts(staJumps==jumpSizes(iJmp) & staVars==variances(iVar), :));
        meanAdjusts(3, 1+iVar, iJmp, :) = ...
            nanmean(volAdjusts(volJumps==jumpSizes(iJmp) & volVars==variances(iVar), :));
    end
end
save(details.analysis.behav.meanAdjustments, 'meanAdjusts');

% using the median
medianAdjusts = NaN(3, 4, 5, 601);
for iJmp = 1: numel(jumpSizes)
    medianAdjusts(1, 1, iJmp, :) = nanmedian(allAdjusts(allJumps==jumpSizes(iJmp), :));
    medianAdjusts(2, 1, iJmp, :) = nanmedian(staAdjusts(staJumps==jumpSizes(iJmp), :));
    medianAdjusts(3, 1, iJmp, :) = nanmedian(volAdjusts(volJumps==jumpSizes(iJmp), :));

    for iVar = 1: numel(variances)
        medianAdjusts(1, 1+iVar, iJmp, :) = ...
            nanmedian(allAdjusts(allJumps==jumpSizes(iJmp) & allVars==variances(iVar), :));
        medianAdjusts(2, 1+iVar, iJmp, :) = ...
            nanmedian(staAdjusts(staJumps==jumpSizes(iJmp) & staVars==variances(iVar), :));
        medianAdjusts(3, 1+iVar, iJmp, :) = ...
            nanmedian(volAdjusts(volJumps==jumpSizes(iJmp) & volVars==variances(iVar), :));
    end
end
save(details.analysis.behav.medianAdjustments, 'medianAdjusts');

% Plot main effects for this subject
[fh1, fh2] = coins_plot_subject_adjustments(meanAdjusts, jumpSizes, options);

savefig(fh1, details.analysis.behav.adjustVolatilityFig);
savefig(fh2, details.analysis.behav.adjustNoiseFig);

[fh1, fh2] = coins_plot_subject_adjustments(medianAdjusts, jumpSizes, options);

savefig(fh1, details.analysis.behav.adjustMedianVolatilityFig);
savefig(fh2, details.analysis.behav.adjustMedianNoiseFig);

end