function fh = coins_plot_participant_performance( perform )


allFields = fieldnames(perform{1,1});
subFieldNames = {};
for iM = 1:numel(allFields)
    metric = allFields{iM};
    if numel(perform{1,1}.(char(metric)))==1
        subFieldNames = [subFieldNames; {metric}];
    end
end

fh = figure;
for iField = 1:numel(subFieldNames)
    [volValues, staValues, ~, p] = coins_compare_performance_across_conditions(perform, subFieldNames{iField});
    subplot(5, 6, iField)
    plot(1, volValues, 'o'); 
    hold on;
    plot(2, staValues, 'o');
    plot(1, mean(volValues), 'sk', 'MarkerFaceColor', 'k');
    plot(2, mean(staValues), 'sk', 'MarkerFaceColor', 'k');
    plot([1 2], [mean(volValues) mean(staValues)], '-k');
    if p<0.05
        plot(1.5, max([mean(volValues) mean(staValues)]), '*r');
    end
    xlabel('condition')
    xlim([0 3]);
    xticks([1 2])
    xticklabels({'volatile', 'stable'});
    ylabel(subFieldNames{iField});
    title(subFieldNames{iField})
end