options = coins_options;
doExclude = false;

for iSub = 1: numel(options.subjectIDs)
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.blockKernels, 'staKernels', 'volKernels');
    load(details.analysis.behav.nResponses, 'nResponses');    
        
    groupKernels(iSub, 1, :, :) = nanmean(staKernels, [1 2]);
    groupKernels(iSub, 2, :, :) = nanmean(volKernels, [1 2]);
    groupN(iSub, 1, :) = [nResponses.stable.move nResponses.stable.size];
    groupN(iSub, 2, :) = [nResponses.volatile.move nResponses.volatile.size];
end

avgGroupKernels = squeeze(mean(groupKernels,1));
seGroupKernels = squeeze(std(groupKernels,1)./sqrt(numel(options.subjectIDs)));

nShieldMin = min(groupN(:,1,2) + groupN(:,2,2));
nShieldMax = max(groupN(:,1,2) + groupN(:,2,2));

col = coins_colours;
timeAxis = [-options.behav.kernelPreSamples : ...
    options.behav.kernelPostSamples]/options.behav.fsample;


fh = figure;
nSubjects = size(groupN,1);

subplot(1,2,1)
for iSub = 1: nSubjects
    plot([1 2], ...
        [squeeze(groupN(iSub,1,1)) ...
        squeeze(groupN(iSub,2,1))], ...
        '-', 'Color', col.highNoise);
    hold on
end
p1 = plot(1, squeeze(groupN(:,1,1)), 'o', ...
    'Color', col.stable, 'MarkerFaceColor', col.stable);
p2 = plot(2, squeeze(groupN(:,2,1)), 'o', ...
    'Color', col.volatile, 'MarkerFaceColor', col.volatile);
legend([p1(end), p2(end)], 'stable', 'volatile')
ylabel('N responses in kernel analysis')
xticks([])
title('N shield moves')
box off

subplot(1,2,2)
for iSub = 1: nSubjects
    plot([1 2], ...
        [squeeze(groupN(iSub,1,2)) ...
        squeeze(groupN(iSub,2,2))], ...
        '-', 'Color', col.highNoise);
    hold on
end
p1 = plot(1, squeeze(groupN(:,1,2)), 'o', ...
    'Color', col.stable, 'MarkerFaceColor', col.stable);
p2 = plot(2, squeeze(groupN(:,2,2)), 'o', ...
    'Color', col.volatile, 'MarkerFaceColor', col.volatile);
legend([p1(end), p2(end)], 'stable', 'volatile')
ylabel('N responses in kernel analysis')
xticks([])
title('N size updates')
box off

[nSizeSta, idx] = sort(squeeze(groupN(:,1,2)));
exclSubj = idx(nSizeSta<100);
if doExclude
    groupKernels(exclSubj,:,:,:) = [];
    avgGroupKernels = squeeze(mean(groupKernels,1));
    seGroupKernels = squeeze(std(groupKernels,1)./sqrt(numel(options.subjectIDs)));

    nShieldMin = min(groupN(:,1,2) + groupN(:,2,2));
    nShieldMax = max(groupN(:,1,2) + groupN(:,2,2));

end

%% with individual participant kernels
fh = figure; 
subplot(2,1,1);
plot(timeAxis, squeeze(groupKernels(:,1,1,:))', '--', 'color', col.stable);
hold on
p1 = plot(timeAxis, squeeze(avgGroupKernels(1,1,:)), '-', 'linewidth', 3, 'color', col.stable);
plot(timeAxis, squeeze(groupKernels(:,2,1,:))', '--', 'color', col.volatile);
p2 = plot(timeAxis, squeeze(avgGroupKernels(2,1,:)), '-', 'linewidth', 3, 'color', col.volatile);
%xlim([-2.5 1])
xlabel('time (s) around shield movement')
ylabel('signed PE')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
legend([p1 p2], ...
    ['stable (n=' num2str(min(groupN(:,1,1))) '-' num2str(max(groupN(:,1,1))) ' per subject)'], ...
    ['volatile (n=' num2str(min(groupN(:,2,1))) '-' num2str(max(groupN(:,2,1))) ' per subject)'], ...
    'location', 'northwest', 'edgecolor', [1 1 1])
title(['Shield movements (N=' num2str(numel(options.subjectIDs)) ')'])
box off

subplot(2,2,3)
plot(timeAxis, squeeze(groupKernels(:,1,5,:))', '--', 'color', col.stable);
hold on
p1 = plot(timeAxis, squeeze(avgGroupKernels(1,5,:)), '-', 'linewidth', 3, 'color', col.stable);
plot(timeAxis, squeeze(groupKernels(:,2,5,:))', '--', 'color', col.volatile);
p2 = plot(timeAxis, squeeze(avgGroupKernels(2,5,:)), '-', 'linewidth', 3, 'color', col.volatile);
%xlim([-2.5 1])
xlabel('time (s) around shield size update')
ylabel('abs PE (mean-corrected)')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
legend([p1 p2], 'stable', 'volatile', 'location', 'northwest', 'edgecolor', [1 1 1])
title({'Shield size up', ['n=' num2str(round(nShieldMin/4)) '-' num2str(round(nShieldMax/4)) ' per subj,cond']})
box off

subplot(2,2,4)
plot(timeAxis, squeeze(groupKernels(:,1,6,:))', '--', 'color', col.stable);
hold on
p1 = plot(timeAxis, squeeze(avgGroupKernels(1,6,:)), '-', 'linewidth', 3, 'color', col.stable);
plot(timeAxis, squeeze(groupKernels(:,2,6,:))', '--', 'color', col.volatile);
p2 = plot(timeAxis, squeeze(avgGroupKernels(2,6,:)), '-', 'linewidth', 3, 'color', col.volatile);
%xlim([-2.5 1])
xlabel('time (s) around shield size update')
ylabel('abs PE (mean-corrected)')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
legend([p1 p2], 'stable', 'volatile', 'location', 'northwest', 'edgecolor', [1 1 1])
title({'Shield size down', ['n=' num2str(round(nShieldMin/4)) '-' num2str(round(nShieldMax/4)) ' per subj,cond']})
box off

fh.Position = [1298 500 944 1059];



%% With shaded error bars
fh = figure; 
subplot(2,1,1);
shadedErrorBar2(timeAxis, squeeze(avgGroupKernels(1,1,:)), squeeze(seGroupKernels(1,1,:)), 'lineprops', ...
    {'-', 'color', col.stable, 'linewidth', 4});
hold on
shadedErrorBar2(timeAxis, squeeze(avgGroupKernels(2,1,:)), squeeze(seGroupKernels(2,1,:)), 'lineprops', ...
    {'-', 'color', col.volatile, 'linewidth', 4});

xlabel('time (s) to response')
ylabel('signed distance')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
xlim([-5 1]);
legend(...[p1 p2], ...
    ...['stable (n=' num2str(min(groupN(:,1,1))) '-' num2str(max(groupN(:,1,1))) ' per subject)'], ...
    ...['volatile (n=' num2str(min(groupN(:,2,1))) '-' num2str(max(groupN(:,2,1))) ' per subject)'], ...
    'stable', 'volatile', ...
        'location', 'northwest', 'edgecolor', [1 1 1])
title(['Shield movements (N=' num2str(numel(options.subjectIDs)) ')'])
box off

subplot(2,2,3)
shadedErrorBar2(timeAxis, squeeze(avgGroupKernels(1,5,:)), squeeze(seGroupKernels(1,5,:)), 'lineprops', ...
    {'-', 'color', col.stable, 'linewidth', 4});
hold on
shadedErrorBar2(timeAxis, squeeze(avgGroupKernels(2,5,:)), squeeze(seGroupKernels(2,5,:)), 'lineprops', ...
    {'-', 'color', col.volatile, 'linewidth', 4});

xlabel('time (s) to response')
ylabel('absolute distance')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
xlim([-5 1]);
%legend(...[p1 p2], 
%    'stable', 'volatile', 'location', 'northwest', 'edgecolor', [1 1 1])
title({'Shield size up'});%, ['n=' num2str(round(nShieldMin/4)) '-' num2str(round(nShieldMax/4)) ' per subj,cond']})
box off

subplot(2,2,4)
shadedErrorBar2(timeAxis, squeeze(avgGroupKernels(1,6,:)), squeeze(seGroupKernels(1,6,:)), 'lineprops', ...
    {'-', 'color', col.stable, 'linewidth', 4});
hold on
shadedErrorBar2(timeAxis, squeeze(avgGroupKernels(2,6,:)), squeeze(seGroupKernels(2,6,:)), 'lineprops', ...
    {'-', 'color', col.volatile, 'linewidth', 4});

xlabel('time (s) to response')
ylabel('absolute distance')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
xlim([-5 1]);
%legend(...[p1 p2], 
%    'stable', 'volatile', 'location', 'northwest', 'edgecolor', [1 1 1])
title({'Shield size down'});%, ['n=' num2str(round(nShieldMin/4)) '-' num2str(round(nShieldMax/4)) ' per subj,cond']})
box off

fh.Children(1).FontSize = 16;
fh.Children(1).LineWidth = 1;
fh.Children(2).FontSize = 16;
fh.Children(2).LineWidth = 1;
fh.Children(4).FontSize = 16;
fh.Children(4).LineWidth = 1;

fh.Children(3).FontSize = 16;
savefig(fh, fullfile(options.workDir, 'behav', 'kernels_shaded.fig'))
%fh.Position = [1298 500 944 1059];

