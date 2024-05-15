function [ volBetas, staBetas, nTrialsVol, nTrialsSta ] = ...
    coins_compute_sessionwise_regressionKernels( sessData, options )

preSmp = options.behav.kernelPreSamplesEvi;

%% Extract block-wise variables and concatenate
X = []; 
Y = [];
volReg = [];
noiseReg = [];
uncertReg = [];
blockId = [];
for iBlock = 1:4
    blockData = sessData(sessData.blockID == iBlock, :);
    blockVol = blockData.volatility;
    noiseTrace = blockData.trueVariance./10 -2;
    shieldSize = blockData.shieldDegrees./20 -2;

    predictionError = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
    % replace all samples until the first hit (participant catches laser for
    % the first time) with NaNs
    tolArea = blockData.shieldDegrees(1)/2;
    for iSmp = 1:numel(predictionError)
        if abs(predictionError(iSmp)) > tolArea
            predictionError(iSmp) = NaN;
        else
            break
        end
    end
    
    blockMove = coins_compute_blockMovements(blockData, options);
    peTrace = [NaN predictionError'];
    
    changeInEvidence = [0; diff(blockData.laserRotation)];
    changeIdx = find(changeInEvidence);
    
    startLeft = blockMove.left.onsets;    
    startRight = blockMove.right.onsets;

    recentEvidenceLeft = [];
    recentEvidenceRight = [];

    for iLeft = 1: numel(startLeft)
        allPriorChanges = changeIdx(changeIdx<startLeft(iLeft));
        if numel(allPriorChanges)>=preSmp
            recentChanges = allPriorChanges(end-preSmp+1:end);
            nonAvail = 0;
        else
            recentChanges = allPriorChanges;
            nonAvail = preSmp-numel(allPriorChanges);
        end
        recentEvidenceLeft(iLeft, :) = peTrace([ones(nonAvail,1); recentChanges+1]);
    end

    for iRight = 1: numel(startRight)
        allPriorChanges = changeIdx(changeIdx<startRight(iRight));
        if numel(allPriorChanges)>=preSmp
            recentChanges = allPriorChanges(end-preSmp+1:end);
            nonAvail = 0;
        else
            recentChanges = allPriorChanges;
            nonAvail = preSmp-numel(allPriorChanges);
        end
        recentEvidenceRight(iRight, :) = peTrace([ones(nonAvail,1); recentChanges+1]);
    end

    X = [X; recentEvidenceLeft; -recentEvidenceRight];
    Y = [Y; blockMove.left.stepSizes; blockMove.right.stepSizes];
    volReg = [volReg; blockVol(blockMove.left.onsets);
        blockVol(blockMove.right.onsets)];
    noiseReg = [noiseReg; noiseTrace(blockMove.left.onsets); 
        noiseTrace(blockMove.right.onsets)];
    uncertReg = [uncertReg; shieldSize(blockMove.left.onsets); 
        shieldSize(blockMove.right.onsets)];
    blockId = [blockId; iBlock*ones(numel(blockMove.left.onsets)+numel(blockMove.right.onsets), 1)];
end

% Compute the GLM - version 1: across conditions
%betasAll = coins_compute_GLM(X,Y,options);

% Compute the GLM - version 1a: across conditions, only 3 samples
Xred = X(:,3:5);
%betasRed = coins_compute_GLM(Xred,Y,options);

% Compute the GLM - version 2: separately vol/stab
Xvol = X(volReg==1, :);
Yvol = Y(volReg==1);
betasVol = coins_compute_GLM(Xvol, Yvol, options);

Xsta = X(volReg==0, :);
Ysta = Y(volReg==0);
betasSta = coins_compute_GLM(Xsta, Ysta, options);

% Compute the GLM - version 3: separately vol/stab, with noise regressor
Xnoi = [X noiseReg];
XvolNoi = Xnoi(volReg==1, :);    
%betasVolNoi = coins_compute_GLM(XvolNoi,Yvol,options);

XstaNoi = Xnoi(volReg==0, :);
%betasStaNoi = coins_compute_GLM(XstaNoi,Ysta,options);

%% Compute the GLM - version 4: separately vol/stab, with noise regressor and interactions with evidence
switch options.behav.flagRegKernelSamples
    case 5
        for iSmp = 1: size(X,2)
            interactX(:,iSmp) = X(:,iSmp).*noiseReg;
        end
        XnoiInter = [X noiseReg interactX];
        XnoiInterVol = XnoiInter(volReg==1, :);
        XnoiInterSta = XnoiInter(volReg==0, :);
        nTrialsVol = size(XnoiInterVol,1);
        nTrialsSta = size(XnoiInterVol,1);
        betasVolNoiInter = coins_compute_GLM(XnoiInterVol, Yvol, options);
        betasStaNoiInter = coins_compute_GLM(XnoiInterSta, Ysta, options);
    case 3  
        for iSmp = 1: size(Xred,2)
            interactX(:,iSmp) = Xred(:,iSmp).*noiseReg;
        end
        XnoiInter = [Xred noiseReg interactX];
        XnoiInterVol = XnoiInter(volReg==1, :);
        XnoiInterSta = XnoiInter(volReg==0, :);
        nTrialsVol = size(XnoiInterVol,1);
        nTrialsSta = size(XnoiInterVol,1);
        betasVolNoiInter = coins_compute_GLM(XnoiInterVol, Yvol, options);
        betasStaNoiInter = coins_compute_GLM(XnoiInterSta, Ysta, options);
end

volBetas = betasVol;%betasVolNoiInter;
staBetas = betasSta;%NoiInter;

%% Shield size update kernels - work in progress
%{
absPE = abs(predictionError);
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
    if numel(allPriorChanges)>=preSmp
        recentChanges = allPriorChanges(end-preSmp+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = preSmp-numel(allPriorChanges);
    end
    recentEvidenceUp(iUp, :) = absPeTrace([ones(nonAvail,1); recentChanges+1]);
end

sizeDown = find(shieldSizeDown);
for iDown = 1: numel(sizeDown)
    allPriorChanges = changeIdx(changeIdx<sizeDown(iDown));
    if numel(allPriorChanges)>=preSmp
        recentChanges = allPriorChanges(end-preSmp+1:end);
        nonAvail = 0;
    else
        recentChanges = allPriorChanges;
        nonAvail = preSmp-numel(allPriorChanges);
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
%}

end