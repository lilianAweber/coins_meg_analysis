function fh = coins_plot_blockData( blockData, options )

if nargin < 2
    options = coins_options;
end

%fields_to_workspace(table2struct(blockData)); 

predictionError = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
absPE = abs(predictionError);

nSamples = numel(absPE);
Fs = options.behav.fsample;
timeIdx = [1:nSamples]/Fs/60;

if unique(blockData.volatility)==1
    con = 'VOLATILE';
else
    con = 'STABLE';
end

fh = figure;
subplot(2, 1, 1);
title({['session' num2str(unique(blockData.sessID)) ', block' num2str(unique(blockData.blockID))], ['Tracking performance: ' con ' block']})
shadedErrorBar(timeIdx, mod(blockData.shieldRotation,360), 0.5*blockData.shieldDegrees);
hold on;
plot(timeIdx, blockData.laserRotation, 'color', [0.6 0 0]);
plot(timeIdx, blockData.trueMean, '--', 'linewidth', 3, 'color', [1 0.2 0.2]);
legend('shield position +/- width', 'laser location', 'true mean')
xlabel('Time (min) across block')
ylabel('location in degrees');

subplot(2, 1, 2);
plot(timeIdx, absPE, 'color', [0 0 0.6]); hold on;
plot(timeIdx, 0.5*blockData.shieldDegrees, 'k', 'linewidth', 2);
plot(timeIdx, blockData.trueVariance, '--', 'color', [0.2 0.2 1], 'linewidth', 3);
title('Absolute prediction error and shield size over time');
xlabel('Time (min) across block');
ylabel('Degrees');
legend({'abs PE' 'shield size', 'true variance'});
box off;

end