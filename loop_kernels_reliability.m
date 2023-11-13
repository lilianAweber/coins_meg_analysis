options = coins_options;
doExclude = false;

for iSub = 1: numel(options.subjectIDs)
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    load(details.analysis.behav.blockKernels, 'avgKernels');  
        
    sessKernels(iSub, :, :, :) = squeeze(nanmean(avgKernels, 2));
end

sessMoveKernels = squeeze(sessKernels(:,:,1,:));
sessUpKernels = squeeze(sessKernels(:,:,5,:));
sessDownKernels = squeeze(sessKernels(:,:,6,:));

col = coins_colours;
timeAxis = [-options.behav.kernelPreSamples : ...
    options.behav.kernelPostSamples]/options.behav.fsample;
nSubjects = size(sessKernels,1);

fh = figure;
for iSub = 1: nSubjects
    ax = subplot(5,5,iSub+3)
    for iSess = 1:4
        plot(timeAxis, squeeze(sessMoveKernels(iSub,iSess,:)), ...
            'color', col.sessions(iSess,:), 'linewidth', 2);
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
end
hleg = legend('1','2','3','4', 'box','off');%, 'Location','eastoutside');
hleg.Title.String = 'Session';
hleg.FontSize = 16;
linkaxes
xlim([-5 1])

savefig(fh, fullfile(options.workDir, 'behav', 'kernels_reliability_subjects.fig'));

maxLag = 200;
[maxCorr_within, bestLag_within, maxCorr_between, bestLag_between, ...
    R, R_bounds] = crdm_reliability( sessMoveKernels, maxLag );

fh = figure;
bounds2 = [R-R_bounds(:,1) R_bounds(:,2)-R];
shadedErrorBar2(timeAxis, R, bounds2, 'lineprops', ...
    {'-', 'color', col.lowNoise, 'linewidth', 4});
hold on
yline(0, '-k')
yline(1, '-k')
yline(0.5, '--k')
xline(0,'--', 'color',col.highNoise)
xlabel('time to response [s]')
ylabel('ICC(2,1)')
xlim([-5 1])
yticks([0 0.5 1])
title({'Shield movements', 'ICC(2,1) over time'})
fh.Children.FontSize = 16;
fh.Children.LineWidth = 1;
savefig(fh, fullfile(options.workDir, 'behav', 'kernels_reliability_ICC.fig'))
