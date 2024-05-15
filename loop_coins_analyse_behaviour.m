function loop_coins_analyse_behaviour( options )

if nargin < 1
    options = coins_options;
end
nSubjects = numel(options.subjectIDs);

%% Subject-level analysis steps
for iSub = 1: nSubjects
    subID = options.subjectIDs(iSub);
    details = coins_subjects(subID, options);
    if ~exist(details.analysis.behav.folder, 'dir')
        mkdir(details.analysis.behav.folder);
    end
    %{
    % Load behavioural data from csv spreadsheet
    subData = coins_load_subjectData(details);
    save(details.analysis.behav.responseData, 'subData');
    
    % General performance indices
    coins_subjectPerformance(details, options);

    % Compute behavioural integration kernels using regression method
    coins_subjectKernels(details, options);
    close all
    %}
    % Same thing, but session-wise with noise effects
    coins_subjectKernels_sessionWise(details, options);
    close all

    % Compute post-mean jump adjustments per condition
    %coins_subjectAdjustments(details, options);

    % Analyse post mean jump reaction times - this is an old version of RT
    % analysis - we now look at adjustment-based RTs which can only be
    % computed per participant & condition (as part of the group analyses
    % below)
    %fh = coins_analyse_subject_reactionTimes( subID, options );
    %savefig(fh, details.analysis.behav.rtFig)
end


%% Group-level analyses

% Integration kernels
coins_group_regressionKernels(options);
coins_group_regressionKernels_sessionWise(options);
coins_group_postJumpAdjustments(options);
coins_group_reactionTimes(options);











