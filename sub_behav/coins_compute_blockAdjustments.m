function [ allAdjust, jumpSize, currVar, currSD ] = coins_compute_blockAdjustments( blockData, options )
%COINS_COMPUTE_BLOCKKERNELS Computes integration kernels from signed
%prediction errors (for shield movements) and absolute PEs (for shield size
%updates)

nSamplesBefore = options.behav.adjustPreSamples;
nSamplesAfter = options.behav.adjustPostSamples;

% transform angels to radians and unwrap to avoid issues with circular data
shield = unwrap(blockData.shieldRotation*pi/180); 
laser = unwrap(blockData.laserRotation*pi/180);
trueMean = unwrap(blockData.trueMean*pi/180);
if sum(abs(shield-laser)) > sum(abs(shield-(laser+2*pi)))
    laser = laser + 2*pi;
    trueMean = trueMean + 2*pi;
end
if sum(abs(shield-trueMean)) > sum(abs(shield-(trueMean+2*pi)))
    trueMean = trueMean + 2*pi;
end

% compute distance 2 mean for all points
dist2mean = shield - trueMean;

% find change points in true mean
%changeInMean = [dist2mean(1); diff(trueMeanRad)];
changeInMean = [0; diff(trueMean)];

cpUp = find(changeInMean>0);
cpDown = find(changeInMean<0);

allAdjust = [];
meanJump = [];
jumpSize = [];
currVar = [];

shield_pad = [NaN(nSamplesBefore, 1); shield; NaN(nSamplesAfter, 1)];
dist2mean_pad = [NaN(nSamplesBefore, 1); dist2mean; NaN(nSamplesAfter, 1)];
trueMean_pad = [NaN(nSamplesBefore, 1); trueMean; NaN(nSamplesAfter, 1)];
for iUp = 1: numel(cpUp)
    % only consider mean jumps after at least nSamplesBefore into the
    % block, and before at least 2s before the end of the block
    if cpUp(iUp) >= nSamplesBefore && cpUp(iUp) < numel(dist2mean)-120
        allAdjust = [allAdjust; shield_pad(cpUp(iUp) : cpUp(iUp)+nSamplesBefore+nSamplesAfter)' - trueMean(cpUp(iUp)-1)];
        meanJump = [meanJump; trueMean_pad(cpUp(iUp) : cpUp(iUp)+nSamplesBefore+nSamplesAfter)'];
        jumpSize = [jumpSize; changeInMean(cpUp(iUp))];
        if numel(unique(blockData.trueVariance(cpUp(iUp)-30:cpUp(iUp)))) > 1
            warning('True noise level changed just before true mean')
        end
        if numel(unique(blockData.trueVariance(cpUp(iUp):cpUp(iUp)+90))) > 1
            warning('True noise level changed within 1.5s after mean jump')
            currVar = [currVar; NaN];
        else
            currVar = [currVar; blockData.trueVariance(cpUp(iUp))];
        end
    end
end
for iDown = 1: numel(cpDown)
    % only consider mean jumps after at least nSamplesBefore into the
    % block, and before at least 2s before the end of the block
    if cpDown(iDown) >= nSamplesBefore && cpDown(iDown) < numel(dist2mean)-120
        allAdjust = [allAdjust; -(shield_pad(cpDown(iDown) : cpDown(iDown)+nSamplesBefore+nSamplesAfter)' - trueMean(cpDown(iDown)-1))];
        meanJump = [meanJump; trueMean_pad(cpDown(iDown) : cpDown(iDown)+nSamplesBefore+nSamplesAfter)'];
        jumpSize = [jumpSize; -changeInMean(cpDown(iDown))];
        if numel(unique(blockData.trueVariance(cpDown(iDown)-30:cpDown(iDown)))) > 1
            warning('True noise level changed just before true mean')
        end
        if numel(unique(blockData.trueVariance(cpDown(iDown):cpDown(iDown)+90))) > 1
            warning('True noise level changed within 1.5s after mean jump')
            currVar = [currVar; NaN];
        else
            currVar = [currVar; blockData.trueVariance(cpDown(iDown))];
        end
    end
end
%figure; plot(allAdjust')
%avgAdjust = nanmean(allAdjust);


% classify jumpSizes
currVar = round(currVar*pi/180,4);
jumpSize = round(jumpSize,4);
currSD = round(jumpSize./currVar,1);    
    
end
