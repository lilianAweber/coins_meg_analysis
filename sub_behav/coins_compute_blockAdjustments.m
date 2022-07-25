function [ allAdjust, jumpSize, currVar, currSD ] = coins_compute_blockAdjustments( blockData, options )
%COINS_COMPUTE_BLOCKKERNELS Computes integration kernels from signed
%prediction errors (for shield movements) and absolute PEs (for shield size
%updates)

nSamplesBefore = options.behav.adjustPreSamples;
nSamplesAfter = options.behav.adjustPostSamples;

% transform angels to radians and unwrap to avoid issues with circular data
rotRad = unwrap(blockData.shieldRotation*pi/180);
trueMeanRad = unwrap(blockData.trueMean*pi/180);
if trueMeanRad(1) < pi
    trueMeanRad = trueMeanRad + 2*pi;
end
%figure; plot(rotRad, '-k');
%hold on; plot(trueMeanRad, '--', 'linewidth', 2, 'color', [0.6 0.6 0.6]);

% compute distance 2 mean for all points and find change points in true
% mean
dist2mean = rotRad - trueMeanRad;
%changeInMean = [dist2mean(1); diff(trueMeanRad)];
changeInMean = [0; diff(trueMeanRad)];

cpUp = find(changeInMean>0);
cpDown = find(changeInMean<0);

allAdjust = [];
meanJump = [];
jumpSize = [];
currVar = [];

diff2mean_pad = [NaN(nSamplesBefore, 1); dist2mean; NaN(nSamplesAfter, 1)];
trueMeanRad_pad = [NaN(nSamplesBefore, 1); trueMeanRad; NaN(nSamplesAfter, 1)];
for iUp = 1: numel(cpUp)
    allAdjust = [allAdjust; -diff2mean_pad(cpUp(iUp) : cpUp(iUp)+nSamplesBefore+nSamplesAfter)'];
    meanJump = [meanJump; trueMeanRad_pad(cpUp(iUp) : cpUp(iUp)+nSamplesBefore+nSamplesAfter)'];
    jumpSize = [jumpSize; changeInMean(cpUp(iUp))];
    currVar = [currVar; blockData.trueVariance(cpUp(iUp))];
end
for iDown = 1: numel(cpDown)
    allAdjust = [allAdjust; diff2mean_pad(cpDown(iDown) : cpDown(iDown)+nSamplesBefore+nSamplesAfter)'];
    meanJump = [meanJump; trueMeanRad_pad(cpDown(iDown) : cpDown(iDown)+nSamplesBefore+nSamplesAfter)'];
    jumpSize = [jumpSize; -changeInMean(cpDown(iDown))];
    currVar = [currVar; blockData.trueVariance(cpDown(iDown))];
end

%avgAdjust = nanmean(allAdjust);


% classify jumpSizes
currVar = round(currVar*pi/180,4);
jumpSize = round(jumpSize,4);
currSD = round(jumpSize./currVar,1);    
    
end
