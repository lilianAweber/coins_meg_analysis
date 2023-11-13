function coins_examine_trigger_delay()

options = coins_options;

%% MEG
% import data from text file which contains MEG triggers (version with
% samples, not time) into a struct: meg.sample, meg.preTrig, meg.trigVal
% I have saved this struct separately
load(fullfile(options.workDir, 'meg', 'subj12_run2_megTrigs.mat'), 'meg');

% find block start triggers in the MEG
bStarts = find(meg.trigVal==10);
% select data up to start of block 2
megB = meg.trigVal(1:bStarts(2));
mTimeSmpB = meg.sample(1:bStarts(2));
% exclude triggers that will not appear in the behaviour 
megBnoExp = megB(megB<10);
mTimeSmpBnoExp = mTimeSmpB(megB<10);

% go from MEG samples to time 
% baseline correct for first relevant event (this has to be the same event
% that the behaviour starts with, double check!)
mTimeBbaseCorr = mTimeSmpBnoExp - mTimeSmpBnoExp(1);
mTimeB = mTimeBbaseCorr/1000; % samplig rate of MEG = 1000 Hz

%% Behav
% load behavioural data for subject 12
details = coins_subjects(12, options);
load(details.analysis.behav.responseData, 'subData');

% choose session 2, first block
sess2  = subData(subData.sessID==2,:);
beh = sess2(sess2.blockID==1,:).triggerValue;

% create behavioural time vector based on sampling rate (60Hz) and number
% of samples in the behavioural trigger vector
bTime = [0:numel(beh)-1]/60; % (subtract 1 because we start at 0)
% this vector is now zero-aligned with the MEG time (because in MEG we
% subtracted the time of the first event that matches the first sample of
% behav triggers)

%% Plot
fh = figure;
plot(bTime, beh, 'o', 'MarkerSize', 8, 'LineWidth', 2);
hold on
plot(mTimeB, megBnoExp, 'x', 'MarkerSize', 8, 'LineWidth', 2);
legend('behav', 'MEG');

xlabel('time (s)')
ylabel('trigger value')
ylim([0 9])
xlim([-5 185]);

fh.Children(1).FontSize = 14;
fh.Children(1).Box = 'off';
fh.Children(2).FontSize = 14;
fh.Children(2).LineWidth =1;
box off

title({'Aligning start time:','all'});
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_all.fig'));

% choose different xlim ranges to zoom in
xlim([-1 5])
title({'Aligning start time:','first 5 seconds'});
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_first.fig'));

xlim([90 95])
title({'Aligning start time:','middle 5 seconds'});
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_middle.fig'));

xlim([94 98])
title({'Aligning start time:','missing triggers'});
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_missing.fig'));

xlim([175 181])
title({'Aligning start time:','last 5 seconds'});
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_last.fig'));

% calculate delay at end of recording
xlim([179.3 180.2])
ylim([0.5 2.5])
% enter data tips for last two data points
fh.Children(2).Children(1).Children.FontSize = 14;
fh.Children(2).Children(2).Children.FontSize = 14;
text(179.8,1.5,'delay = 141ms','FontSize',14)
title({'Aligning start time:','delay at end'})
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_delay.fig'));

% plot delay over time for specific events
idxButtonReleaseBeh = find(beh==7);
idxButtonReleaseMeg = find(megBnoExp==7);
bReleaseTimeBeh = bTime(idxButtonReleaseBeh);
bReleaseTimeMeg = mTimeB(idxButtonReleaseMeg);
fh = figure; 
plot(bReleaseTimeMeg, bReleaseTimeMeg' - bReleaseTimeBeh, 'x', ...
    'MarkerSize', 8', 'LineWidth', 2);
xlabel('Time (s) from MEG triggers')
ylabel('Delay of MEG trigs (MEG-behav) in s')
fh.Children.FontSize = 14;
fh.Children.LineWidth = 1;
box off
title({'Delay between MEG and behav. triggers','for button release triggers only'})
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_delayOverTime_orButtonRelease.fig'));

% check whether preTrig column can explain missing hit/miss triggers
preTrigB = meg.preTrig(1:bStarts(2));
% exclude triggers that will not appear in the behaviour 
preTrigBnoExp = preTrigB(megB<10);

fh = figure;
plot(bTime, beh, 'o', 'MarkerSize', 8, 'LineWidth', 2);
hold on
plot(mTimeB, megBnoExp, 'x', 'MarkerSize', 8, 'LineWidth', 2);
plot(mTimeB, preTrigBnoExp, '^', 'MarkerSize', 8, 'LineWidth', 2);
legend('behav', 'MEG', 'preTrigs');

xlabel('time (s)')
ylabel('trigger value')
ylim([0 9])
xlim([-5 185]);

fh.Children(1).FontSize = 14;
fh.Children(1).Box = 'off';
fh.Children(2).FontSize = 14;
fh.Children(2).LineWidth =1;
box off

title('Inspecting pre trigger column')
savefig(fh, fullfile(options.workDir, 'documentation', 'triggers_alignStart_preTrigColumn.fig'));

%% Align start and end time



end
