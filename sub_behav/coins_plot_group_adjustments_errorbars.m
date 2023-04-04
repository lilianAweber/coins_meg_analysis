function fh = coins_plot_group_adjustments_errorbars( data1, err1, data2, err2, ...
    col1, col2, lw1, lw2, label1, label2, timeAxis, lineStyles, jumpSizes, titleStr, ...
    doZoom, newFigure )

if newFigure
    fh = figure;
end
for iJmp = 1:numel(jumpSizes)
    p1(iJmp) = shadedErrorBar(timeAxis, data1(iJmp,:)', err1(iJmp,:)', ...
        'lineprops', {lineStyles{iJmp}, 'linewidth', lw1, 'color', col1});
    hold on, 
    p2(iJmp) = shadedErrorBar(timeAxis, data2(iJmp,:)', err2(iJmp,:)', ...
        'lineprops', {lineStyles{iJmp}, 'linewidth', lw2, 'color', col2});
end
for i=1:numel(jumpSizes)
    plot([0 8], [jumpSizes(i) jumpSizes(i)], 'color', [0.5 0.5 0.5], ...
        'linestyle', lineStyles{i})
end
yline(0)
xline(0)
legend([p1(end).mainLine, p2(end).mainLine], {label1, label2}, ...
    'location', 'northwest', 'edgecolor', [1 1 1], 'fontsize', 11)
xlim([-1 5])
xlabel('time from change point (s)')
ylabel({'shield adjustment (rad)', 'at change points'})
title(titleStr)

if doZoom
    xlim([0 2])
    ylim([-0.1 0.6])
end


end