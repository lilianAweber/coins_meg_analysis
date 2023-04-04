function [ avgKernels, nKernels ] = coins_compute_blockKernels( blockData, options )
%COINS_COMPUTE_BLOCKKERNELS Computes integration kernels from signed
%prediction errors (for shield movements) and absolute PEs (for shield size
%updates)

nSamplesBefore = options.behav.kernelPreSamples;
nSamplesAfter = options.behav.kernelPostSamples;
nSamplesTotal = nSamplesBefore + nSamplesAfter;

predictionError = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
absPE = abs(predictionError);

shield1stDeriv = [0; diff(blockData.shieldRotation)];
shield2ndDeriv = [0; 0; diff(diff(blockData.shieldRotation))];

leftTurnOnsets = shield1stDeriv>0 &shield2ndDeriv>0;
rightTurnOnsets = shield1stDeriv<0 &shield2ndDeriv<0;

shieldSize1stDeriv = [0; diff(blockData.shieldDegrees)];
shieldSizeUp = shieldSize1stDeriv > 0;
shieldSizeDown = shieldSize1stDeriv < 0;

peTrace = [NaN(1, nSamplesBefore) predictionError' NaN(1, nSamplesAfter)];
startLeft = find(leftTurnOnsets);
allKernelsLeft = [];
for iLeft = 1: numel(startLeft)
    allKernelsLeft = [allKernelsLeft; peTrace(startLeft(iLeft) : startLeft(iLeft)+nSamplesTotal)]; 
end
startRight = find(rightTurnOnsets);
allKernelsRight = [];
for iRight = 1: numel(startRight)
    allKernelsRight = [allKernelsRight; peTrace(startRight(iRight) : startRight(iRight)+nSamplesTotal)]; 
end

absPeTrace = [NaN(1, nSamplesBefore) absPE' NaN(1, nSamplesAfter)];
startUp = find(shieldSizeUp);
allKernelsUp = [];
for iUp = 1: numel(startUp)
    allKernelsUp = [allKernelsUp; absPeTrace(startUp(iUp) : startUp(iUp)+nSamplesTotal)]; 
end
startDown = find(shieldSizeDown);
allKernelsDown = [];
for iDown = 1: numel(startDown)
    allKernelsDown = [allKernelsDown; absPeTrace(startDown(iDown) : startDown(iDown)+nSamplesTotal)]; 
end

if isempty(allKernelsUp)
    allKernelsUp = NaN(1, size(allKernelsLeft, 2));
end
if isempty(allKernelsDown)
    allKernelsDown = NaN(1, size(allKernelsLeft, 2));
end

moveKernels = [allKernelsLeft; -allKernelsRight];
sizeKernels = [allKernelsUp; -allKernelsDown];

avgKernels = [nanmean(moveKernels, 1); nanmean(sizeKernels, 1); ...
                nanmean(allKernelsLeft, 1); nanmean(allKernelsLeft, 1); ...
                nanmean(allKernelsUp, 1); nanmean(allKernelsDown, 1)];

nKernels = [size(moveKernels, 1); size(allKernelsUp, 1); size(allKernelsDown, 1)];

%moveKernels(:, :) = allKernelsMove;
%sizeKernels(:, :) = allKernelsSize;
%blockKernels(1, 1, :, :) = allKernelsLeft;
%blockKernels(1, 2, :, :) = -allKernelsRight;
%blockKernels(2, 1, :, :) = allKernelsUp;
%blockKernels(2, 2, :, :) = -allKernelsDown;

end
