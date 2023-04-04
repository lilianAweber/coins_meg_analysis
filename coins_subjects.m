function details = coins_subjects( subID, options )
%COINS_SUBJECTS Lists all the participant-specific settings and filenames.

details.subjName = sprintf('sub%03.0f', subID);

details.nSessions = 4;
details.excludedBlocks = [];
switch subID
    case 3
        details.excludedBlocks = [1 3]; % col1: sessID; col2: blockID
end
        
details.raw.behav.folder = fullfile(options.rawDir, 'behav', details.subjName);
details.raw.meg.folder = fullfile(options.rawDir, 'MEG', details.subjName);
for iSess = 1: details.nSessions
    details.raw.behav.sessionFileNames{iSess} = fullfile(details.raw.behav.folder, ...
        ['savedData_' details.subjName sprintf('%03.0f', iSess) '.csv']);
end

details.analysis.behav.folder = fullfile(options.workDir, 'behav', details.subjName);
details.analysis.behav.responseData = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_responseData.mat']);
for iSess = 1: details.nSessions
    for iBlock = 1:4
        details.analysis.behav.blockFigures{iSess, iBlock} = ...
            fullfile(details.analysis.behav.folder, [details.subjName ...
            '_sess' num2str(iSess) '_block' num2str(iBlock) '_blockPlot.fig']);
    end
end

details.analysis.behav.performance = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_perform.mat']);
details.analysis.behav.performancePlot = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_performance.fig']);
details.analysis.behav.performRewardFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_performOverviewReward.fig']);
details.analysis.behav.performAvgPeFig  = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_performOverviewAvgPE.fig']);
details.analysis.behav.performAvgDevFromMeanFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_performOverviewDevFromMean.fig']); 

details.analysis.behav.blockKernels = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_blockKernels.mat']);
details.analysis.behav.nResponses = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_nResponses.mat']);
details.analysis.behav.kernelConditionPlot = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_kernelsVolatility.fig']);

details.analysis.behav.adjustments = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_adjustments.mat']);
details.analysis.behav.adjustmentsVolatility = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_adjustmentsSplitByVola.mat']);
details.analysis.behav.meanAdjustments = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_meanAdjustments.mat']);
details.analysis.behav.medianAdjustments = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_medianAdjustments.mat']);

details.analysis.behav.movements = fullfile(details.analysis.behav.folder, ...
    [details.subjName '_movements.mat']);

details.analysis.behav.adjustVolatilityFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName, '_meanAdjust2Volatility.fig']);
details.analysis.behav.adjustVolatilityUnscaledFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName, '_meanAdjust2VolatilityUnscaled.fig']);
details.analysis.behav.adjustNativeJumpSizeFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName, '_meanAdjust2NativeJumpSize.fig']);
details.analysis.behav.adjustJumpSizeOnsetsFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName, '_meanAdjustOnset2JumpSize.fig']);
details.analysis.behav.adjustJumpSizeStochasticityFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName, '_meanAdjust2SizeAndStochasticity.fig']);
details.analysis.behav.adjustJumpSizeVolatilityFig = fullfile(details.analysis.behav.folder, ...
    [details.subjName, '_meanAdjust2SizeAndVolatility.fig']);

end



























