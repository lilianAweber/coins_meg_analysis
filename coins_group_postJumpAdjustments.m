function coins_group_postJumpAdjustments(options)

nSubjects = numel(options.subjectIDs);
resultsDir = fullfile(options.workDir, 'behav');

% collect
for iSub = 1: nSubjects
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.meanAdjustments, 'meanAdjusts');
    groupAdjusts(iSub, :, :, :, :) = meanAdjusts;
end

load(details.analysis.behav.adjustments, 'allJumps');
jumpSizes = unique(allJumps);
pre = options.behav.adjustPreSamples;
post = options.behav.adjustPostSamples;
fsmp = options.behav.fsample;
timeAxis = [-pre/fsmp: 1/fsmp : post/fsmp];

% normalise
if options.behav.flagNormaliseAdjustments
    for iSub = 1: nSubjects
        for iJmp = 1: numel(jumpSizes)
            for iCon = 1:3
                for iVar = 1:4
                    groupAdjusts(iSub, iCon, iVar, iJmp, :) = ...
                        squeeze(groupAdjusts(iSub,iCon,iVar,iJmp,:)) - ...
                        squeeze(groupAdjusts(iSub,iCon,iVar,iJmp,pre+1));
                end
            end
        end     
    end
end

% save
avgGroupAdjusts = squeeze(mean(groupAdjusts,1));
seGroupAdjusts = squeeze(std(groupAdjusts,1)./sqrt(size(groupAdjusts,1)));
save(fullfile(resultsDir, ['n' num2str(nSubjects) '_groupAdjustments.mat']), ...
    "groupAdjusts", "avgGroupAdjusts", "seGroupAdjusts", "timeAxis", "jumpSizes");

% plot
[fh1, fh2] = coins_plot_group_adjustments(avgGroupAdjusts, seGroupAdjusts, ...
    jumpSizes, options);

savefig(fh1, fullfile(resultsDir, ['n' num2str(nSubjects) ...
    '_adjustment_timecourse_volatility.fig']));
savefig(fh2, fullfile(resultsDir, ['n' num2str(nSubjects) ...
    '_adjustment_timecourse_noise.fig']));

end