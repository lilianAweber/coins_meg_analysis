options = coins_options;
sub2use = options.subjectIDs;
blocksInSession = [1 3 5 7; 2 4 6 8];

for iSub = 1: numel(sub2use)
    subID = sub2use(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.blockRegKernels, 'betasCon');
    %{
    for iSess = 1: details.nSessions
        blockStart = iSess * 2 -1;
        data.stab(iSub,iSess,:) = nanmean(betasCon{1}(blockStart:blockStart+1,:),1);
        data.vola(iSub,iSess,:) = nanmean(betasCon{2}(blockStart:blockStart+1,:),1);
        data.avg(iSub, iSess, :) = nanmean([squeeze(data.stab(iSub,iSess,:))'; ...
            squeeze(data.vola(iSub,iSess,:))']);
    end
    %}
    for iSess = 1: 2
        data.stab(iSub,iSess,:) = nanmean(betasCon{1}(blocksInSession(iSess,:),:),1);
        data.vola(iSub,iSess,:) = nanmean(betasCon{2}(blocksInSession(iSess,:),:),1);
        data.avg(iSub, iSess, :) = nanmean([squeeze(data.stab(iSub,iSess,:))'; ...
            squeeze(data.vola(iSub,iSess,:))']);
    end
end

save(fullfile(options.workDir, 'behav', ['n' num2str(numel(sub2use)) '_regressionBetas_data_splitHalf.mat']), 'data');

col = coins_colours;
timeAxis = [-options.behav.kernelPreSamplesEvi:-1];
nSubjects = size(data.vola,1);

conditions = {'stab', 'vola', 'avg'};

fh = figure;
for iCon = 1:3
    cond = conditions{iCon};
    for iSub = 1: nSubjects
        ax = subplot(3,nSubjects,(iCon-1)*nSubjects +iSub)
        for iVis = 1:2
            plot(timeAxis, squeeze(data.(cond)(iSub,iVis,:)), ...
                'color', col.sessions(iVis,:), 'linewidth', 2);
            hold on
        end
        yline(0, '-', 'color', col.medNoise);
        box off
        %if iSub ~= 21
            xticks([])
            yticks([])
        %else
         %   hleg = legend('1','2','3','4', 'box','off');%, 'Location','eastoutside');
         %   hleg.Title.String = 'Session';
        %end
        ax.LineWidth =1;
        if iSub == 1
            title([cond ', ' num2str(sub2use(iSub))]);
        else
            title(num2str(sub2use(iSub)));
        end
    end
end
%hleg = legend('1','2', 'box','off', 'location', 'northwest');%, 'Location','eastoutside');
%hleg.Title.String = 'Visit';
%hleg.FontSize = 12;
linkaxes
xlim([-4 -1])
fh.Position = [552 879 1139 770];
savefig(fh, fullfile(options.workDir, 'behav', ['n22_regressionBetas_reliability_spliHalf_data.fig']));

fh = figure;
for iCon = 1:3
    cond = conditions{iCon};
    maxLag = 5;
    [maxCorr_within, bestLag_within, maxCorr_between, bestLag_between, ...
        R, R_bounds] = crdm_reliability( data.(cond), maxLag );

    bounds2 = [R-R_bounds(:,1) R_bounds(:,2)-R];
    
    ax=subplot(2,2,iCon);
    shadedErrorBar(timeAxis, R, bounds2, 'lineprops', ...
        {'-', 'color', col.lowNoise, 'linewidth', 3});
    hold on
    yline(0, '-k');
    yline(1, '-k');
    yline(0.5, '--k');
    xline(0,'--', 'color',col.highNoise);
    xlabel('samples before response');
    ylabel('ICC(2,1)');
    xlim([-5 -1]);
    ylim([-0.2 1.2]);
    yticks([0 0.5 1]);
    title(cond);
    ax.FontSize = 16;
    ax.LineWidth = 1;
end
linkaxes
fh.Position = [931 1141 666 528];
savefig(fh, fullfile(options.workDir, 'behav', ['n22_regressionBetas_reliability_splitHalf_ICC.fig']));

%% Focussing on the average weights
fh = figure;
cond = conditions{3};
maxLag = 5;
[maxCorr_within, bestLag_within, maxCorr_between, bestLag_between, ...
    R, R_bounds] = crdm_reliability( data.(cond), maxLag );

bounds2 = [R-R_bounds(:,1) R_bounds(:,2)-R];

shadedErrorBar(timeAxis, R, bounds2, 'lineprops', ...
    {'-', 'color', col.lowNoise, 'linewidth', 3});
hold on
yline(0, '-k');
yline(1, '-k');
yline(0.5, '--k');
xline(0,'--', 'color',col.highNoise);
xlabel('samples to response');
ylabel('ICC(2,1)');
xlim([-5 -1]);
ylim([-0.2 1.2]);
yticks([0 0.5 1]);
title('Reliability (split-half)');

fh.Children(1).FontSize = 16;
fh.Children(1).LineWidth = 1;

fh.Position = [1084 1392 245 213];
savefig(fh, fullfile(options.workDir, 'behav', ['n22_regressionBetas_reliability_splitHalf_ICC_avgOnly.fig']));


fh = figure;
for iCon = 3
    cond = conditions{iCon};
    for iSub = 1: nSubjects
        ax = subplot(5,5,iSub+3)
        for iVis = 1:2
            plot(timeAxis, squeeze(data.(cond)(iSub,iVis,:)), ...
                'color', col.sessions(iVis,:), 'linewidth', 2);
            hold on
        end
        yline(0, '-', 'color', col.medNoise);
        box off
        %if iSub ~= 21
            xticks([])
            yticks([])
        %else
         %   hleg = legend('1','2','3','4', 'box','off');%, 'Location','eastoutside');
         %   hleg.Title.String = 'Session';
        %end
        ax.LineWidth =1;
        %if iSub == 1
        %    title([cond ', ' num2str(sub2use(iSub))]);
        %else
            title(num2str(sub2use(iSub)));
        %end
    end
end
%hleg = legend('1','2', 'box','off', 'location', 'northwest');%, 'Location','eastoutside');
%hleg.Title.String = 'Visit';
%hleg.FontSize = 12;
linkaxes
xlim([-5 -1])
for i=1:numel(fh.Children)
fh.Children(i).FontSize=14;
end
fh.Position = [1204 1292 376 479];
savefig(fh, fullfile(options.workDir, 'behav', ['n22_regressionBetas_reliability_spliHalf_data_avgOnly.fig']));

