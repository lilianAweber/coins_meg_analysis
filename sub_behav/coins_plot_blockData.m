function fh = coins_plot_blockData( blockData, options )

if nargin < 2
    options = coins_options;
end

shield = unwrap(blockData.shieldRotation*pi/180); 
laser = unwrap(blockData.laserRotation*pi/180);
shieldDegrees = blockData.shieldDegrees*pi/180;
trueMean = unwrap(blockData.trueMean*pi/180);
trueVariance = blockData.trueVariance*pi/180;

if sum(abs(shield-laser)) > sum(abs(shield-(laser+2*pi)))
    laser = laser + 2*pi;
    trueMean = trueMean + 2*pi;
end

if sum(abs(shield-trueMean)) > sum(abs(shield-(trueMean+2*pi)))
    trueMean = trueMean + 2*pi;
end

%predictionError = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
predictionError = laser-shield;
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
shadedErrorBar(timeIdx, shield, 0.5*shieldDegrees);
hold on;
plot(timeIdx, laser, 'color', [0.6 0 0]);
plot(timeIdx, trueMean, '--', 'linewidth', 3, 'color', [1 0.2 0.2]);
legend('shield position +/- width', 'laser location', 'true mean')
xlabel('Time (min) across block')
ylabel('location in radians');

subplot(2, 1, 2);
plot(timeIdx, absPE, 'color', [0 0 0.6]); hold on;
plot(timeIdx, 0.5*shieldDegrees, 'k', 'linewidth', 2);
plot(timeIdx, trueVariance, '--', 'color', [0.2 0.2 1], 'linewidth', 3);
title('Absolute prediction error and shield size over time');
xlabel('Time (min) across block');
ylabel('Radians');
legend({'abs PE' 'shield size', 'true variance'});
box off;

end