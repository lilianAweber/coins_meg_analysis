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
%fh = coins_plot_participant_performance(perform);
%savefig(fh, details.analysis.behav.performancePlot);

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
                nKernels(iSess, iBlock, :) = zeros(2, 1);
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
    nResponses.move = sum(sum(nMoveKernels));
    nResponses.size = sum(sum(nSizeKernels));
    nResponses.volatile.move = sum(sum(nMoveKernels(conditionLabels==1)));
    nResponses.volatile.size = sum(sum(nSizeKernels(conditionLabels==1)));
    nResponses.stable.move = sum(sum(nMoveKernels(conditionLabels==0)));
    nResponses.stable.size = sum(sum(nSizeKernels(conditionLabels==0)));
    save(details.analysis.behav.nResponses, 'nResponses');
else
    load(details.analysis.behav.blockKernels, 'volKernels', 'staKernels');
    load(details.analysis.behav.nResponses, 'nResponses');
end

% Plot volatile versus stable block kernels
fh = figure;
timeAxis = [-options.behav.kernelPreSamples : ...
    options.behav.kernelPostSamples]/options.behav.fsample;

volaKerns = nanmean(squeeze(nanmean(volKernels(:, :, 1, :),1)),1);
stabKerns = nanmean(squeeze(nanmean(staKernels(:, :, 1, :),1)),1);
if options.behav.flagBaselineCorrectKernels
    volaBase = nanmean(volaKerns(1, 1:options.behav.nSamplesKernelBaseline));
    stabBase = nanmean(stabKerns(1, 1:options.behav.nSamplesKernelBaseline));
    %volaBase = max(volaKerns);
    %stabBase = max(stabKerns);
    volaKerns = volaKerns - volaBase;
    stabKerns = stabKerns - stabBase;
    %volaKerns = volaKerns/volaBase;
    %stabKerns = stabKerns/stabBase;
end    

subplot(2, 1, 1); 
% signed PEs preceding movements
plot(timeAxis, volaKerns, 'color', col.volatile)
hold on
plot(timeAxis, stabKerns, 'color', col.stable)
xlabel('time (s) around button press')
ylabel('signed PE')
yline(0)
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
%{
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
else
    load(details.analysis.behav.adjustments, 'allAdjusts', 'allJumps', 'allVars');
    load(details.analysis.behav.adjustmentsVolatility, ...
        'staAdjusts', 'staJumps', 'staVars', 'volAdjusts', 'volJumps', 'volVars');
end

% Plot for the effect of volatility
%{
scStaAdjusts = staAdjusts;
for iAdj = 1: size(staAdjusts,1)
    scStaAdjusts(iAdj, options.behav.adjustPreSamples+1:...
    options.behav.adjustPreSamples+options.behav.adjustPostSamples) = ...
    scStaAdjusts(iAdj, options.behav.adjustPreSamples+1:...
    options.behav.adjustPreSamples+options.behav.adjustPostSamples)/staJumps(iAdj);
end
    
scaledStaAdjusts(:, options.behav.adjustPreSamples:...
    options.behav.adjustPreSamples+options.behav.adjustPostSamples+1) = ...
    scaledStaAdjusts(:, options.behav.adjustPreSamples:...
    options.behav.adjustPreSamples+options.behav.adjustPostSamples+1)./staJumps;
scaledVolAdjusts = volAdjusts;
scaledVolAdjusts(:, options.behav.adjustPreSamples:...
    options.behav.adjustPreSamples+options.behav.adjustPostSamples+1) = ...
    scaledVolAdjusts(:, options.behav.adjustPreSamples:...
    options.behav.adjustPreSamples+options.behav.adjustPostSamples+1)./volJumps;

%}

scaledStaAdjusts = staAdjusts;
scaledStaAdjusts = ...
    scaledStaAdjusts./staJumps;
scaledVolAdjusts = volAdjusts;
scaledVolAdjusts = ...
    scaledVolAdjusts./volJumps;

avgScVol = nanmean(scaledVolAdjusts,1);
avgScSta = nanmean(scaledStaAdjusts,1);
semScVol = nanstd(scaledVolAdjusts, 1)/sqrt(size(scaledVolAdjusts, 1));
semScSta = nanstd(scaledStaAdjusts, 1)/sqrt(size(scaledStaAdjusts, 1));

avgVol = nanmean(volAdjusts, 1);
avgSta = nanmean(staAdjusts, 1);
semVol = nanstd(volAdjusts, 1)/sqrt(size(volAdjusts, 1));
semSta = nanstd(staAdjusts, 1)/sqrt(size(staAdjusts, 1));

timeAxis = [-options.behav.adjustPreSamples:options.behav.adjustPostSamples]./60;

fh = figure; 
plot(timeAxis,avgScSta, 'color', col.stable);
hold on, 
plot(timeAxis,avgScSta+semScSta, 'color', [0.3 0.3 1]);
plot(timeAxis,avgScSta-semScSta, 'color', [0.3 0.3 1]);
plot(timeAxis,avgScVol, 'color', col.volatile);
plot(timeAxis,avgScVol+semScVol, 'color', [1 0.3 0.3]);
plot(timeAxis,avgScVol-semScVol, 'color', [1 0.3 0.3]);

yline(1, '--', 'color', [0.6 0.6 0.6])
yline(0, '--', 'color', [0.6 0.6 0.6])
xline(0, '--', 'color', [0.6 0.6 0.6])

xlabel('time (s) relative to mean jump')
ylabel('distance from previous mean in units of mean jump')
legend('stable blocks', '+1SEM', '-1SEM', 'volatile blocks', '+1SEM', '-1SEM', 'location', 'southeast')
title({'Effect of volatility on mean size adjustments', ...
    'Mean scaled position adjustments after mean jumps'})
savefig(fh, details.analysis.behav.adjustVolatilityFig);

fh = figure; 
plot(timeAxis,avgSta, 'color', col.stable);
hold on, 
plot(timeAxis,avgSta+semSta, 'color', [0.3 0.3 1]);
plot(timeAxis,avgSta-semSta, 'color', [0.3 0.3 1]);
plot(timeAxis,avgVol, 'color', col.volatile);
plot(timeAxis,avgVol+semVol, 'color', [1 0.3 0.3]);
plot(timeAxis,avgVol-semVol, 'color', [1 0.3 0.3]);

yline(0, '--', 'color', [0.6 0.6 0.6])
xline(0, '--', 'color', [0.6 0.6 0.6])
xlabel('time (s) relative to mean jump')
ylabel('distance from previous mean in radians')
legend('stable blocks', '+1SEM', '-1SEM', 'volatile blocks', '+1SEM', '-1SEM', 'location', 'southeast')
title('Effect of volatility on mean size adjustments')
savefig(fh, details.analysis.behav.adjustVolatilityUnscaledFig);


% Plot for the effect of jump size - native sizes
allJumpsDeg = round(allJumps*180/pi);
jumpSet = unique(round(allJumps,2));

for iJumpSize = 1: numel(jumpSet)
    adjustSet = allAdjusts(abs(allJumps-jumpSet(iJumpSize))<0.01,:);
    avgAdjust(iJumpSize, :) = nanmean(adjustSet);
end

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

% Plot for the interaction between stochasticity*jump size
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

end