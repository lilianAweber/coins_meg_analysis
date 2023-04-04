options = coins_options;

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

lineStyles = {'-', ':', '-.', '--', '-'};

% 2 separate figures for the full version
doZoom = 0;
newFigure = 1;

fh1 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(2,1,:,:)), squeeze(seGroupAdjusts(2,1,:,:)), ...
    squeeze(avgGroupAdjusts(3,1,:,:)), squeeze(seGroupAdjusts(3,1,:,:)), ...
    col.stable, col.volatile, 2, 2, 'stable', 'volatile', ...
    timeAxis, lineStyles, jumpSizes, 'Effect of volatility', doZoom, newFigure);
fh1.Position = [1399 659 618 897];

fh2 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,2,:,:)), squeeze(seGroupAdjusts(1,2,:,:)), ...
    squeeze(avgGroupAdjusts(1,4,:,:)), squeeze(seGroupAdjusts(1,4,:,:)), ...
    col.lowNoise, col.highNoise, 2, 2, 'low noise', 'high noise', ...
    timeAxis, lineStyles, jumpSizes, 'Effect of noise level', doZoom, newFigure);
fh2.Position = [1399 659 618 897];

%{
fh1 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,1,:,:)), squeeze(seGroupAdjusts(1,1,:,:)), ...
    squeeze(avgGroupAdjusts(2,1,:,:)), squeeze(seGroupAdjusts(2,1,:,:)), ...
    col.stable, col.volatile, 2, 2, 'stable, precise', 'volatile, precise', ...
    timeAxis, lineStyles, jumpSizes, 'LOW NOISE', doZoom, newFigure);

fh2 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,2,:,:)), squeeze(seGroupAdjusts(1,2,:,:)), ...
    squeeze(avgGroupAdjusts(2,2,:,:)), squeeze(seGroupAdjusts(2,2,:,:)), ...
    col.stable/2, col.volatile/2, 1, 1, 'stable, noisy', 'volatile, noisy', ...
    timeAxis, lineStyles, jumpSizes, 'HIGH NOISE', doZoom, newFigure);

fh3 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,1,:,:)), squeeze(seGroupAdjusts(1,1,:,:)), ...
    squeeze(avgGroupAdjusts(1,2,:,:)), squeeze(seGroupAdjusts(1,2,:,:)), ...
    col.stable, col.stable/2, 2, 1, 'precise, stable', 'noisy, stable', ...
    timeAxis, lineStyles, jumpSizes, 'STABLE', doZoom, newFigure);

fh4 = coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(2,1,:,:)), squeeze(seGroupAdjusts(2,1,:,:)), ...
    squeeze(avgGroupAdjusts(2,2,:,:)), squeeze(seGroupAdjusts(2,2,:,:)), ...
    col.volatile, col.volatile/2, 2, 1, 'precise, volatile', 'noisy, volatile', ...
    timeAxis, lineStyles, jumpSizes, 'VOLATILE', doZoom, newFigure);


% 1 figure for the zoomed version
doZoom = 1;
newFigure = 0;

fh = figure;
subplot(2, 2, 1);
coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,1,:,:)), squeeze(seGroupAdjusts(1,1,:,:)), ...
    squeeze(avgGroupAdjusts(2,1,:,:)), squeeze(seGroupAdjusts(2,1,:,:)), ...
    col.stable, col.volatile, 2, 2, 'stable, precise', 'volatile, precise', ...
    timeAxis, lineStyles, jumpSizes, 'LOW NOISE', doZoom, newFigure);

subplot(2, 2, 2);
coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,2,:,:)), squeeze(seGroupAdjusts(1,2,:,:)), ...
    squeeze(avgGroupAdjusts(2,2,:,:)), squeeze(seGroupAdjusts(2,2,:,:)), ...
    col.stable/2, col.volatile/2, 1, 1, 'stable, noisy', 'volatile, noisy', ...
    timeAxis, lineStyles, jumpSizes, 'HIGH NOISE', doZoom, newFigure);

subplot(2, 2, 3);
coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(1,1,:,:)), squeeze(seGroupAdjusts(1,1,:,:)), ...
    squeeze(avgGroupAdjusts(1,2,:,:)), squeeze(seGroupAdjusts(1,2,:,:)), ...
    col.stable, col.stable/2, 2, 1, 'precise, stable', 'noisy, stable', ...
    timeAxis, lineStyles, jumpSizes, 'STABLE', doZoom, newFigure);

subplot(2, 2, 4);
coins_plot_group_adjustments_errorbars(...
    squeeze(avgGroupAdjusts(2,1,:,:)), squeeze(seGroupAdjusts(2,1,:,:)), ...
    squeeze(avgGroupAdjusts(2,2,:,:)), squeeze(seGroupAdjusts(2,2,:,:)), ...
    col.volatile, col.volatile/2, 2, 1, 'precise, volatile', 'noisy, volatile', ...
    timeAxis, lineStyles, jumpSizes, 'VOLATILE', doZoom, newFigure);

fh.Position = [398 -169 635 823];
    %}
    
    
%{

fh2 = figure;
for iJmp = 1:3
    pStaPre = shadedErrorBar(timeAxis, squeeze(avgGroupAdjusts(1,1,iJmp,:))', squeeze(seGroupAdjusts(1,1,iJmp,:))',...
        'lineprops', {lineStyles{iJmp}, 'linewidth', 2, 'color', col.stable});
        %plot(timeAxis, squeeze(avgGroupAdjusts(1,1,iJmp,:))', 'LineStyle', lineStyles{iJmp}, ...
        %'linewidth', 2, 'color', col.stable);
    hold on, 
    pVolPre = shadedErrorBar(timeAxis, squeeze(avgGroupAdjusts(2,1,iJmp,:))', squeeze(seGroupAdjusts(2,1,iJmp,:))',...
        'lineprops', {lineStyles{iJmp}, 'linewidth', 2, 'color', col.volatile});
        %plot(timeAxis, squeeze(avgGroupAdjusts(2,1,iJmp,:))', 'LineStyle', lineStyles{iJmp}, ...
        %'linewidth', 2, 'color', col.volatile);
end
%set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    plot([0 8], [jumpSizes(i) jumpSizes(i)], 'color', [0.5 0.5 0.5], 'linestyle', lineStyles{i})
end
yline(0);
xline(0);
legend([pStaPre(end), pVolPre(end)], ...
    'stable, precise', 'volatile, precise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Low noise: Volatility * JumpSize - start at 0')
%xlim([-1 2])
%ylim([-0.1 0.7])

% 3. Volatility during high noise
fh3 = figure;
for iJmp = 1:3
    pStaNoi = plot(timeAxis, squeeze(avgGroupAdjusts(1,2,iJmp,:))', 'color', col.stable/1.5, ...
        'linestyle', lineStyles{iJmp}, 'linewidth', 1);
    hold on, 
    pVolNoi = plot(timeAxis, squeeze(avgGroupAdjusts(2,2,iJmp,:))', 'color', col.volatile/1.5, ...
        'linestyle', lineStyles{iJmp}, 'linewidth', 1);
end
%set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5], 'linestyle', lineStyles{i})
end
yline(0)
xline(0)
legend([pStaNoi(end), pVolNoi(end)], ...
    'stable, noisy', 'volatile, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('High noise: Volatility * JumpSize - start at 0')

% 4. Noise during low volatility
fh4 = figure;
pPreSta = plot(timeAxis, squeeze(avgGroupAdjusts(1,1,:,:))', 'linewidth', 2);
hold on, 
pNoiSta = plot(timeAxis, squeeze(avgGroupAdjusts(1,2,:,:))', 'linewidth', 1);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pPreSta(end), pNoiSta(end)], ...
    'stable, precise', 'stable, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Stable blocks: Noise * JumpSize - start at 0')

% 3. Noise during high volatility
fh5 = figure;
pPreVol = plot(timeAxis, squeeze(avgGroupAdjusts(2,1,:,:))', '--', 'linewidth', 2);
hold on, 
pNoiVol = plot(timeAxis, squeeze(avgGroupAdjusts(2,2,:,:))', '--', 'linewidth', 1);

set(gca, 'ColorOrder', colormap(lines(3)))
%jumpSizes = [20 30 40]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i), 'color', [0.5 0.5 0.5])
end
yline(0)
xline(0)
legend([pPreVol(end), pNoiVol(end)], ...
    'volatile, precise', 'volatile, noisy')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over change points)')
title('Volatile blocks: Noise * JumpSize - start at 0')

%}