function [ allDurs, nResp, jumpSize, currVar, currSD ] = coins_compute_blockReactionTimes( blockData, options )
%COINS_COMPUTE_BLOCKREACTIONTIMES Computes "reaction times" defined as the
%onset of the first/longest button press in the right direction after a
%mean jump

nSamplesAfter = options.behav.maxRtSamples; % 2.5s * 60 Hz = 150;
nSamplesBefore = 0; % 0.3s * 60Hz = 18

% transform angels to radians and unwrap to avoid issues with circular data
shield = unwrap(blockData.shieldRotation*pi/180); 
laser = unwrap(blockData.laserRotation*pi/180);
trueMean = unwrap(blockData.trueMean*pi/180);
if sum(abs(shield-laser)) > sum(abs(shield-(laser+2*pi)))
    laser = laser + 2*pi;
    trueMean = trueMean + 2*pi;
end

%% shield movements & movement durations
shieldMove = [0; diff(shield)];
binShieldMove = sign(shieldMove);
bin2ndDeriv = [0; diff(binShieldMove)];

upTurnOnsets = binShieldMove>0 & bin2ndDeriv>0;
doTurnOnsets = binShieldMove<0 & bin2ndDeriv<0;

upTurnOffsets = binShieldMove==0 & bin2ndDeriv<0 | bin2ndDeriv<-1;
doTurnOffsets = binShieldMove==0 & bin2ndDeriv>0 | bin2ndDeriv>1;

upStart = find(upTurnOnsets);
upStop = find(upTurnOffsets);
if numel(upStart) > numel(upStop)
    % subject pressed a button towards the end of the block and did not 
    % release it before the block was over
    upStop = [upStop; numel(shieldMove)];
end
upDur = upStop - upStart;

doStart = find(doTurnOnsets);
doStop = find(doTurnOffsets);
if numel(doStart) > numel(doStop)
    % subject pressed a button towards the end of the block and did not 
    % release it before the block was over
    doStop = [doStop; numel(shieldMove)];
end
doDur = doStop - doStart;

allMoveDursSmp = [upDur; doDur];
allMoveDursSec = [upDur; doDur]/options.behav.fsample;

%% find change points in true mean
changeInMean = [0; diff(trueMean)];

cpUp = find(changeInMean>0);
cpDo = find(changeInMean<0);

%% collect responses & durations per CP
allDurs = NaN(numel(cpUp)+numel(cpDo), 10);
nResp = [];

jumpSize = [];
currVar = [];

for iUp = 1: numel(cpUp)
    responseOnsets = find(upStart > cpUp(iUp)+nSamplesBefore & upStart < cpUp(iUp)+nSamplesAfter);
    nResp = [nResp; numel(responseOnsets)];
    for iResp = 1: numel(responseOnsets)
        allDurs(iUp, iResp) = upDur(responseOnsets(iResp));
    end
    jumpSize = [jumpSize; changeInMean(cpUp(iUp))];
    currVar = [currVar; blockData.trueVariance(cpUp(iUp))];
end
for iDo = 1: numel(cpDo)
    responseOnsets = find(doStart > cpDo(iDo)+nSamplesBefore & doStart < cpDo(iDo)+nSamplesAfter);
    nResp = [nResp; numel(responseOnsets)];
    for iResp = 1: numel(responseOnsets)
        allDurs(iUp+iDo, iResp) = doDur(responseOnsets(iResp));
    end
    jumpSize = [jumpSize; -changeInMean(cpDo(iDo))];
    currVar = [currVar; blockData.trueVariance(cpDo(iDo))];
end

% classify jumpSizes
currVar = round(currVar*pi/180,4);
jumpSize = round(jumpSize,4);
currSD = round(jumpSize./currVar,1);    
    
end
