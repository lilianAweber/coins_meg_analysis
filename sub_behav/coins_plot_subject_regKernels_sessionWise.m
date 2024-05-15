function fh = coins_plot_subject_regKernels_sessionWise( volBetas, staBetas )

nBetas = size(volBetas,2);
col = coins_colours;

fh = figure;
for iBet = 1:nBetas
    for iSub = 1: size(volBetas,1)
        plot([iBet-0.2 iBet+0.2], [staBetas(iSub,iBet) volBetas(iSub,iBet)], ...
            '-', 'color', col.highNoise);
        hold on
    end
    yline(0);
    p1 = plot(iBet-0.2, squeeze(staBetas(:,iBet)), 'o', ...
        'Color', col.stable, 'MarkerFaceColor', col.stable);
    p2 = plot(iBet+0.2, squeeze(volBetas(:,iBet)), 'o', ...
        'Color', col.volatile, 'MarkerFaceColor', col.volatile);
end
xticks(1:nBetas);
switch nBetas
    case 11
        xticklabels({'-5', '-4', '-3', '-2', '-1', ...
            'noise', ...
            'noise*(-5)', 'noise*(-4)', 'noise*(-3)', 'noise*(-2)', 'noise*(-1)'});
    case 7
        xticklabels({'-3', '-2', '-1', ...
            'noise', ...
            'noise*(-3)', 'noise*(-2)', 'noise*(-1)'});
end
ylabel('weight on response')
xlabel('regressor')
legend([p1(end), p2(end)], {'stable', 'volatile'}, 'box', 'off')
title(['betas: ' num2str(nBetas) ' regressors'])
box off
fh.Children(2).LineWidth =1;
fh.Children(2).FontSize = 14;
fh.Children(1).FontSize = 14;
