function fh = coins_plot_group_regressionKernels( avgGroupKernels, seGroupKernels, nSubjects, options )
%COINS_PLOT_GROUP_REGRESSIONKERNELS Plots beta weights of evidence samples
%prior to shield movement across all participants in the COINS study.

col = coins_colours;
timeAxis = [-options.behav.kernelPreSamplesEvi:-1];

fh = figure; 
shadedErrorBar(timeAxis, squeeze(avgGroupKernels(1,:)), ...
    squeeze(seGroupKernels(1,:)), 'lineprops', ...
    {'-', 'color', col.stable, 'linewidth', 4});
hold on
shadedErrorBar(timeAxis, squeeze(avgGroupKernels(2,:)), ...
    squeeze(seGroupKernels(2,:)), 'lineprops', ...
    {'-', 'color', col.volatile, 'linewidth', 4});

xlabel('samples preceding movement')
ylabel('weight on decision')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
xlim([-5 -1]);
legend('stable', 'volatile', ...
        'location', 'northwest', 'edgecolor', [1 1 1])
title(['N=' num2str(nSubjects)])
box off

fh.Children(1).FontSize = 16;
fh.Children(2).FontSize = 16;
fh.Children(2).LineWidth = 1;

fh.Position = [832 456 372 391];

end