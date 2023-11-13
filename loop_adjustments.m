options = coins_options;
resultsDir = fullfile(options.workDir, 'behav');

pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
doNorm = options.behav.flagNormaliseAdjustments;

fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];

col = coins_colours;

for iSub = 1: numel(options.subjectIDs)
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.meanAdjustments, 'meanAdjusts');
    groupAdjusts(iSub, :, :, :, :) = meanAdjusts;
end
load(details.analysis.behav.adjustments, 'allJumps');
jumpSizes = unique(allJumps);

% Normalise adjustments: start at zero
if doNorm
    for iSub = 1: numel(options.subjectIDs)
        for iJmp = 1: numel(jumpSizes)
            for iCon = 1:3
                for iVar = 1:4
                    groupAdjusts(iSub, iCon, iVar, iJmp, :) = ...
                        squeeze(groupAdjusts(iSub,iCon,iVar,iJmp,:)) - ...
                        squeeze(groupAdjusts(iSub,iCon,iVar,iJmp,pre+1));
                end
            end
        end     
    end
end

avgGroupAdjusts = squeeze(mean(groupAdjusts,1));
seGroupAdjusts = squeeze(std(groupAdjusts,1)./sqrt(size(groupAdjusts,1)));

save(fullfile(resultsDir, 'groupAdjustments.mat'), "groupAdjusts", ...
    "avgGroupAdjusts", "seGroupAdjusts", "timeAxis", "jumpSizes");

%% Plot average adjustment time courses
lineStyles = {'-', ':', '-.', '--', '-'};

% 2 separate figures for the full version
doZoom = 0;
newFigure = 1;

fh1 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(2,1,:,:)), squeeze(seGroupAdjusts(2,1,:,:)), ...
    squeeze(avgGroupAdjusts(3,1,:,:)), squeeze(seGroupAdjusts(3,1,:,:)), ...
    col.stable, col.volatile, 3, 3, 'stable', 'volatile', ...
    timeAxis, lineStyles, jumpSizes, 'Effect of volatility', doZoom, newFigure);
fh1.Children(2).FontSize = 16;
fh1.Children(1).FontSize = 16;
fh1.Children(2).LineWidth = 1;
fh1.Position = [196 396 428 381];

fh2 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,2,:,:)), squeeze(seGroupAdjusts(1,2,:,:)), ...
    squeeze(avgGroupAdjusts(1,4,:,:)), squeeze(seGroupAdjusts(1,4,:,:)), ...
    col.lowNoise, col.highNoise, 3, 3, 'low noise', 'high noise', ...
    timeAxis, lineStyles, jumpSizes, 'Effect of noise level', doZoom, newFigure);
fh2.Children(2).FontSize = 16;
fh2.Children(1).FontSize = 16;
fh2.Children(2).LineWidth = 1;
fh2.Position = [196 396 428 381];

savefig(fh1, fullfile(resultsDir, 'adjustment_timecourse_volatility.fig'));
savefig(fh2, fullfile(resultsDir, 'adjustment_timecourse_noise.fig'));

%% Determine RTs
halfJumps = jumpSizes/2;
% remove time before jump
allAdjusts = groupAdjusts(:,:,:,:,101:end);
allTimes = timeAxis(101:end);
for iSub = 1: numel(options.subjectIDs)
    for iJmp = 1: numel(jumpSizes)
        for iCon = 1:3
            for iVar = 1:4
                adjustData = squeeze(allAdjusts(iSub, iCon, iVar, iJmp, :));
                
                rt = allTimes(adjustData>=halfJumps(iJmp));
                adjustRTs(iSub, iCon, iVar, iJmp) = rt(1);
            end
        end
    end     
end
save(fullfile(resultsDir, 'groupAdjustment_RTs.mat'), "adjustRTs");

%% Linear mixed models for RTs
% For analysis of RTs, we only want correct responses
dataRTs = adjustRTs(:,[2:3],[2:4],:);
[nSubjects, nConditions, nVariances, nJumps] = size(dataRTs);

t1 = table;
% dependent variable
t1.RT = dataRTs(:);
% predictors
t1.volatility = repmat(repmat([-0.5*ones(nSubjects,1); 0.5*ones(nSubjects,1)],nVariances,1),nJumps,1);
t1.noise = repmat([repmat(-ones(nSubjects,1),nConditions,1); ...
    repmat(zeros(nSubjects,1),nConditions,1); ...
    repmat(ones(nSubjects,1),nConditions,1)], nJumps,1);
t1.jumpSize = [repmat(-2*ones(nSubjects,1),nConditions*nVariances,1); ...
    repmat(-ones(nSubjects,1),nConditions*nVariances,1); ...
    repmat(zeros(nSubjects,1),nConditions*nVariances,1); ...
    repmat(ones(nSubjects,1),nConditions*nVariances,1); ...
    repmat(2*ones(nSubjects,1),nConditions*nVariances,1)];
% subject identifier
t1.ID = repmat([1:22]',nConditions*nVariances*nJumps,1);

modelRT = ['RT ~ jumpSize*volatility*noise']; ...
    %'+ (jumpSize*volatility*noise |ID)'];
fit1 = fitlme(t1, modelRT);
save(fullfile(resultsDir, 'reactionTimes_linearModel.mat'), 'fit1')

% Plot some results for this
[beta,betanames,stats] = fixedEffects(fit1);
fh = figure; 
errorbar(1:8,beta,stats.SE,"s", 'linewidth', 4, "MarkerSize",15,...
    "MarkerEdgeColor","blue","MarkerFaceColor",[0.65 0.85 0.90], 'CapSize', 0);
yline(0, '-k','LineWidth',1);
hold on
for i=1:8
    if stats.pValue(i) < 0.05
        plot(i, 0.25, '*k', 'LineWidth',1, 'MarkerSize',10);
    end
end
ylim([-0.4 0.35])
xticklabels(betanames.Name);
xtickangle(45)
xlim([1.5 8.5])
xlabel('predictors')
ylabel('beta')
title('Reaction times (fixed effects)')
box off
fh.Children.LineWidth = 1;
fh.Children.FontSize = 16;
%fh.Children.FontWeight = 'bold';
savefig(fh, fullfile(resultsDir, 'reactionTimes_betas.fig'));

%% Plot RTs
% Average volatility effect (split by jump size)
volDataRTs = squeeze(mean(dataRTs,3));

fh = figure; 
for iJmp = 1:5
    for iSub = 1: nSubjects
        plot([iJmp-0.1 iJmp+0.1], ...
            [squeeze(volDataRTs(iSub,1,iJmp)) ...
            squeeze(volDataRTs(iSub,2,iJmp))], ...
            '-', 'Color', col.highNoise, 'linewidth',1);
        hold on
    end
    p1 = plot(iJmp-0.1, squeeze(volDataRTs(:,1,iJmp)), 'o', ...
        'Color', col.stable, 'MarkerFaceColor', col.stable, 'MarkerSize',8);
    p2 = plot(iJmp+0.1, squeeze(volDataRTs(:,2,iJmp)), 'o', ...
        'Color', col.volatile, 'MarkerFaceColor', col.volatile, 'MarkerSize',8);
end
legend([p1(end), p2(end)], 'stable', 'volatile')
ylabel('RT (s) to reach half-way')
xticks(1:5)
xlabel('Jump size')
title('Reaction times: Volatility x Jump Size')
box off
fh.Children(2).LineWidth = 1;
fh.Children(2).FontSize = 16;
%fh.Children(2).FontWeight = 'bold';
fh.Children(1).FontSize = 16;
savefig(fh, fullfile(resultsDir, 'reactionTimes_volatility_jumpSize.fig'));

% Average volatility effect (not split by jump size)
volAvgRTs = squeeze(mean(volDataRTs,3));

fh = figure; 
for iSub = 1: nSubjects
    plot([0.9 1.1], ...
        [squeeze(volAvgRTs(iSub,1)) ...
        squeeze(volAvgRTs(iSub,2))], ...
        '-', 'Color', col.highNoise, 'linewidth',1);
    hold on
end
v1 = plot(0.9, squeeze(volAvgRTs(:,1)), 'o', ...
    'Color', col.stable, 'MarkerFaceColor', col.stable, 'MarkerSize',8);
v2 = plot(1.1, squeeze(volAvgRTs(:,2)), 'o', ...
    'Color', col.volatile, 'MarkerFaceColor', col.volatile, 'MarkerSize',8);
legend([v1(end), v2(end)], 'stable', 'volatile')
ylabel('RT (s) to reach half-way')
xlim([0.8 1.2])
xticks([])
title({'Reaction times: Effect of Volatility', 'averaging over jump size and noise'})
box off
fh.Children(2).LineWidth = 1;
fh.Children(2).FontSize = 16;
%fh.Children(2).FontWeight = 'bold';
fh.Children(1).FontSize = 16;
savefig(fh, fullfile(resultsDir, 'reactionTimes_volatility.fig'));

% Average noise effect (split by jump size)
noiDataRTs = squeeze(mean(dataRTs,2));

fh = figure;
for iJmp = 1:5
    for iSub = 1: nSubjects
        plot([iJmp-0.2 iJmp iJmp+0.2], ...
            [squeeze(noiDataRTs(iSub,1,iJmp)) ...
            squeeze(noiDataRTs(iSub,2,iJmp)) ...
            squeeze(noiDataRTs(iSub,3,iJmp))], ...
            '-', 'Color', col.highNoise, 'linewidth',1);
        hold on
    end
    p1 = plot(iJmp-0.2, squeeze(noiDataRTs(:,1,iJmp)), 'o', ...
        'Color', col.lowNoise, 'MarkerFaceColor', col.lowNoise, 'MarkerSize',8);
    p2 = plot(iJmp, squeeze(noiDataRTs(:,2,iJmp)), 'o', ...
        'Color', col.medNoise, 'MarkerFaceColor', col.medNoise, 'MarkerSize',8);
    p3 = plot(iJmp+0.2, squeeze(noiDataRTs(:,3,iJmp)), 'o', ...
        'Color', col.highNoise, 'MarkerFaceColor', col.highNoise, 'MarkerSize',8);
end
legend([p1(end), p2(end), p3(end)], 'low noise', 'medium noise', 'high noise')
ylabel('RT (s) to reach half-way')
xticks(1:5)
xlabel('Jump size')
title('Reaction times: Noise x Jump Size')
box off
fh.Children(2).LineWidth = 1;
fh.Children(2).FontSize = 16;
%fh.Children(2).FontWeight = 'bold';
fh.Children(1).FontSize = 16;
savefig(fh, fullfile(resultsDir, 'reactionTimes_noise.fig'));

% Interaction volatility x noise
intDataRTs = squeeze(mean(dataRTs,4));

fh = figure; 
for iVar = 1:3
    for iSub = 1: nSubjects
        plot([iVar-0.1 iVar+0.1], ...
            [squeeze(intDataRTs(iSub,1,iVar)) ...
            squeeze(intDataRTs(iSub,2,iVar))], ...
            '-', 'Color', col.highNoise, 'linewidth',1);
        hold on
    end
    i1 = plot(iVar-0.1, squeeze(intDataRTs(:,1,iVar)), 'o', ...
        'Color', col.stable, 'MarkerFaceColor', col.stable, 'MarkerSize',8);
    i2 = plot(iVar+0.1, squeeze(intDataRTs(:,2,iVar)), 'o', ...
        'Color', col.volatile, 'MarkerFaceColor', col.volatile, 'MarkerSize',8);
end
legend([i1(end), i2(end)], 'stable', 'volatile')
ylabel('RT (s) to reach half-way')
xticks(1:3)
xlabel('Noise level')
xticklabels({'Low', 'Medium', 'High'})
title('Reaction times: Volatility x Noise')
box off
fh.Children(2).LineWidth = 1;
fh.Children(2).FontSize = 16;
%fh.Children(2).FontWeight = 'bold';
fh.Children(1).FontSize = 16;
savefig(fh, fullfile(resultsDir, 'reactionTimes_noise_volatility.fig'));