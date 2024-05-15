function fh = coins_plot_betaWeights_across_subjects_sessions( betas, sub2use )

col = coins_colours;
nBetas = size(betas,3);

fh = figure;
switch nBetas
    case 7
        nLin = 2;
    case 11
        nLin = 3;
    otherwise
        nLin = 2;
end
for iBet = 1: nBetas
    subplot(nLin, 4, iBet)
    for iSub = sub2use
        plot(1:4, squeeze(betas(iSub,:,iBet)), '-', 'color', col.highNoise);
        hold on
    end
    for iSes = 1:4
        p1 = plot(iSes, squeeze(betas(sub2use,iSes,iBet)), 'o', ...
            'Color', col.stable, 'MarkerFaceColor', col.stable);
        hold on
    end
end
linkaxes