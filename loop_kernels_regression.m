options = coins_options;
doExclude = false;
sub2use = options.subjectIDs;

% re-compute the kernels using regression method
for iSub = 1: numel(sub2use)
    subID = sub2use(iSub);
    details = coins_subjects(subID, options);
    coins_subjectKernels(details, options);
    close all
end


% load all kernels into group array
for iSub = 1: numel(options.subjectIDs)
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.blockRegKernels, 'betasCon');
        
    groupKernels(iSub, 1, :) = squeeze(nanmean(betasCon{1},1));
    groupKernels(iSub, 2, :) = squeeze(nanmean(betasCon{2},1));
end

avgGroupKernels = squeeze(mean(groupKernels,1));
seGroupKernels = squeeze(std(groupKernels)./sqrt(numel(options.subjectIDs)));

%nShieldMin = min(groupN(:,1,2) + groupN(:,2,2));
%nShieldMax = max(groupN(:,1,2) + groupN(:,2,2));

save(fullfile(options.workDir, 'behav', ['n' num2str(numel(sub2use)) '_regressionBetas.mat']), ...
    'groupKernels', 'avgGroupKernels', 'seGroupKernels');

col = coins_colours;
timeAxis = [-options.behav.kernelPreSamplesEvi:-1];

% Group effect
fh = figure; 
shadedErrorBar(timeAxis, squeeze(avgGroupKernels(1,:)), squeeze(seGroupKernels(1,:)), 'lineprops', ...
    {'-', 'color', col.stable, 'linewidth', 4});
hold on
shadedErrorBar(timeAxis, squeeze(avgGroupKernels(2,:)), squeeze(seGroupKernels(2,:)), 'lineprops', ...
    {'-', 'color', col.volatile, 'linewidth', 4});

xlabel('samples preceding movement')
ylabel('weight on decision')
yline(0);
xline(0, '--', 'color', [0.6 0.6 0.6]);
xlim([-5 -1]);
legend('stable', 'volatile', ...
        'location', 'northwest', 'edgecolor', [1 1 1])
title(['N=' num2str(numel(sub2use))])
box off

fh.Children(1).FontSize = 16;
fh.Children(2).FontSize = 16;
fh.Children(2).LineWidth = 1;

fh.Position = [832 456 372 391];
savefig(fh, fullfile(options.workDir, 'behav', ['n' num2str(numel(sub2use)) ...
    '_regressionBetas_perCondition.fig']))

% With individual participants
fh = figure;
offset = 0.15;
sampleOrder = -5:-1;
for iSub = 1:numel(sub2use)
    for iSamp = 1:5
        plot([sampleOrder(iSamp)-offset sampleOrder(iSamp)+offset], squeeze(groupKernels(iSub,:,iSamp)), ...
            '-', 'color', col.medNoise);
        hold on;
    end
end
for iSub = 1:numel(sub2use)
    p1 = plot(sampleOrder-offset, squeeze(groupKernels(iSub, 1, :)), 'o', ...
        'color', col.stable, 'MarkerFaceColor',col.stable, 'MarkerSize', 8);
    p2 = plot(sampleOrder+offset, squeeze(groupKernels(iSub, 2, :)), 'o', ...
        'color', col.volatile, 'MarkerFaceColor',col.volatile, 'MarkerSize', 8);
end

for iSamp = 1:5
    h = ttest(squeeze(groupKernels(:,1,iSamp)), squeeze(groupKernels(:,2,iSamp)));
    if h
        plot(sampleOrder(iSamp), max(groupKernels(:,1,iSamp))+0.1, '*', ...
            'color', 'k', 'MarkerSize',10, 'linewidth', 1.5);
    end
end
xlim([-5.5 -0.5])
xlabel('samples to response')
ylabel('weight on decision')
legend([p1, p2], 'stable', 'volatile', 'Location','northwest', 'box', 'off');
box off
fh.Children(1).FontSize = 20;
fh.Children(2).FontSize = 16;
fh.Children(2).LineWidth = 1;

fh.Position = [1223 1425 372 391];
savefig(fh, fullfile(options.workDir, 'behav', ['n' num2str(numel(sub2use)) ...
    '_regressionBetas_perSubject.fig']))

xlim([-3.5 -0.5])
title(['N=' num2str(numel(sub2use))])
fh.Children(2).FontSize = 18;
fh.Position = [1166 1404 347 335];
savefig(fh, fullfile(options.workDir, 'behav', ['n' num2str(numel(sub2use)) ...
    '_regressionBetas_perSubject_zoom.fig']))


