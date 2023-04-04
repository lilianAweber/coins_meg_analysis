function [ blockMove ] = coins_compute_blockMovements( blockData, options )

% Start by excluding everything that happened prior to the first hit
predictionError = mod(blockData.laserRotation-blockData.shieldRotation+180,360)-180;
tolArea = unique(blockData.shieldDegrees)/2;
for iSmp = 1:numel(predictionError)
    if abs(predictionError(iSmp)) <= tolArea
        startSample = iSmp;
        break
    end
end
blockData(1:startSample-1, :) = [];

% Determine movement onsets
shield1stDeriv = [0; diff(blockData.shieldRotation)];
shield2ndDeriv = [0; 0; diff(diff(blockData.shieldRotation))];

leftTurnOnsets = shield1stDeriv>0 &shield2ndDeriv>0;
rightTurnOnsets = shield1stDeriv<0 &shield2ndDeriv<0;

leftOnsetIdx = find(leftTurnOnsets);
rightOnsetIdx = find(rightTurnOnsets);

% Find movement offsets (more difficult as we don't always get the
% derivatives we would expect for the offsets if people end their move by 
% pressing the other direction 
for iOn = 1: numel(leftOnsetIdx)
    for iFrame = leftOnsetIdx(iOn) : numel(shield1stDeriv)
        if shield1stDeriv(iFrame) <= 0
            break
        end
    end
    leftOffsetIdx(iOn,1) = iFrame;
end
        
for iOn = 1: numel(rightOnsetIdx)
    for iFrame = rightOnsetIdx(iOn) : numel(shield1stDeriv)
        if shield1stDeriv(iFrame) >= 0
            break
        end
    end
    rightOffsetIdx(iOn,1) = iFrame;
end

leftStepSizes = leftOffsetIdx - leftOnsetIdx;
rightStepSizes = rightOffsetIdx - rightOnsetIdx;

% exclude very small steps
origLeftStepSizes = leftStepSizes;
origRightStepSizes = rightStepSizes;


%% group together steps that are very close together in time
leftDiscard = [];
newLeftStepSizes = leftStepSizes;
for iL = 2: numel(leftOnsetIdx)
    if (leftOnsetIdx(iL) - leftOffsetIdx(iL-1)) < options.behav.minResponseDistance
        leftDiscard = [leftDiscard; iL];
        % determine relevant stepSize to adjust
        relStep = iL-1;
        for iBack = 1: iL
            if ~ismember(relStep, leftDiscard)
                break;
            else
                relStep = relStep-1;
            end
        end
        % adjust step size of relevant previous step
        %newLeftStepSizes(relStep) = newLeftStepSizes(relStep) + leftStepSizes(iL);
        newLeftStepSizes(relStep) = blockData.shieldRotation(leftOffsetIdx(iL)-1) - blockData.shieldRotation(leftOnsetIdx(relStep)-1);
    end
end
cleanLeftStepSizes = newLeftStepSizes;
cleanLeftOnsetIdx = leftOnsetIdx;
cleanLeftStepSizes(leftDiscard) = [];
cleanLeftOnsetIdx(leftDiscard) = [];

rightDiscard = [];
newRightStepSizes = rightStepSizes;
for iR = 2: numel(rightOnsetIdx)
    if (rightOnsetIdx(iR) - rightOffsetIdx(iR-1)) < options.behav.minResponseDistance
        rightDiscard = [rightDiscard; iR];
        % determine relevant stepSize to adjust
        relStep = iR-1;
        for iBack = 1: iR
            if ~ismember(relStep, rightDiscard)
                break;
            else
                relStep = relStep-1;
            end
        end
        % adjust step size of relevant previous step
        %newRightStepSizes(relStep) = newRightStepSizes(relStep) + rightStepSizes(iR);
        newRightStepSizes(relStep) = blockData.shieldRotation(rightOnsetIdx(relStep)-1) - blockData.shieldRotation(rightOffsetIdx(iR)-1);
    end
end
cleanRightStepSizes = newRightStepSizes;
cleanRightOnsetIdx = rightOnsetIdx;
cleanRightStepSizes(rightDiscard) = [];
cleanRightOnsetIdx(rightDiscard) = [];

%% Exclude very small steps
smallStepsLeft = find(cleanLeftStepSizes < options.behav.minStepSize);
cleanLeftOnsetIdx(smallStepsLeft) = [];
cleanLeftStepSizes(smallStepsLeft) = [];
smallStepsRight = find(cleanRightStepSizes < options.behav.minStepSize);
cleanRightOnsetIdx(smallStepsRight) = [];
cleanRightStepSizes(smallStepsRight) = [];

blockMove.left.onsets = cleanLeftOnsetIdx + startSample-1;
blockMove.left.stepSizes = cleanLeftStepSizes;
blockMove.left.smallSteps = numel(smallStepsLeft);
blockMove.left.unifiedSteps = numel(leftDiscard);
blockMove.left.origStepSizes = origLeftStepSizes;

blockMove.right.onsets = cleanRightOnsetIdx + startSample-1;
blockMove.right.stepSizes = cleanRightStepSizes;
blockMove.right.smallSteps = numel(smallStepsRight);
blockMove.right.unifiedSteps = numel(rightDiscard);
blockMove.right.origStepSizes = origRightStepSizes;

blockMove.nMovements = numel(cleanLeftOnsetIdx) + numel(cleanRightOnsetIdx);
blockMove.stepSizes = [cleanLeftStepSizes; cleanRightStepSizes];
blockMove.origStepSizes = [origLeftStepSizes; origRightStepSizes];
blockMove.nSmallSteps = numel(smallStepsLeft) + numel(smallStepsRight);
blockMove.nUnifiedSteps = numel(leftDiscard) + numel(rightDiscard);


end