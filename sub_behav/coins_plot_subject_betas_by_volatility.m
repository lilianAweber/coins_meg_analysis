function fh = coins_plot_subject_betas_by_volatility( betasCon, ...
    nTrialsCon, options )

col = coins_colours;

timeAxis = [-options.behav.kernelPreSamplesEvi:-1];
xLblStr = 'evidence samples'; yLblStr = 'avg weight on decision';
tStr = 'Avg weight of evidence samples';
volaKerns = squeeze(nanmean(betasCon{2},1));
stabKerns = squeeze(nanmean(betasCon{1},1));

% plotting
fh = figure;

plot(timeAxis, volaKerns, 'color', col.volatile);
hold on
plot(timeAxis, stabKerns, 'color', col.stable);

xlabel([xLblStr 'leading up to button press']);
ylabel(yLblStr);
yline(0, 'color', col.medNoise);

title({[tStr ' leading up to shield movement onset'], 'low noise blocks'})
legend(['volatile blocks (N=' num2str(sum(nTrialsCon{2})) ')'], ...
    ['stable blocks (N=' num2str(sum(nTrialsCon{1})) ')'], 'location', 'northwest');
box off;
ax1 = gca;
ax1.LineWidth = 1;


end
