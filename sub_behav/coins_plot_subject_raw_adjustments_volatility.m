function fh = coins_plot_subject_raw_adjustments_volatility( dataSta, ...
    dataVol, staJumps, volJumps, flagStat, options )

jumpSizes = [unique(staJumps) unique(staJumps)]';
jumpSizes = jumpSizes(:);

fh = figure; 
for js = 1: numel(jumpSizes)
    subplot(5, 2, js)
    if mod(js,2) == 1
        plot(dataSta(staJumps==jumpSizes(js), :)');
        hold on;
        switch flagStat
            case 'median'
                p1 = plot(nanmedian(dataSta(staJumps==jumpSizes(js), :)), ...
                    'LineWidth', 3, 'Color', 'r');
            case 'mean'
                p1 = plot(nanmean(dataSta(staJumps==jumpSizes(js), :)), ...
                    'LineWidth', 3, 'Color', 'r');
        end
        title(['stable, jumpSize=' num2str(jumpSizes(js))]);
    else
        plot(dataVol(volJumps==jumpSizes(js), :)');
        hold on;
        switch flagStat
            case 'median'
                p1 = plot(nanmedian(dataVol(volJumps==jumpSizes(js), :)), ...
                    'LineWidth', 3, 'Color', 'r');
            case 'mean'
                p1 = plot(nanmean(dataVol(volJumps==jumpSizes(js), :)), ...
                    'LineWidth', 3, 'Color', 'r');
        end    
        title(['volatile, jumpSize=' num2str(jumpSizes(js))]);
    end
    hold on; 
    xline(options.behav.adjustPreSamples);
    p2 = plot([1 options.behav.adjustPreSamples options.behav.adjustPreSamples+1 ...
        options.behav.adjustPreSamples + options.behav.adjustPostSamples], ...
        [0 0 jumpSizes(js) jumpSizes(js)], ...
        'LineWidth', 3, 'color', [0.3 0.3 0.3]);
    xlim([50 400])
    if js < 5
        ylim([-1 1])
    elseif js > 8
        ylim([-1 3])
        xlabel('samples after mean jump')
        ylabel('shield position')
        switch flagStat
            case 'median'
                legend([p2, p1], 'stim mean jump', 'median shield move')
            case 'mean'
                legend([p2, p1], 'stim mean jump', 'mean shield move')
        end
    else
        ylim([-1 2])
    end
end
