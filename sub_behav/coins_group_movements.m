function coins_group_movements( options )

subjectIDs = [1 2 3 4 5 6 7 8 9];




% Collect all movements
for iSubj = 1: numel(subjectIDs)
    
    details = coins_subjects(subjectIDs(iSubj), options);
    load(details.analysis.behav.medianAdjustments, 'medianAdjusts');
    
    medAdjusts(iSubj, :, :, :, :) = medianAdjusts;
end

% Collect all movements
for iSubj = 1: numel(subjectIDs)
    
    details = coins_subjects(subjectIDs(iSubj), options);
    load(details.analysis.behav.meanAdjustments, 'meanAdjusts');
    
    medAdjusts(iSubj, :, :, :, :) = meanAdjusts;
end

pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];
jumpSizes = [10 20 30 40 60]*pi/180;

% Effect of noise - raw
figure; 

pL = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,1,2,:,:))))', 'linewidth', 2);
hold on, 
pM = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,1,3,:,:))))');
hold on, 
pH = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,1,4,:,:))))', '--');

set(gca,'ColorOrder',colormap(lines(5)))
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('median shield position (avg over participants)')
title('Stochasticity * JumpSize')

% Effect of noise - normalised
for iJmp = 1: numel(jumpSizes)
    meanMedAdjustLow(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,1,2,iJmp,:))) - mean(squeeze(medAdjusts(:,1,2,iJmp,pre+1))));
    meanMedAdjustMed(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,1,3,iJmp,:))) - mean(squeeze(medAdjusts(:,1,3,iJmp,pre+1))));
    meanMedAdjustHig(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,1,4,iJmp,:))) - mean(squeeze(medAdjusts(:,1,4,iJmp,pre+1))));
end
figure; 

pL = plot(timeAxis, meanMedAdjustLow', 'linewidth', 2);
hold on, 
%pM = plot(timeAxis, meanMedAdjustMed');
%hold on, 
pH = plot(timeAxis, meanMedAdjustHig', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
%legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
legend([pL(end), pH(end)], 'low', 'high')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Stochasticity * JumpSize - start at 0')


% Effect of volatility - raw
figure; 

pS = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,2,1,:,:))))', 'linewidth', 2);
hold on, 
pV = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,3,1,:,:))))', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pS(end), pV(end)], 'stable', 'volatile')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility * JumpSize')

% Effect of volatility - normalised
for iJmp = 1: numel(jumpSizes)
    meanMedAdjustSta(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,2,1,iJmp,:))) - mean(squeeze(medAdjusts(:,2,1,iJmp,pre+1))));
    meanMedAdjustVol(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,3,1,iJmp,:))) - mean(squeeze(medAdjusts(:,3,1,iJmp,pre+1))));
end
figure; 

pS = plot(timeAxis, meanMedAdjustSta', 'linewidth', 2);
hold on, 
%pM = plot(timeAxis, meanMedAdjustMed');
%hold on, 
pV = plot(timeAxis, meanMedAdjustVol', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
%legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
legend([pS(end), pV(end)], 'stable', 'volatile')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility * JumpSize - start at 0')


% Volatility * Stochasticity
figure; 

pLS = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,2,2,:,:))))', 'linewidth', 2);
hold on, 
pLV = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,3,2,:,:))))', '--', 'linewidth', 2);

pHS = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,2,4,:,:))))');
pHV = plot(timeAxis, squeeze(mean(squeeze(medAdjusts(:,3,4,:,:))))', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pLS(end), pLV(end), pHS(end), pHV(end)], 'low noise, stable', 'low noise, volatile', 'high noise, stable', 'high noise, volatile')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility * Stochasticity * JumpSize')


% Volatility * Stochasticity - normalised
for iJmp = 1: numel(jumpSizes)
    meanMedAdjustStaLo(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,2,2,iJmp,:))) - mean(squeeze(medAdjusts(:,2,2,iJmp,pre+1))));
    meanMedAdjustStaHi(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,2,4,iJmp,:))) - mean(squeeze(medAdjusts(:,2,4,iJmp,pre+1))));
    meanMedAdjustVolLo(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,3,2,iJmp,:))) - mean(squeeze(medAdjusts(:,3,2,iJmp,pre+1))));
    meanMedAdjustVolHi(iJmp, :) = squeeze(mean(squeeze(medAdjusts(:,3,4,iJmp,:))) - mean(squeeze(medAdjusts(:,3,4,iJmp,pre+1))));
end
figure; 

pSL = plot(timeAxis, meanMedAdjustStaLo', 'linewidth', 2);
hold on, 
pSH = plot(timeAxis, meanMedAdjustStaHi');
pVL = plot(timeAxis, meanMedAdjustVolLo', '--', 'linewidth', 2);
pVH = plot(timeAxis, meanMedAdjustVolHi', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
%legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
legend([pSL(end), pSH(end), pVL(end), pVH(end)], 'stable, low noise', 'stable, high noise', 'volatile, low noise', 'volatile, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility * Noise * JumpSize - start at 0')

% Volatility * Stochasticity - normalised, only 2 extremes
figure; 

pSH = plot(timeAxis, meanMedAdjustStaHi');
hold on, 
pVL = plot(timeAxis, meanMedAdjustVolLo', '--', 'linewidth', 2);

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
%legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
legend([pSH(end), pVL(end)], 'stable, high noise', 'volatile, low noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility * Noise * JumpSize - start at 0')


% Volatility * Stochasticity - normalised, only low noise
figure; 

pSL = plot(timeAxis, meanMedAdjustStaLo', 'linewidth', 2);
hold on, 
pVL = plot(timeAxis, meanMedAdjustVolLo', '--', 'linewidth', 2);

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
%legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
legend([pSL(end), pVL(end)], 'stable, low noise', 'volatile, low noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility (low noise) * JumpSize - start at 0')


% Volatility * Stochasticity - normalised, only high noise
figure; 

pSH = plot(timeAxis, meanMedAdjustStaHi');
hold on, 
pVH = plot(timeAxis, meanMedAdjustVolHi', '--', 'linewidth', 2);

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
%legend([pL(end), pM(end), pH(end)], 'low', 'medium', 'high')
legend([pSH(end), pVH(end)], 'stable, high noise', 'volatile, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Volatility (high noise) * JumpSize - start at 0')


% Volatility * Stochasticity - normalised, only stable
figure; 

pSL = plot(timeAxis, meanMedAdjustStaLo', 'linewidth', 2);
hold on, 
pSH = plot(timeAxis, meanMedAdjustStaHi');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pSL(end), pSH(end)], 'stable, low noise', 'stable, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Noise (stable) * JumpSize - start at 0')


% Volatility * Stochasticity - normalised, only volatile
figure; 

pVL = plot(timeAxis, meanMedAdjustVolLo', '--', 'linewidth', 2);
hold on, 
pVH = plot(timeAxis, meanMedAdjustVolHi', '--');

set(gca,'ColorOrder',colormap(lines(5)))
jumpSizes = [10 20 30 40 60]*pi/180;
for i=1:numel(jumpSizes)
    yline(jumpSizes(i))
end
yline(0)
xline(0)
legend([pVL(end), pVH(end)], 'volatile, low noise', 'volatile, high noise')
xlim([-1 8])
xlabel('time from stim mean jump (s)')
ylabel('mean shield position (avg over participants)')
title('Noise (volatile) * JumpSize - start at 0')

end