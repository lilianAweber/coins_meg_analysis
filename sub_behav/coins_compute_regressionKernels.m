function [ betas, nTrials, avgKernels, nKernels, ...
    recentEvidenceUp, recentEvidenceDown ] = ...
    coins_compute_regressionKernels( blockData, options )
%COINS_COMPUTE_REGRESSIONKERNELS Computes integration kernels from signed
%prediction errors (for shield movements) and absolute PEs (for shield size
%updates) using regression method

nSamplesBefore = options.behav.kernelPreSamplesEvi;
%nSamplesAfter = options.behav.kernelPostSamplesEvi;

%% Preparation
predictionError = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
% replace all samples until the first hit (participant catches laser for
% the first time) with NaNs
tolArea = unique(blockData.shieldDegrees)/2;
for iSmp = 1:numel(predictionError)
    if abs(predictionError(iSmp)) > tolArea
        predictionError(iSmp) = NaN;
    else
        break
    end
end
absPE = abs(predictionError);

%% Shield movement kernels
blockMove = coins_compute_blockMovements(blockData, options);
peTrace = [NaN predictionError'];

changeInEvidence = [0; diff(blockData.laserRotation)];
changeIdx = find(changeInEvidence);

startLeft = blockMove.left.onsets;
for iLeft = 1: numel(startLeft)
    allPriorChanges = changeIdx(changeIdx<startLeft(iLeft));
    if numel(allPriorChanges)>=nSamplesBefore
        recentChanges = allPriorChanges(end-nSamplesBefore+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = nSamplesBefore-numel(allPriorChanges);
    end
    recentEvidenceLeft(iLeft, :) = peTrace([ones(nonAvail,1); recentChanges+1]);
end

startRight = blockMove.right.onsets;
for iRight = 1: numel(startRight)
    allPriorChanges = changeIdx(changeIdx<startRight(iRight));
    if numel(allPriorChanges)>=nSamplesBefore
        recentChanges = allPriorChanges(end-nSamplesBefore+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = nSamplesBefore-numel(allPriorChanges);
    end
    recentEvidenceRight(iRight, :) = peTrace([ones(nonAvail,1); recentChanges+1]);
end

moveKernels = [recentEvidenceLeft; -recentEvidenceRight];

%% Shield size update kernels - work in progress
recentEvidenceUp = [];
recentEvidenceDown = [];

absPE = absPE - nanmean(absPE);
absPeTrace = [NaN absPE'];

shieldSize1stDeriv = [0; diff(blockData.shieldDegrees)];
shieldSizeUp = shieldSize1stDeriv > 0;
shieldSizeDown = shieldSize1stDeriv < 0;

sizeUp = find(shieldSizeUp);
for iUp = 1: numel(sizeUp)
    allPriorChanges = changeIdx(changeIdx<sizeUp(iUp));
    if numel(allPriorChanges)>=nSamplesBefore
        recentChanges = allPriorChanges(end-nSamplesBefore+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = nSamplesBefore-numel(allPriorChanges);
    end
    recentEvidenceUp(iUp, :) = absPeTrace([ones(nonAvail,1); recentChanges+1]);
end

sizeDown = find(shieldSizeDown);
for iDown = 1: numel(sizeDown)
    allPriorChanges = changeIdx(changeIdx<sizeDown(iDown));
    if numel(allPriorChanges)>=nSamplesBefore
        recentChanges = allPriorChanges(end-nSamplesBefore+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = nSamplesBefore-numel(allPriorChanges);
    end
    recentEvidenceDown(iDown, :) = absPeTrace([ones(nonAvail,1); recentChanges+1]);
end

% the GLM for size updates needs to run across different blocks, otherwise
% we have to few data points.

%% Summarise
% spit out average kernels for overall movements, left and right movements
avgKernels = nanmean(moveKernels, 1);
nKernels = size(moveKernels, 1);

%% Regression
% binary
Ybin = [ones(numel(startLeft),1); -ones(numel(startRight),1)];

% continuous
Y = [blockMove.left.stepSizes; -blockMove.right.stepSizes];

% design matrix
X = [recentEvidenceLeft; recentEvidenceRight];
if options.behav.flagNormaliseEvidence
    X = (X - nanmean(X))./nanstd(X);
    Y = (Y - mean(Y))./std(Y);
end
% only keep trials without NaNs in design matrix
toRemove = isnan(X(:,1));
X(toRemove,:) = [];
Ybin(toRemove) = [];
Y(toRemove) = [];
nTrials = size(X,1);

pDM = geninv(X); %pseudoinvesrse of design matrix    
betas = pDM*Y;

if options.behav.flagUseBinaryRegression
    betas = pDM*Ybin;
end


end
