function [ fh1, fh2 ] = coins_plot_subject_adjustments( adjusts, jumpSizes, options )

pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
doNorm = options.behav.flagNormaliseAdjustments;

fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];

% meanAdjusts = NaN(3, 4, 5, 601);
% meanAdjusts(iCon, iVar, iJmp, :) - iCon=1 is all, iCon=2 is stable,
% iCon=3 is volatile; iVar=1 is all, iVar=2-4 is 3 noise levels

% Normalise adjustments: start at zero
if doNorm
    for iJmp = 1: numel(jumpSizes)
        for iCon = 1:3
            for iVar = 1:4
                adjusts(iCon, iVar, iJmp, :) = squeeze(adjusts(iCon,iVar,iJmp,:)) - squeeze(adjusts(iCon,iVar,iJmp,pre+1));
            end
        end
    end
end

% 1. Effect of volatility (no noise considered)
fh1 = figure;
pSta = plot(timeAxis, squeeze(adjusts(2,1,:,:))', 'linewidth', 2);
hold on, 
pVol = plot(timeAxis, squeeze(adjusts(3,1,:,:))', '--', 'linewidth', 2);

set(gca, 'ColorOrder', colormap(lines(5)))
for i=1:numel(jumpSizes)
    plot([0 8], [jumpSizes(i) jumpSizes(i)], 'color', [0.5 0.5 0.5]);
end
yline(0)
xline(0)
legend([pSta(end), pVol(end)], 'stable', 'volatile', ...
    'location', 'northwest', 'edgecolor', [1 1 1], 'fontsize', 11)
xlim([-1 4])
xlabel('time from change point (s)')
ylabel({'shield adjustment (rad)', 'at change points'})
title('Effect of volatility')


% 2. Effect of noise (no volatility considered)
fh2 = figure;
pLow = plot(timeAxis, squeeze(adjusts(1,2,:,:))', 'linewidth', 2);
hold on, 
pMed = plot(timeAxis, squeeze(adjusts(1,3,:,:))', '--', 'linewidth', 2);
pHigh = plot(timeAxis, squeeze(adjusts(1,4,:,:))', '-.', 'linewidth', 2);

set(gca, 'ColorOrder', colormap(lines(5)))
for i=1:numel(jumpSizes)
    plot([0 8], [jumpSizes(i) jumpSizes(i)], 'color', [0.5 0.5 0.5]);
end
yline(0)
xline(0)
legend([pLow(end), pMed(end), pHigh(end)], 'low noise', 'medium noise', 'high noise', ...
    'location', 'northwest', 'edgecolor', [1 1 1], 'fontsize', 11)
xlim([-1 4])
xlabel('time from change point (s)')
ylabel({'shield adjustment (rad)', 'at change points'})
title('Effect of noise')


