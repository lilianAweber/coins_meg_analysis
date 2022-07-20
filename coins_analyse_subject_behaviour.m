function coins_analyse_subject_behaviour( subID, options )

details = coins_subjects(subID, options);
if ~exist(details.analysis.behav.folder, 'dir')
    mkdir(details.analysis.behav.folder);
end
subData = coins_load_subjectData(details);
save(details.analysis.behav.responseData, 'subData');
%load(details.analysis.behav.responseData, 'subData');

% Go through data block-wise, extract kernels and compute performance
for iSess = 1: details.nSessions
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        fh = coins_plot_blockData(blockData, options);
        savefig(fh, details.analysis.behav.blockFigures{iSess, iBlock});
        [stim{iSess, iBlock}, perform{iSess, iBlock}] = ...
            coins_compute_trackingPerformance(blockData, options);
        
        % integration kernels
        [avgKernels(iSess, iBlock, :, :), nKernels(iSess, iBlock, :)] = ...
            coins_compute_blockKernels(blockData, options);
        conditionLabels(iSess, iBlock) = unique(blockData.volatility);
        if unique(blockData.volatility)==1
            volKernels(iSess, iBlock, :, :) = avgKernels(iSess, iBlock, :, :);
            staKernels(iSess, iBlock, :, :) = NaN(size(avgKernels, 3, 4));
        else
            volKernels(iSess, iBlock, :, :) = NaN(size(avgKernels, 3, 4));
            staKernels(iSess, iBlock, :, :) = avgKernels(iSess, iBlock, :, :);
        end
    end
end
save(details.analysis.behav.performance, 'stim', 'perform');
save(details.analysis.behav.blockKernels, 'avgKernels', 'volKernels', 'staKernels');

fh = coins_plot_participant_performance(perform);
savefig(fh, details.analysis.behav.performancePlot);

% Compute number of responses (as used for the kernels)
nMoveKernels = squeeze(nKernels(:, :, 1));
nSizeKernels = squeeze(nKernels(:, :, 2));
nResponses.move = sum(sum(nMoveKernels));
nResponses.size = sum(sum(nSizeKernels));
nResponses.volatile.move = sum(sum(nMoveKernels(conditionLabels==1)));
nResponses.volatile.size = sum(sum(nSizeKernels(conditionLabels==1)));
nResponses.stable.move = sum(sum(nMoveKernels(conditionLabels==0)));
nResponses.stable.size = sum(sum(nSizeKernels(conditionLabels==0)));
save(details.analysis.behav.nResponses, 'nResponses');

% Plot volatile versus stable block kernels
fh = figure;
timeAxis = [-options.behav.kernelPreSamples : ...
    options.behav.kernelPostSamples]/options.behav.fsample;

subplot(2, 1, 1); 
% signed PEs preceding movements
plot(timeAxis, nanmean(squeeze(nanmean(volKernels(:, :, 1, :),1)),1))
hold on
plot(timeAxis, nanmean(squeeze(nanmean(staKernels(:, :, 1, :),1)),1))
xlabel('time (s) around button press')
ylabel('signed PE')
title('Average signed PEs leading up to shield movement onset')
legend(['volatile blocks (N=' num2str(nResponses.volatile.move) ')'], ...
    ['stable blocks (N=' num2str(nResponses.stable.move) ')']);

subplot(2, 1, 2); 
% abs PEs preceding size updates
plot(timeAxis, nanmean(squeeze(nanmean(volKernels(:, :, 2, :),1)),1))
hold on
plot(timeAxis, nanmean(squeeze(nanmean(staKernels(:, :, 2, :),1)),1))
xlabel('time (s) around button press')
ylabel('absolute PE')
title('Average absolute PEs leading up to shield size update')
legend(['volatile blocks (N=' num2str(nResponses.volatile.size) ')'], ...
    ['stable blocks (N=' num2str(nResponses.stable.size) ')']);

savefig(fh, details.analysis.behav.kernelConditionPlot)

end