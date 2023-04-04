function fh = coins_plot_subject_adjustments_volatility( staAdjusts, volAdjusts, ...
    flagNormalise, options )

col = coins_colours;

avgVol = nanmean(volAdjusts,1);
avgSta = nanmean(staAdjusts,1);
semVol = nanstd(volAdjusts, 1)/sqrt(size(volAdjusts, 1));
semSta = nanstd(staAdjusts, 1)/sqrt(size(staAdjusts, 1));

timeAxis = [-options.behav.adjustPreSamples:options.behav.adjustPostSamples]./options.behav.fsample;

fh = figure; 
plot(timeAxis,avgSta, 'color', col.stable);
hold on, 
plot(timeAxis,avgSta+semSta, 'color', [0.3 0.3 1]);
plot(timeAxis,avgSta-semSta, 'color', [0.3 0.3 1]);
plot(timeAxis,avgVol, 'color', col.volatile);
plot(timeAxis,avgVol+semVol, 'color', [1 0.3 0.3]);
plot(timeAxis,avgVol-semVol, 'color', [1 0.3 0.3]);

yline(1, '--', 'color', [0.6 0.6 0.6])
yline(0, '--', 'color', [0.6 0.6 0.6])
xline(0, '--', 'color', [0.6 0.6 0.6])

xlabel('time (s) relative to mean jump')
ylabel('distance from previous mean in units of mean jump')
legend('stable blocks', '+1SEM', '-1SEM', 'volatile blocks', '+1SEM', '-1SEM', 'location', 'southeast')
if flagNormalise
    title({'Effect of volatility on mean size adjustments', ...
        'Mean position adjustments after mean jumps, normalised for jump size'})
else
    title({'Effect of volatility on mean size adjustments', ...
        'Mean position adjustments after mean jumps'})
end

end