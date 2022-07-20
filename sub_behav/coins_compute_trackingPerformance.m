function [ stim, perf ] = coins_compute_trackingPerformance( blockData, options )
%COINS_COMPUTE_TRACKINGPERFORMANCE Computes several indices for quantifying
%how well a participant was tracking the laser position in the COINS study.

%% Keep track of conditions
stim.volatility = unique(blockData.volatility);
perf.volatility = unique(blockData.volatility);

%% Collect raw and derived stimulus
% stimulus and generating stats
stim.position   = blockData.laserRotation;
stim.genMean    = blockData.trueMean;
stim.movAvg     = movmean(blockData.laserRotation, [options.behav.movAvgWin-1 0]);
stim.genStd     = blockData.trueVariance;
stim.movAvg     = movstd(blockData.laserRotation, [options.behav.movAvgWin-1 0]);
% change points in generating stats
stim.nMeanCPs   = sum(diff(blockData.trueMean)~=0);% + sum(diff(blockData.trueMean)>0);
stim.sumDeltaMean = sum(abs(diff(blockData.trueMean)));
stim.nStdCPs    = sum(diff(blockData.trueVariance)~=0);
% bias in stimulus and generating stats
stim.moveBias   = sum(diff(blockData.laserRotation));
stim.meanBias   = sum(diff(blockData.trueMean));
stim.stdBias    = sum(diff(blockData.trueVariance));

%% Collect raw and derived behaviour
% useful variables
shield1stDeriv = [0; diff(blockData.shieldRotation)];
shield2ndDeriv = [0; 0; diff(diff(blockData.shieldRotation))];

leftTurnOnsets = shield1stDeriv>0 &shield2ndDeriv>0;
rightTurnOnsets = shield1stDeriv<0 &shield2ndDeriv<0;
isShieldMovement = shield1stDeriv ~= 0;

shieldSize1stDeriv = [0; diff(blockData.shieldDegrees)];
shieldSizeUp = shieldSize1stDeriv > 0;
shieldSizeDown = shieldSize1stDeriv < 0;

% position and movement
perf.position       = blockData.shieldRotation;
perf.positionPE     = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
perf.overallPosPE   = sum(abs(perf.positionPE));
perf.diff2genMean   = mod(blockData.trueMean-blockData.shieldRotation+180,360)-180;
perf.sumDiff2mean   = sum(abs(perf.diff2genMean));
perf.nMoveOnsets    = sum(leftTurnOnsets) + sum(rightTurnOnsets);
perf.nMoveFrames    = sum(isShieldMovement);
perf.overallMove    = sum(abs(shield1stDeriv));

% movement biases
perf.moveBias       = sum(shield1stDeriv);
perf.relMoveBias    = perf.moveBias - stim.moveBias;
perf.trackBias      = sum(perf.positionPE);
perf.relTrackBias   = perf.trackBias - stim.moveBias; %???
perf.infBias        = sum(perf.diff2genMean);
perf.relInfBias     = perf.infBias - stim.meanBias;

% shield size and updates
perf.stdev          = 0.5*blockData.shieldDegrees;
perf.meanStdev      = mean(perf.stdev);
perf.absPositionPE  = abs(perf.positionPE);
perf.diff2absPE     = perf.absPositionPE - perf.stdev;
perf.sumDiff2absPE  = sum(abs(perf.diff2absPE));
perf.diff2genStd    = perf.stdev - stim.genStd;
perf.sumDiff2std    = sum(abs(perf.diff2genStd));
perf.nSizeOnsets    = sum(shieldSizeUp) + sum(shieldSizeDown);

% shield size biases
perf.sizeTrackBias  = sum(perf.diff2absPE);
perf.sizeInfBias    = sum(perf.diff2genStd);
perf.sizeUpdateBias = sum(shieldSize1stDeriv);
perf.relSizeUpdateBias = perf.sizeUpdateBias - stim.stdBias;

% volatility biases
perf.diff2genMeanCPs    = perf.nMoveOnsets - stim.nMeanCPs;
perf.diff2sumDeltaMean  = perf.overallMove - stim.sumDeltaMean;
perf.diff2genStdCPs     = perf.nSizeOnsets - stim.nStdCPs;


% reward/loss
perf.reward = blockData.totalReward(end);

end
