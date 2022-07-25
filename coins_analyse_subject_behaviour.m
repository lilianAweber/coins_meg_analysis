function coins_analyse_subject_behaviour( subID, options )

details = coins_subjects(subID, options);
if ~exist(details.analysis.behav.folder, 'dir')
    mkdir(details.analysis.behav.folder);
end

%load(details.analysis.behav.responseData, 'subData');

subData = coins_load_subjectData(details);
save(details.analysis.behav.responseData, 'subData');

% Go through data block-wise, extract kernels and compute performance
for iSess = 1: details.nSessions
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        fh = coins_plot_blockData(blockData, options);
        savefig(fh, details.analysis.behav.blockFigures{iSess, iBlock});
        [stim{iSess, iBlock}, perform{iSess, iBlock}] = ...
            coins_compute_trackingPerformance(blockData, options);
        
        % integration kernels
        [avgKernels(iSess, iBlock, :, :), nKernels(iSess, iBlock, :)] = ...
            coins_compute_blockKernels(blockData, options);
        conditionLabels(iSess, iBlock) = unique(blockData.volatility);
        if unique(blockData.volatility)==1
            volKernels(iSess, iBlock, :, :) = avgKernels(iSess, iBlock, :, :);
            staKernels(iSess, iBlock, :, :) = NaN(size(avgKernels, 3, 4));
        else
            volKernels(iSess, iBlock, :, :) = NaN(size(avgKernels, 3, 4));
            staKernels(iSess, iBlock, :, :) = avgKernels(iSess, iBlock, :, :);
        end
    end
end
save(details.analysis.behav.performance, 'stim', 'perform');
save(details.analysis.behav.blockKernels, 'avgKernels', 'volKernels', 'staKernels');

fh = coins_plot_participant_performance(perform);
savefig(fh, details.analysis.behav.performancePlot);

% Compute number of responses (as used for the kernels)
nMoveKernels = squeeze(nKernels(:, :, 1));
nSizeKernels = squeeze(nKernels(:, :, 2));
nResponses.move = sum(sum(nMoveKernels));
nResponses.size = sum(sum(nSizeKernels));
nResponses.volatile.move = sum(sum(nMoveKernels(conditionLabels==1)));
nResponses.volatile.size = sum(sum(nSizeKernels(conditionLabels==1)));
nResponses.stable.move = sum(sum(nMoveKernels(conditionLabels==0)));
nResponses.stable.size = sum(sum(nSizeKernels(conditionLabels==0)));
save(details.analysis.behav.nResponses, 'nResponses');

% Plot volatile versus stable block kernels
fh = figure;
timeAxis = [-options.behav.kernelPreSamples : ...
    options.behav.kernelPostSamples]/options.behav.fsample;

subplot(2, 1, 1); 
% signed PEs preceding movements
plot(timeAxis, nanmean(squeeze(nanmean(volKernels(:, :, 1, :),1)),1))
hold on
plot(timeAxis, nanmean(squeeze(nanmean(staKernels(:, :, 1, :),1)),1))
xlabel('time (s) around button press')
ylabel('signed PE')
title('Average signed PEs leading up to shield movement onset')
legend(['volatile blocks (N=' num2str(nResponses.volatile.move) ')'], ...
    ['stable blocks (N=' num2str(nResponses.stable.move) ')']);

subplot(2, 1, 2); 
% abs PEs preceding size updates
plot(timeAxis, nanmean(squeeze(nanmean(volKernels(:, :, 2, :),1)),1))
hold on
plot(timeAxis, nanmean(squeeze(nanmean(staKernels(:, :, 2, :),1)),1))
xlabel('time (s) around button press')
ylabel('absolute PE')
title('Average absolute PEs leading up to shield size update')
legend(['volatile blocks (N=' num2str(nResponses.volatile.size) ')'], ...
    ['stable blocks (N=' num2str(nResponses.stable.size) ')']);

savefig(fh, details.analysis.behav.kernelConditionPlot)

% Go through data block-wise, extract adjustments
allAdjusts = [];
volAdjusts = [];
staAdjusts = [];
allJumps = [];
volJumps = [];
staJumps = [];
allVars = [];
volVars = [];
staVars = [];
for iSess = 1: details.nSessions
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        % adjustments after mean change
        [allAdjustments{iSess, iBlock}, allJumpSizes{iSess, iBlock}, allVariances{iSess, iBlock}] = ...
            coins_compute_blockAdjustments(blockData, options);
        
        allAdjusts = [allAdjusts; allAdjustments{iSess,iBlock}];
        allJumps = [allJumps; allJumpSizes{iSess,iBlock}];
        allVars = [allVars; allVariances{iSess,iBlock}];
        
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
save(details.analysis.behav.adjustments, 'allAdjusts', 'allJumps', 'allVars');
save(details.analysis.behav.adjustmentsVolatility, ...
    'staAdjusts', 'staJumps', 'staVars', 'volAdjusts', 'volJumps', 'volVars');

% Plot for the effect of volatility
scaledStaAdjusts = staAdjusts;
scaledStaAdjusts(:, options.behav.adjustPreSamples+1:options.behav.adjustPreSamples+options.behav.adjustPostSamples) = ...
    scaledStaAdjusts(:, options.behav.adjustPreSamples+1:options.behav.adjustPreSamples+options.behav.adjustPostSamples)./staJumps;
scaledVolAdjusts = volAdjusts;
scaledVolAdjusts(:, options.behav.adjustPreSamples+1:options.behav.adjustPreSamples+options.behav.adjustPostSamples) = ...
    scaledVolAdjusts(:, options.behav.adjustPreSamples+1:options.behav.adjustPreSamples+options.behav.adjustPostSamples)./volJumps;

avgScVol = nanmean(scaledVolAdjusts,1);
avgScSta = nanmean(scaledStaAdjusts,1);

timeAxis = [-options.behav.adjustPreSamples:options.behav.adjustPostSamples]./60;

fh = figure; 
plot(timeAxis,avgScSta); 
hold on, 
plot(timeAxis,avgScVol);

yline(1, '--', 'color', [0.7 0.7 0.7])
yline(0, '--', 'color', [0.7 0.7 0.7])

xlabel('time (s) relative to mean jump')
ylabel('distance from mean in units of SD of stimulus')
legend('stable blocks', 'volatile blocks')
title({'Effect of volatility on mean size adjustments', 'Mean scaled position adjustments after mean jumps'})
savefig(fh, details.analysis.behav.adjustVolatilityFig);

% Plot for the effect of jump size - native sizes
allJumpsDeg = round(allJumps*180/pi);
jumpSet = unique(round(allJumps,2));

for iJumpSize = 1: numel(jumpSet)
    adjustSet = allAdjusts(abs(allJumps-jumpSet(iJumpSize))<0.01,:);
    avgAdjust(iJumpSize, :) = nanmean(adjustSet);
end
figure; 
plot(timeAxis,avgAdjust);
hold on;
yticks(jumpSet);
yticklabels(unique(allJumpsDeg));
yline(0, '--', 'color', [0.6 0.6 0.6])
for iJump = 1:numel(jumpSet)
    plot([0 timeAxis(end)], [jumpSet(iJump) jumpSet(iJump)], '--', 'color', [0.6 0.6 0.6]);
end
xlabel('time (s) relative to mean jump')
ylabel('distance (deg) from current mean')
title('Effect of jump size on mean position adjustments')

savefig(fh, details.analysis.behav.adjustNativeJumpSizeFig);

% Plot for the effect of jump size - adjusted for start position for comparing onset
for iJumpSize = 1: numel(jumpSet)
    avgScaledAdjust(iJumpSize, :) = avgAdjust(iJumpSize, :) - avgAdjust(iJumpSize, options.behav.adjustPreSamples+1);
end

fh = figure;
subplot(1, 2, 1)
plot(timeAxis,-avgScaledAdjust.*180/pi);
yline(10, '--', 'color', [0.6 0.6 0.6])
yline(20, '--', 'color', [0.6 0.6 0.6])
yline(30, '--', 'color', [0.6 0.6 0.6])
yline(40, '--', 'color', [0.6 0.6 0.6])
yline(60, '--', 'color', [0.6 0.6 0.6])
legend('smallest', '2nd', '3rd', '4th', 'largest jump')

xlim([0 timeAxis(end)])
xlabel('time (s) relative to mean jump')
ylabel({'dist. from start position'})
title('Effect of jump size on mean position adjustments')

subplot(1, 2, 2)
plot(timeAxis,-avgScaledAdjust.*180/pi);
yline(10, '--', 'color', [0.6 0.6 0.6])
legend('smallest', '2nd', '3rd', '4th', 'largest jump')

xlim([0 1]);
ylim([-0.5 15])
xlabel('time (s) relative to mean jump')
ylabel({'dist. from start position'})
title('Zoom: Onset of adjustment')

savefig(fh, details.analysis.behav.adjustJumpSizeOnsetsFig);

% Plot for the interaction between stochasticity*jump size
% split all variables into 3 levels of stochasticity
for iJumpSize = 1: numel(jumpSet)
    adjustSetLow = allAdjusts(...
        abs(allJumps-jumpSet(iJumpSize))<0.01 ...
        & allVars<options.behav.varianceSet(2), ...
        :);
    if numel(adjustSetLow)>0
        avgAdjustLow(iJumpSize, :) = nanmean(adjustSetLow);
    else
        avgAdjustLow(iJumpSize, :) = NaN(1, size(allAdjusts,2));
    end
    adjustSetMed = allAdjusts(...
        abs(allJumps-jumpSet(iJumpSize))<0.01 ...
        & allVars>options.behav.varianceSet(1) ...
        & allVars<options.behav.varianceSet(3), ...
        :);
    if numel(adjustSetMed)>0
        avgAdjustMed(iJumpSize, :) = nanmean(adjustSetMed);
    else
        avgAdjustMed(iJumpSize, :) = NaN(1, size(allAdjusts,2));
    end
    
    adjustSetHigh = allAdjusts(...
        abs(allJumps-jumpSet(iJumpSize))<0.01 ...
        & allVars>options.behav.varianceSet(2), ...
        :);
    if numel(adjustSetHigh)>0
        avgAdjustHigh(iJumpSize, :) = nanmean(adjustSetHigh);
    else
        avgAdjustHigh(iJumpSize, :) = NaN(1, size(allAdjusts,2));
    end

end

for iJumpSize = 1: numel(jumpSet)
    avgScaledAdjustLow(iJumpSize, :) = avgAdjustLow(iJumpSize, :) - avgAdjustLow(iJumpSize, options.behav.adjustPreSamples+1);
    avgScaledAdjustMed(iJumpSize, :) = avgAdjustMed(iJumpSize, :) - avgAdjustMed(iJumpSize, options.behav.adjustPreSamples+1);
    avgScaledAdjustHigh(iJumpSize, :) = avgAdjustHigh(iJumpSize, :) - avgAdjustHigh(iJumpSize, options.behav.adjustPreSamples+1);
end

fh = figure;
for i= 1:size(avgScaledAdjustLow,1)
    subplot(1, 5, i)
    plot(timeAxis,-avgScaledAdjustLow(i, :).*180/pi);
    hold on
    plot(timeAxis,-avgScaledAdjustMed(i, :).*180/pi);
    plot(timeAxis,-avgScaledAdjustHigh(i, :).*180/pi);

    yline(0, '--', 'color', [0.6 0.6 0.6])
    legend('low', 'medium', 'high')
    xlim([0 1]);
    ylim([-1 5])
    xlabel('time (s) relative to mean jump')
    ylabel({'dist. from start position'})
end

savefig(fh, details.analysis.behav.adjustJumpSizeStochasticityFig);
end