function [ fh ] = coins_plot_performance_overview( perform, fieldName )

col = coins_colours;
plotCols{1} = [col.stable; col.stable/2];
plotCols{2} = [col.volatile; col.volatile/2];

% collect block values
data = cell(2,1);
for iSes = 1:size(perform,1)
    for iBlock = 1: size(perform,2)
        if ~isempty(perform{iSes, iBlock})
            data{perform{iSes, iBlock}.volatility+1} = ...
                [data{perform{iSes, iBlock}.volatility+1} ...
                perform{iSes, iBlock}.(fieldName)];
        end
    end
end

nBlocks = max(numel(data{1}),numel(data{2}));
fh = figure;
for iVol = 1:2
    for iSes = 1: numel(data{iVol})
        ph(iVol) = plot(iSes, data{iVol}(iSes), 'o', ...
            'color', plotCols{iVol}(1, :), ...
            'MarkerFaceColor', plotCols{iVol}(1, :));
        hold on
    end
    plot(1:iSes, data{iVol}, '--', 'color', plotCols{iVol}(1, :));
end
if ~strcmp(fieldName, 'reward')
    yline(0.1745)
end
legend([ph(1) ph(2)], 'stable', 'volatile');
xlim([0.5 nBlocks+0.5])
xticks(1:nBlocks)
xlabel('block')
ylabel(fieldName)
title([fieldName ' across blocks'])

end