function [ fh1, fh2 ] = coins_plot_group_adjustments( avgGroupAdjusts, ...
    seGroupAdjusts, jumpSizes, options )
%COINS_PLOT_GROUP_ADJUSTMENTS Produces two figures that plot the average
%post mean jump adjustment time course across participants in the COINS
%study separately for different jump sizes and volatility/noise conditions.

pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];

col = coins_colours;

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
