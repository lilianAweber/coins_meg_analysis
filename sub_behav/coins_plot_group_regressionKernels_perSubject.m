function fh = coins_plot_group_regressionKernels_perSubject( groupKernels, nSubjects, options )
%COINS_PLOT_GROUP_REGRESSIONKERNELS_PERSUBJECT Plots the beta weights on
%evidence samples preceding responses for each individual in the COINS
%study across stable and volatile blocks and tests for differences using
%paired t-tests (no multiple comparison correction).

col = coins_colours;
offset = 0.15;
sampleOrder = -5:-1;

fh = figure;
for iSub = 1:nSubjects
    for iSamp = 1:5
        plot([sampleOrder(iSamp)-offset sampleOrder(iSamp)+offset], squeeze(groupKernels(iSub,:,iSamp)), ...
            '-', 'color', col.medNoise);
        hold on;
    end
end
for iSub = 1:nSubjects
    p1 = plot(sampleOrder-offset, squeeze(groupKernels(iSub, 1, :)), 'o', ...
        'color', col.stable, 'MarkerFaceColor',col.stable, 'MarkerSize', 8);
    p2 = plot(sampleOrder+offset, squeeze(groupKernels(iSub, 2, :)), 'o', ...
        'color', col.volatile, 'MarkerFaceColor',col.volatile, 'MarkerSize', 8);
end

for iSamp = 1:5
    h = ttest(squeeze(groupKernels(:,1,iSamp)), squeeze(groupKernels(:,2,iSamp)));
    if h
        plot(sampleOrder(iSamp), max(groupKernels(:,1,iSamp))+0.1, '*', ...
            'color', 'k', 'MarkerSize',10, 'linewidth', 1.5);
    end
end
xlim([-5.5 -0.5])
xlabel('samples to response')
ylabel('weight on decision')
legend([p1, p2], 'stable', 'volatile', 'Location','northwest', 'box', 'off');
box off
fh.Children(1).FontSize = 20;
fh.Children(2).FontSize = 16;
fh.Children(2).LineWidth = 1;

fh.Position = [1223 1425 372 391];
savefig(fh, fullfile(options.workDir, 'behav', ['n' num2str(nSubjects) ...
    '_regressionBetas_perSubject.fig']))

xlim([-3.5 -0.5])
title(['N=' num2str(nSubjects)])
fh.Children(2).FontSize = 18;
fh.Position = [1166 1404 347 335];


end