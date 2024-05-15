function [ betasCon, nTrialsCon, avgKernelsCon, nKernelsCon, fh1, fh2 ] = ...
    coins_sizeKernels_regression( subData, excludedBlocks, options )

% Go through data block-wise, extract kernels
nBlocks = zeros(2,1);
evidenceUp{vol} = [];
evidenceDown{vol} = [];

for iSess = 1: max(subData.sessID)
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        % check whether current block is excluded
        if ~isempty(excludedBlocks) && ismember([iSess iBlock], excludedBlocks, 'rows')
            recentEvidenceUp=[];
            recentEvidenceDown=[];
        else
            % compute integration kernels using regression method
            [~, ~, ~, ~, recentEvidenceUp, recentEvidenceDown ] ...
                = coins_compute_regressionKernels(blockData, options);
        end
       
        % allocate kernels to different conditions
        vol = unique(blockData.volatility)+1;
        nBlocks(vol) = nBlocks(vol) + 1;
        evidenceUp{vol} = [evidenceUp{vol}; recentEvidenceUp];
        evidenceDown{vol} = [evidenceDown{vol}; recentEvidenceDown];
        nTrialsUp{vol}(nBlocks(vol)) = size(recentEvidenceUp);
        nTrialsDown{vol}(nBlocks(vol)) = size(recentEvidenceDown);
    end
end

%% Regression

for vol = 1:2
    YbinUp{vol} = ones(numel(evidenceUp{vol}),1); %[ones(numel(startLeft),1); -ones(numel(startRight),1)];
    YbinDown{vol} = ones(numel(evidenceDown{vol}),1);

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
    betas = pDM*Ybin;
end

end