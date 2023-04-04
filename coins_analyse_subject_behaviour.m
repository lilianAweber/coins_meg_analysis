function coins_analyse_subject_behaviour( subID, options )
%COINS_ANALYSE_SUBJECT_BEHAVIOUR Performs all analysis steps on single
%subject's behavioural data from the COINS MEG study.

if nargin < 2
    options = coins_options;
end
details = coins_subjects(subID, options);
if ~exist(details.analysis.behav.folder, 'dir')
    mkdir(details.analysis.behav.folder);
end
col = coins_colours;

%% Load behavioural data from csv spreadsheet
if options.behav.flagLoadData
    subData = coins_load_subjectData(details);
    save(details.analysis.behav.responseData, 'subData');
else    
    load(details.analysis.behav.responseData, 'subData');
end

%% General performance indices
if options.behav.flagPerformance
    % Go through data block-wise, extract kernels and compute performance
    for iSess = 1: details.nSessions
        for iBlock = 1: 4
            blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
            fh = coins_plot_blockData(blockData, options);
            savefig(fh, details.analysis.behav.blockFigures{iSess, iBlock});
            [stim{iSess, iBlock}, perform{iSess, iBlock}] = ...
                coins_compute_trackingPerformance(blockData, options);
        end
    end
    close all
    save(details.analysis.behav.performance, 'stim', 'perform');
else
    load(details.analysis.behav.performance, 'perform');
end

% From here on, we want to exclude faulty blocks (e.g, where participants
% fell asleep etc.)
excludedBlocks = details.excludedBlocks;

% Plot performance indices across stable and volatile conditions
for iEx = 1: size(excludedBlocks, 1)
    perform{excludedBlocks(iEx, 1), excludedBlocks(iEx, 2)} = [];
end
if options.behav.flagPerformance
    fh = coins_plot_participant_performance(perform);
    savefig(fh, details.analysis.behav.performancePlot);
    fh = coins_plot_performance_overview(perform, 'reward');
    savefig(fh, details.analysis.behav.performRewardFig);
    fh = coins_plot_performance_overview(perform, 'meanPosPE');
    savefig(fh, details.analysis.behav.performAvgPeFig);
    fh = coins_plot_performance_overview(perform, 'meanDiff2mean');
    savefig(fh, details.analysis.behav.performAvgDevFromMeanFig);
    
    close all
end

%% Integration kernels (simple averaging method)
if options.behav.flagKernels
    % Go through data block-wise, extract kernels and compute performance
    for iSess = 1: details.nSessions
        for iBlock = 1: 4
            blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
            % check whether current block is excluded
            if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
                avgKernels(iSess, iBlock, :, :) = NaN(6, options.behav.kernelPreSamples + ...
                    options.behav.kernelPostSamples + 1);
                nKernels(iSess, iBlock, :) = 0;
            else
                % compute integration kernels
                [avgKernels(iSess, iBlock, :, :), nKernels(iSess, iBlock, :)] = ...
                    coins_compute_blockKernels(blockData, options);
            end
            
            % allocate kernels to different conditions
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
    save(details.analysis.behav.blockKernels, 'avgKernels', 'nKernels', 'volKernels', 'staKernels');
    
    % Compute number of responses (as used for the kernels)
    % I think this is duplicate of what we do in the performance script
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
else
    load(details.analysis.behav.blockKernels, 'volKernels', 'staKernels');
    load(details.analysis.behav.nResponses, 'nResponses');
end

% Plot volatile versus stable block kernels
fh = coins_plot_subject_kernels_by_volatility(staKernels, volKernels, ...
    nResponses, options);
savefig(fh, details.analysis.behav.kernelConditionPlot)

%% Post mean jump adjustments
if options.behav.flagAdjustments
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
    allConds = [];
    for iSess = 1: details.nSessions
        for iBlock = 1: 4
            blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
            if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
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
else
    load(details.analysis.behav.adjustments, 'allAdjusts', 'allJumps', 'allVars');
    load(details.analysis.behav.adjustmentsVolatility, ...
        'staAdjusts', 'staJumps', 'staVars', 'volAdjusts', 'volJumps', 'volVars');
    load(details.analysis.behav.meanAdjustments, 'meanAdjusts');
    load(details.analysis.behav.medianAdjustments, 'medianAdjusts');
end



%{
is done within plotting now: normalising adjustments
for iJmp = 1: numel(jumpSizes)
    for iCon = 1:3
        for iVar = 1:numel(variances)
            normMedianAdjusts(iCon, iVar, iJmp, :) = ...
                squeeze(medianAdjusts(iCon, iVar, iJmp, :)) - ...
                squeeze(medianAdjusts(iCon, iVar ,iJmp, pre+1));
            normMeanAdjusts(iCon, iVar, iJmp, :) = ...
                squeeze(meanAdjusts(iCon, iVar, iJmp, :)) - ...
                squeeze(meanAdjusts(iCon, iVar ,iJmp, pre+1));
        end
    end
end
%}
%     medAdjustStaLo(iJmp, :) = squeeze(medianAdjusts(2,2,iJmp,:)) - squeeze(medianAdjusts(2,2,iJmp,pre+1));
%     medAdjustStaMe(iJmp, :) = squeeze(medianAdjusts(2,3,iJmp,:)) - squeeze(medianAdjusts(2,3,iJmp,pre+1));
%     medAdjustStaHi(iJmp, :) = squeeze(medianAdjusts(2,4,iJmp,:)) - squeeze(medianAdjusts(2,4,iJmp,pre+1));
%     medAdjustVolLo(iJmp, :) = squeeze(medianAdjusts(3,2,iJmp,:)) - squeeze(medianAdjusts(3,2,iJmp,pre+1));
%     medAdjustVolMe(iJmp, :) = squeeze(medianAdjusts(3,3,iJmp,:)) - squeeze(medianAdjusts(3,3,iJmp,pre+1));
%     medAdjustVolHi(iJmp, :) = squeeze(medianAdjusts(3,4,iJmp,:)) - squeeze(medianAdjusts(3,4,iJmp,pre+1));
%     
%     menAdjustStaLo(iJmp, :) = squeeze(meanAdjusts(2,2,iJmp,:)) - squeeze(meanAdjusts(2,2,iJmp,pre+1));
%     menAdjustStaMe(iJmp, :) = squeeze(meanAdjusts(2,3,iJmp,:)) - squeeze(meanAdjusts(2,3,iJmp,pre+1));
%     menAdjustStaHi(iJmp, :) = squeeze(meanAdjusts(2,4,iJmp,:)) - squeeze(meanAdjusts(2,4,iJmp,pre+1));
%     menAdjustVolLo(iJmp, :) = squeeze(meanAdjusts(3,2,iJmp,:)) - squeeze(meanAdjusts(3,2,iJmp,pre+1));
%     menAdjustVolMe(iJmp, :) = squeeze(meanAdjusts(3,3,iJmp,:)) - squeeze(meanAdjusts(3,3,iJmp,pre+1));
%     menAdjustVolHi(iJmp, :) = squeeze(meanAdjusts(3,4,iJmp,:)) - squeeze(meanAdjusts(3,4,iJmp,pre+1));
% end




%{
% Volatility (low noise)
figure; 
pSL = plot(timeAxis, menAdjustStaLo', 'linewidth', 2);
hold on, 
pVL = plot(timeAxis, menAdjustVolLo', '--', 'linewidth', 2);

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pSL(end), pVL(end)], 'stable, low noise', 'volatile, low noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('median shield position (avg over change points)')
title('Volatility (low noise) * JumpSize - start at 0')

% Volatility (medium noise)
figure; 
pSL = plot(timeAxis, menAdjustStaMe');
hold on, 
pVL = plot(timeAxis, menAdjustVolMe', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pSL(end), pVL(end)], 'stable, medium noise', 'volatile, medium noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('median shield position (avg over change points)')
title('Volatility (medium noise) * JumpSize - start at 0')

% Volatility (high noise)
figure; 
pSL = plot(timeAxis, menAdjustStaHi');
hold on, 
pVL = plot(timeAxis, menAdjustVolHi', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pSL(end), pVL(end)], 'stable, high noise', 'volatile, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('median shield position (avg over change points)')
title('Volatility (high noise) * JumpSize - start at 0')

% Noise (stable)
figure; 
pSL = plot(timeAxis, menAdjustStaLo', 'linewidth', 2);
hold on, 
pVL = plot(timeAxis, menAdjustStaHi');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pSL(end), pVL(end)], 'stable, low noise', 'stable, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('median shield position (avg over change points)')
title('Noise (stable) * JumpSize - start at 0')

% Noise (volatile)
figure; 
pSL = plot(timeAxis, menAdjustVolLo', '--', 'linewidth', 2);
hold on, 
pVL = plot(timeAxis, menAdjustVolHi', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pSL(end), pVL(end)], 'volatile, low noise', 'volatile, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('median shield position (avg over change points)')
title('Noise (volatile) * JumpSize - start at 0')


% Volatility * JumpSize - individual traces
% raw adjustments
fh = coins_plot_subject_raw_adjustments_volatility(staAdjusts, volAdjusts, ...
    staJumps, volJumps, 'mean', options);
fh = coins_plot_subject_raw_adjustments_volatility(staAdjusts, volAdjusts, ...
    staJumps, volJumps, 'median', options);
% normalised for start position for comparing onset
normStaAdjusts = staAdjusts;
for iJump = 1: size(staAdjusts, 1)
    normStaAdjusts(iJump, :) = normStaAdjusts(iJump, :) - ...
        normStaAdjusts(iJump, options.behav.adjustPreSamples);
end
normVolAdjusts = volAdjusts;
for iJump = 1: size(volAdjusts, 1)
    normVolAdjusts(iJump, :) = normVolAdjusts(iJump, :) - ...
        normVolAdjusts(iJump, options.behav.adjustPreSamples);
end

fh = coins_plot_subject_raw_adjustments_volatility(normStaAdjusts, ...
    normVolAdjusts, staJumps, volJumps, 'mean', options);
fh = coins_plot_subject_raw_adjustments_volatility(normStaAdjusts, ...
    normVolAdjusts, staJumps, volJumps, 'median', options);
%}

%{
% Main effect of volatility - average across traces and jumpSizes
fh = coins_plot_subject_adjustments_volatility(staAdjusts, volAdjusts, ...
    false, options);
savefig(fh, details.analysis.behav.adjustVolatilityUnscaledFig);

% normalised for jump size
scaledStaAdjusts = staAdjusts;
scaledStaAdjusts = ...
    scaledStaAdjusts./staJumps;
scaledVolAdjusts = volAdjusts;
scaledVolAdjusts = ...
    scaledVolAdjusts./volJumps;

fh = coins_plot_subject_adjustments_volatility(scaledStaAdjusts, scaledVolAdjusts, ...
    true, options);
savefig(fh, details.analysis.behav.adjustVolatilityFig);


% Main effect of jump size - native sizes
allJumpsDeg = round(allJumps*180/pi);
jumpSet = unique(round(allJumps,2));

for iJumpSize = 1: numel(jumpSet)
    adjustSet = allAdjusts(abs(allJumps-jumpSet(iJumpSize))<0.01,:);
    avgAdjust(iJumpSize, :) = nanmean(adjustSet);
end
timeAxis = [-options.behav.adjustPreSamples:options.behav.adjustPostSamples]./options.behav.fsample;

fh = figure;
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
avgScaledAdjust = avgAdjust;
for iJumpSize = 1: numel(jumpSet)
    avgScaledAdjust(iJumpSize, :) = ...
    avgAdjust(iJumpSize, :) - ...
    avgAdjust(iJumpSize, options.behav.adjustPreSamples+1);
end

fh = figure;
subplot(1, 2, 1)
plot(timeAxis,avgScaledAdjust.*180/pi);
yline(10, '--', 'color', [0.6 0.6 0.6])
yline(20, '--', 'color', [0.6 0.6 0.6])
yline(30, '--', 'color', [0.6 0.6 0.6])
yline(40, '--', 'color', [0.6 0.6 0.6])
yline(60, '--', 'color', [0.6 0.6 0.6])
legend('smallest', '2nd', '3rd', '4th', 'largest jump')

%xlim([0 timeAxis(end)])
xlabel('time (s) relative to mean jump')
ylabel({'dist. from start position'})
title('Effect of jump size on mean position adjustments')

subplot(1, 2, 2)
plot(timeAxis,avgScaledAdjust.*180/pi);
yline(10, '--', 'color', [0.6 0.6 0.6])
legend('smallest', '2nd', '3rd', '4th', 'largest jump')

xlim([0 2]);
ylim([-2 15])
xlabel('time (s) relative to mean jump')
ylabel({'dist. from start position'})
title('Zoom: Onset of adjustment')

savefig(fh, details.analysis.behav.adjustJumpSizeOnsetsFig);

% Interaction between stochasticity*jump size
% split all variables into 3 levels of stochasticity
for iJumpSize = 1: numel(jumpSet)
    adjustSetLow = allAdjusts(...
        abs(allJumps-jumpSet(iJumpSize))<0.01 ...
        & allVars<options.behav.varianceSet(2), ...
        :);
    %size(adjustSetLow, 1)
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
    %size(adjustSetMed, 1)
    if numel(adjustSetMed)>0
        avgAdjustMed(iJumpSize, :) = nanmean(adjustSetMed);
    else
        avgAdjustMed(iJumpSize, :) = NaN(1, size(allAdjusts,2));
    end
    
    adjustSetHigh = allAdjusts(...
        abs(allJumps-jumpSet(iJumpSize))<0.01 ...
        & allVars>options.behav.varianceSet(2), ...
        :);
    %size(adjustSetHigh, 1)
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
jumpSetDegree = round(jumpSet*180/pi);
for i= 1:size(avgAdjustLow,1)
    subplot(1, 5, i)
    plot(timeAxis,avgAdjustLow(i, :).*180/pi);
    hold on
    plot(timeAxis,avgAdjustMed(i, :).*180/pi);
    plot(timeAxis,avgAdjustHigh(i, :).*180/pi);

    yline(jumpSetDegree(i), '--', 'color', [0.6 0.6 0.6]);
    yline(0, '--', 'color', [0.6 0.6 0.6])
    xline(0, '--', 'color', [0.6 0.6 0.6])
    legend('low', 'medium', 'high')
    %xlim([0 1]);
    ylim([-10 jumpSetDegree(i)+10])
    xlabel('time (s) relative to mean jump')
    ylabel({'dist. from previous mean'})
end

fh = figure;
for i= 1:size(avgScaledAdjustLow,1)
    subplot(1, 5, i)
    plot(timeAxis,avgScaledAdjustLow(i, :).*180/pi);
    hold on
    plot(timeAxis,avgScaledAdjustMed(i, :).*180/pi);
    plot(timeAxis,avgScaledAdjustHigh(i, :).*180/pi);

    yline(jumpSetDegree(i), '--', 'color', [0.6 0.6 0.6]);
    yline(0, '--', 'color', [0.6 0.6 0.6])
    xline(0, '--', 'color', [0.6 0.6 0.6])
    legend('low', 'medium', 'high')
    %xlim([0 1]);
    ylim([-10 jumpSetDegree(i)+10])
    xlabel('time (s) relative to mean jump')
    ylabel({'dist. from start position'})
end

savefig(fh, details.analysis.behav.adjustJumpSizeStochasticityFig);


% Plot for the interaction between volatility*jump size
for iJumpSize = 1: numel(jumpSet)
    adjustSetSta = staAdjusts(...
        abs(staJumps-jumpSet(iJumpSize))<0.01, :);
    if numel(adjustSetSta)>0
        avgAdjustSta(iJumpSize, :) = nanmean(adjustSetSta);
    else
        avgAdjustSta(iJumpSize, :) = NaN(1, size(allAdjusts,2));
    end
    adjustSetVol = volAdjusts(...
        abs(volJumps-jumpSet(iJumpSize))<0.01, :);
    if numel(adjustSetVol)>0
        avgAdjustVol(iJumpSize, :) = nanmean(adjustSetVol);
    else
        avgAdjustVol(iJumpSize, :) = NaN(1, size(allAdjusts,2));
    end
end

for iJumpSize = 1: numel(jumpSet)
    avgScaledAdjustSta(iJumpSize, :) = avgAdjustSta(iJumpSize, :) - avgAdjustSta(iJumpSize, options.behav.adjustPreSamples+1);
    avgScaledAdjustVol(iJumpSize, :) = avgAdjustVol(iJumpSize, :) - avgAdjustVol(iJumpSize, options.behav.adjustPreSamples+1);
end

fh = figure;
for i= 1:size(avgScaledAdjustSta,1)
    subplot(1, 5, i)
    plot(timeAxis,avgScaledAdjustSta(i, :).*180/pi);
    hold on
    plot(timeAxis,avgScaledAdjustVol(i, :).*180/pi);

    yline(jumpSetDegree(i), '--', 'color', [0.6 0.6 0.6]);
    yline(0, '--', 'color', [0.6 0.6 0.6])
    xline(0, '--', 'color', [0.6 0.6 0.6])
    legend('stable', 'volatile')
    %xlim([0 1]);
    ylim([-10 jumpSetDegree(i)+10])
    xlabel('time (s) relative to mean jump')
    ylabel({'dist. from start position'})
end
savefig(fh, details.analysis.behav.adjustJumpSizeVolatilityFig);

%}
%% Post mean jump reaction times
if options.behav.flagReactionTimes
    coins_analyse_subject_reactionTimes( subID, options );
end

end