function coins_analyse_movement

    options = coins_options;
    col = coins_colours;

    subs = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    %subs = 3;
    sessions = [1, 2, 3, 4];
    blocks = [1, 2, 3, 4; 1, 2, 3, 4; 1, 2, 3, 4; 1, 3, 4, 2; 1, 2, 4, 3; 4, 3, 2, 1; 3, 1, 2, 4; 2, 3, 1, 4; 3, 4, 1, 2];
    %sessions = 1;
    %blocks = 1;

    all_button_presses = [];
    all_bpd = [];
    all_bpd_after_change = [];

    for sub_id = 1:length(subs)
        load(fullfile(options.workDir, 'behav', sprintf('sub%03.0f', subs(sub_id)), strcat(sprintf('sub%03.0f', subs(sub_id)), '_responseData.mat')));

        sub_bpd = [];
        sub_bpd_after_change = [];
        for session_idx = 1:length(sessions)
            session_id = sessions(session_idx);
            session_bpd = [];
            session_bpd_after_change = [];
            for block_id = 1:length(blocks(sub_id, :))
                block_bpd = [];

                all_button_presses(:, blocks(sub_id, block_id), session_id, sub_id) = [0; diff(table2array(subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "shieldRotation")))];
                
                button_press_onsets = [0; diff(all_button_presses(:, blocks(sub_id, block_id), session_id, sub_id))];
                onsets_idx = find(button_press_onsets);
                
                button_press_durations = [0; diff(onsets_idx)];

                button_press_onset_buttons = all_button_presses(onsets_idx, blocks(sub_id, block_id), session_id, sub_id);

                button_press_durations = button_press_durations(find(button_press_onset_buttons));
                button_press_onset_buttons = button_press_onset_buttons(find(button_press_onset_buttons));

                block_bpd(1, :) = button_press_durations;
                block_bpd(2, :) = button_press_onset_buttons;

                session_bpd = [session_bpd, block_bpd];

                %% Button presses after mean changes

                block_bpd_after_change = [];
                all_button_presses_after_change = [];
                
                mean_changes = [0; diff(table2array(subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "trueMean")))];
                mean_changes_onsets = find(mean_changes);
                
                for mean_change_id = 1:length(mean_changes_onsets)
                    if mean_changes_onsets(mean_change_id) + 240 <= length(mean_changes)
                        session_block_bp = subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "shieldRotation");

                        new_button_presses_after_change = [0; diff(table2array(session_block_bp(mean_changes_onsets(mean_change_id):mean_changes_onsets(mean_change_id)+240, "shieldRotation")))];
                        all_button_presses_after_change = [all_button_presses_after_change; new_button_presses_after_change];
                    else
                        session_block_bp = subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "shieldRotation");
                        new_button_presses_after_change = [0; diff(table2array(session_block_bp(mean_changes_onsets(mean_change_id):length(mean_changes), "shieldRotation")))];
                        all_button_presses_after_change = [all_button_presses_after_change; new_button_presses_after_change];

                    end
                end
                
                button_press_onsets_a = [0; diff(all_button_presses_after_change)];
                onsets_idx_a = find(button_press_onsets_a);
                
                button_press_durations_a = [0; diff(onsets_idx_a)];

                button_press_onset_buttons_a = all_button_presses_after_change(onsets_idx_a);

                button_press_durations_a = button_press_durations_a(find(button_press_onset_buttons_a));
                button_press_onset_buttons_a = button_press_onset_buttons_a(find(button_press_onset_buttons_a));

                % Optional - flatten to 240 frames
                flatten = button_press_durations_a > 240;

                button_press_durations_a(find(flatten)) = 240;


                block_bpd_after_change(1, :) = button_press_durations_a;
                block_bpd_after_change(2, :) = button_press_onset_buttons_a;

                session_bpd_after_change = [session_bpd_after_change, block_bpd_after_change];
                
            end
            sub_bpd = [sub_bpd session_bpd];

            sub_bpd_after_change = [sub_bpd_after_change session_bpd_after_change];
        end
        
        %% Non-limited button presses
        % Histogram of button presses for each subject
        subject_button_presses = reshape(all_button_presses(:, :, :, sub_id), [1, numel(all_button_presses(:, :, :, sub_id))]);
        
%         figure
%         hist(subject_button_presses, [-1, 0, 1])
        
        % Histograms of button press durations for each subject

        all_bpd = [all_bpd, sub_bpd];

%         figure
%         hist(sub_bpd(1, :), unique(sub_bpd(1, :)))
%         title("BPD histogram - subject " + sub_id)

        r_presses = sub_bpd(2, :) == 1;
        l_presses = sub_bpd(2, :) == -1;

%         figure
%         subplot(1, 2, 1)
%         hist(sub_bpd(1, r_presses), unique(sub_bpd(1, r_presses)))
%         title("R BPD histogram - subject " + sub_id)
% 
%         subplot(1, 2, 2)
%         hist(sub_bpd(1, l_presses), unique(sub_bpd(1, l_presses)))
%         title("L BPD histogram - subject " + sub_id)

        %% Button presses after change
        
        % Histograms of button press durations for each subject

        all_bpd_after_change = [all_bpd_after_change, sub_bpd_after_change];

%         figure
%         hist(sub_bpd_after_change(1, :), unique(sub_bpd_after_change(1, :)))
%         title("Change BPD histogram - subject " + sub_id)

        r_presses = sub_bpd_after_change(2, :) == 1;
        l_presses = sub_bpd_after_change(2, :) == -1;

%         figure
%         subplot(1, 2, 1)
%         hist(sub_bpd_after_change(1, r_presses), unique(sub_bpd_after_change(1, r_presses)))
%         title("Change R BPD histogram - subject " + sub_id)
% 
%         subplot(1, 2, 2)
%         hist(sub_bpd_after_change(1, l_presses), unique(sub_bpd_after_change(1, l_presses)))
%         title("Change L BPD histogram - subject " + sub_id)
    end
    
    % Overall histogram of button presses for all subjects
    total_button_presses = reshape(all_button_presses, [1, numel(all_button_presses)]);

%     figure
%     hist(total_button_presses, [-1, 0, 1])

    % Overall histograms of button press durations for all subjects

    figure
    hist(all_bpd(1, :), unique(all_bpd(1, :)))
    title('Overall BPD distribution for all subjects')

    r_presses = all_bpd(2, :) == 1;
    l_presses = all_bpd(2, :) == -1;

    figure
    subplot(1, 2, 1)
    hist(all_bpd(1, r_presses), unique(all_bpd(1, r_presses)))
    title('R BPD distribution - all subjects')

    subplot(1, 2, 2)
    hist(all_bpd(1, l_presses), unique(all_bpd(1, l_presses)))
    title('L BPD distribution - all subjects')

    %% First movement in the right direction after mean change

    vol = [0, 1];
    sto = [10, 20, 30];
    jump_sizes = [10, 20, 30, 40, 60];

    all_rt = [];
    all_first_bpd = [];
    all_longest_bpd = [];
    all_longest_rt = [];
    sub_rts = zeros(1, length(subs));

    all_median_rt_js = zeros(1, 5, length(subs));
    all_median_rt_js_vol = zeros(2, 5, length(subs));
    all_median_rt_js_sto = zeros(3, 5, length(subs));

    all_nan_rt_js  = zeros(1, 5, length(subs));
    all_nan_rt_js_vol = zeros(2, 5, length(subs));
    all_nan_rt_js_sto = zeros(3, 5, length(subs));
    
    for sub_id = 1:length(subs)
        load(fullfile(options.workDir, 'behav', sprintf('sub%03.0f', subs(sub_id)), strcat(sprintf('sub%03.0f', subs(sub_id)), '_responseData.mat')));
        
        sub_rt = [];
        sub_first_bpd = [];
        sub_longest_bpd = [];
        sub_longest_rt = [];

        for session_idx = 1:length(sessions)
            session_id = sessions(session_idx);
            
            session_rt = [];
            session_first_bpd = [];
            session_longest_bpd = [];
            session_longest_rt = [];
            
            for block_id = 1:length(blocks(sub_id, :))
                block_rt = [];
                block_first_bpd = [];
                block_longest_bpd = [];
                block_longest_rt = [];

                block = subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), :);
                block_vol = block(1, "volatility");

                mean_changes = [0; diff(table2array(subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "trueMean")))];
                mean_changes_onsets = find(mean_changes);

                rotation_changes = [0; diff(table2array(subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "shieldRotation")))];
                rotation_changes_onsets = [0; diff(rotation_changes)];

                onsets_idx = find(rotation_changes_onsets);
                onsets = nonzeros(rotation_changes_onsets)';

                onsets_idx_p = onsets_idx(onsets > 0);
                onsets_idx_n = onsets_idx(onsets < 0);

                for mean_change_id = 1:length(mean_changes_onsets)
                    if sign(mean_changes(mean_changes_onsets(mean_change_id))) == 1

                        onsets_idx_p_follow = onsets_idx_p(onsets_idx_p > mean_changes_onsets(mean_change_id) & onsets_idx_p < (mean_changes_onsets(mean_change_id) + 180));
                        if ~isempty(onsets_idx_p_follow)
                            block_rt(1, mean_change_id) = onsets_idx_p_follow(1)-mean_changes_onsets(mean_change_id);
                            block_rt(2, mean_change_id) = table2array(block_vol);
                            block_rt(3, mean_change_id) = table2array(subData(onsets_idx_p_follow(1) + size(mean_changes, 1)*(block_id - 1), "trueVariance"));
                            block_rt(4, mean_change_id) = abs(mean_changes(mean_changes_onsets(mean_change_id)));

                            first_bp_end = onsets_idx(onsets_idx > onsets_idx_p_follow(1));

                            if ~isempty(first_bp_end)
                                block_first_bpd(1, mean_change_id) = first_bp_end(1) - onsets_idx_p_follow(1);
                                block_first_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                                block_first_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                                block_first_bpd(4, mean_change_id) = block_rt(4, mean_change_id);
                            else
                                block_first_bpd(1, mean_change_id) = size(subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "trueMean"), 1) - onsets_idx_p_follow(1);
                                block_first_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                                block_first_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                                block_first_bpd(4, mean_change_id) = block_rt(4, mean_change_id);
                            end

                            bpd_follow = [];
                            for bp_follow = 1:length(onsets_idx_p_follow)
                                bp_end = onsets_idx(onsets_idx > onsets_idx_p_follow(bp_follow) & onsets_idx < (mean_changes_onsets(mean_change_id) + 180));
                                if ~isempty(bp_end)
                                    bpd_follow = [bpd_follow bp_end(1) - onsets_idx_p_follow(bp_follow)];
                                else
                                    bpd_follow = [bpd_follow, 0];
                                end
                            end
                            [block_longest_bpd(1, mean_change_id), longest_bpd_idx] = max(bpd_follow);
                            block_longest_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_bpd(4, mean_change_id) = block_rt(4, mean_change_id);

                            block_longest_rt(1, mean_change_id) = onsets_idx_p_follow(longest_bpd_idx) - mean_changes_onsets(mean_change_id);
                            block_longest_rt(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_rt(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_rt(4, mean_change_id) = block_rt(4, mean_change_id);
                        else
                            block_rt(1, mean_change_id) = 0;
                            block_rt(2, mean_change_id) = table2array(block_vol);
                            block_rt(3, mean_change_id) = table2array(subData(mean_changes_onsets(mean_change_id) + size(mean_changes, 1)*(block_id - 1), "trueVariance"));
                            block_rt(4, mean_change_id) = abs(mean_changes(mean_changes_onsets(mean_change_id)));

                            block_first_bpd(1, mean_change_id) = 0;
                            block_first_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_first_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_first_bpd(4, mean_change_id) = block_rt(4, mean_change_id);

                            block_longest_bpd(1, mean_change_id) = 0;
                            block_longest_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_bpd(4, mean_change_id) = block_rt(4, mean_change_id);

                            block_longest_rt(1, mean_change_id) = 0;
                            block_longest_rt(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_rt(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_rt(4, mean_change_id) = block_rt(4, mean_change_id);
                        end
                    else
                        onsets_idx_n_follow = onsets_idx_n(onsets_idx_n > mean_changes_onsets(mean_change_id) & onsets_idx_n < (mean_changes_onsets(mean_change_id) + 180));
                        if ~isempty(onsets_idx_n_follow)
                            block_rt(1, mean_change_id) = onsets_idx_n_follow(1)-mean_changes_onsets(mean_change_id);
                            block_rt(2, mean_change_id) = table2array(block_vol);
                            block_rt(3, mean_change_id) = table2array(subData(mean_changes_onsets(mean_change_id) + size(mean_changes, 1)*(block_id - 1), "trueVariance"));
                            block_rt(4, mean_change_id) = abs(mean_changes(mean_changes_onsets(mean_change_id)));
                            
                            first_bp_end = onsets_idx(onsets_idx > onsets_idx_n_follow(1));

                            if ~isempty(first_bp_end)
                                block_first_bpd(1, mean_change_id) = first_bp_end(1) - onsets_idx_n_follow(1);
                                block_first_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                                block_first_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                                block_first_bpd(4, mean_change_id) = block_rt(4, mean_change_id);
                            else
                                block_first_bpd(1, mean_change_id) = size(subData(subData.sessID == session_id & subData.blockID == blocks(sub_id, block_id), "trueMean"), 1) - onsets_idx_n_follow(1);
                                block_first_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                                block_first_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                                block_first_bpd(4, mean_change_id) = block_rt(4, mean_change_id);
                            end

                            bpd_follow = [];
                            for bp_follow = 1:length(onsets_idx_n_follow)
                                bp_end = onsets_idx(onsets_idx > onsets_idx_n_follow(bp_follow) & onsets_idx < (mean_changes_onsets(mean_change_id) + 180));
                                if ~isempty(bp_end)
                                    bpd_follow = [bpd_follow, bp_end(1) - onsets_idx_n_follow(bp_follow)];
                                else
                                    bpd_follow = [bpd_follow, 0];
                                end
                            end
                            [block_longest_bpd(1, mean_change_id), longest_bpd_idx] = max(bpd_follow);
                            block_longest_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_bpd(4, mean_change_id) = block_rt(4, mean_change_id);

                            block_longest_rt(1, mean_change_id) = onsets_idx_n_follow(longest_bpd_idx) - mean_changes_onsets(mean_change_id);
                            block_longest_rt(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_rt(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_rt(4, mean_change_id) = block_rt(4, mean_change_id);
                        else
                            block_rt(1, mean_change_id) = 0;
                            block_rt(2, mean_change_id) = table2array(block_vol);
                            block_rt(3, mean_change_id) = table2array(subData(mean_changes_onsets(mean_change_id) + size(mean_changes, 1)*(block_id - 1), "trueVariance"));
                            block_rt(4, mean_change_id) = abs(mean_changes(mean_changes_onsets(mean_change_id)));

                            block_first_bpd(1, mean_change_id) = 0;
                            block_first_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_first_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_first_bpd(4, mean_change_id) = block_rt(4, mean_change_id);

                            block_longest_bpd(1, mean_change_id) = 0;
                            block_longest_bpd(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_bpd(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_bpd(4, mean_change_id) = block_rt(4, mean_change_id);

                            block_longest_rt(1, mean_change_id) = 0;
                            block_longest_rt(2, mean_change_id) = block_rt(2, mean_change_id);
                            block_longest_rt(3, mean_change_id) = block_rt(3, mean_change_id);
                            block_longest_rt(4, mean_change_id) = block_rt(4, mean_change_id);
                        end
                    end
                end
                session_rt = [session_rt, block_rt];
                session_first_bpd = [session_first_bpd, block_first_bpd];
                session_longest_bpd = [session_longest_bpd, block_longest_bpd];
                session_longest_rt = [session_longest_rt, block_longest_rt];

            end

            sub_rt = [sub_rt, session_rt];
            sub_first_bpd = [sub_first_bpd, session_first_bpd];
            sub_longest_bpd = [sub_longest_bpd, session_longest_bpd];
            sub_longest_rt = [sub_longest_rt, session_longest_rt];

        end
        all_rt = [all_rt, sub_rt];
        all_first_bpd = [all_first_bpd, sub_first_bpd];
        all_longest_bpd = [all_longest_bpd, sub_longest_bpd];

        all_longest_rt = [all_longest_rt, sub_longest_rt];

        sub_rts(sub_id) = size(sub_longest_rt, 2);

        % Histogram of all RTs for each subject
%         figure
%         hist(sub_rt(1, :), unique(sub_rt(1, :)))
%         title("RT distribution - subject " + sub_id)
% 
%         vol_rt = sub_rt(2, :) == 1;
%         sta_rt = sub_rt(2, :) == 0;
% 
%         figure
%         subplot(1, 2, 1)
%         hist(sub_rt(1, vol_rt), unique(sub_rt(1, vol_rt)))
%         title("Vol RT distribution - subject " + sub_id)
% 
%         subplot(1, 2, 2)
%         hist(sub_rt(1, sta_rt), unique(sub_rt(1, sta_rt)))
%         title("Sta RT distribution - subject " + sub_id)

        % Histogram of all first BPDs for each subject
%         figure
%         hist(sub_first_bpd(1, :), unique(sub_first_bpd(1, :)))
%         title("First BPD distribution - subject " + sub_id)
% 
%         vol_first_bpd = sub_first_bpd(2, :) == 1;
%         sta_first_bpd = sub_first_bpd(2, :) == 0;
% 
%         figure
%         subplot(1, 2, 1)
%         hist(sub_first_bpd(1, vol_first_bpd), unique(sub_first_bpd(1, vol_first_bpd)))
%         title("Vol first BPD distribution - subject " + sub_id)
% 
%         subplot(1, 2, 2)
%         hist(sub_first_bpd(1, sta_first_bpd), unique(sub_first_bpd(1, sta_first_bpd)))
%         title("Sta first BPD distribution - subject " + sub_id)

        for i = 1:size(sub_first_bpd, 2)
            if sub_first_bpd(4, i) > 60
                sub_first_bpd(4, i) = 360 - sub_first_bpd(4, i);
            end
        end

        %figure
        %title("First BPD distribution - subject " + sub_id)
        for jump = 1:length(jump_sizes)
            jump_first_bpd = sub_first_bpd(4, :) == jump_sizes(jump);
            half_bpd = sub_first_bpd(1, jump_first_bpd) >= jump_sizes(jump)/2;
            half_bpd = sum(half_bpd);

%             subplot(1, length(jump_sizes), jump)
%             hist(sub_first_bpd(1, jump_first_bpd), unique(sub_first_bpd(1, jump_first_bpd)))
%             title("Ratio = " + half_bpd + "/" + sum(jump_first_bpd))
        end

        for i = 1:size(sub_longest_bpd, 2)
            if sub_longest_bpd(4, i) > 60
                sub_longest_bpd(4, i) = 360 - sub_longest_bpd(4, i);
            end
        end

        for i = 1:size(sub_longest_rt, 2)
            if sub_longest_rt(4, i) > 60
                sub_longest_rt(4, i) = 360 - sub_longest_rt(4, i);
            end
        end

%         figure
        %title("Longest BPD distribution - subject " + sub_id)
        for jump = 1:length(jump_sizes)
            jump_longest_bpd = sub_longest_bpd(4, :) == jump_sizes(jump);
            half_bpd = sub_longest_bpd(1, jump_longest_bpd) >= jump_sizes(jump)/2;
            half_bpd = sum(half_bpd);

%             subplot(1, length(jump_sizes), jump)
%             hist(sub_longest_bpd(1, jump_longest_bpd), unique(sub_longest_bpd(1, jump_longest_bpd)))
%             title("Ratio = " + half_bpd + "/" + sum(jump_longest_bpd))
%             xlim([0 200])

        end

        sub_longest_rt(1, (sub_longest_bpd(1, :) == 0)) = NaN;

        for js = 1:length(jump_sizes)
            jump_longest_rt = sub_longest_rt(4, :) == jump_sizes(js);
            all_median_rt_js(1, js, sub_id) = nanmedian(sub_longest_rt(1, jump_longest_rt));
            all_nan_rt_js(1, js, sub_id) = sum(isnan(sub_longest_rt(1, jump_longest_rt)));
            for vol_value = 1:length(vol)
                jump_vol_longest_rt = (sub_longest_rt(4, :) == jump_sizes(js)) & (sub_longest_rt(2, :) == vol(vol_value));
                all_median_rt_js_vol(vol_value, js, sub_id) = nanmedian(sub_longest_rt(1, jump_vol_longest_rt));
                all_nan_rt_js_vol(vol_value, js, sub_id) = sum(isnan(sub_longest_rt(1, jump_vol_longest_rt)));
            end
            for sto_value  = 1:length(sto)
                jump_sto_longest_rt = (sub_longest_rt(4, :) == jump_sizes(js)) & (sub_longest_rt(3, :) == sto(sto_value));
                all_median_rt_js_sto(sto_value, js, sub_id) = nanmedian(sub_longest_rt(1, jump_sto_longest_rt));
                all_nan_rt_js_sto(sto_value, js, sub_id) = sum(isnan(sub_longest_rt(1, jump_sto_longest_rt)));
            end
        end
    end
    reshaped_rt_sto = reshape(all_median_rt_js_sto, 1, length(sto)*length(jump_sizes), length(subs));

    data = table(...
    squeeze(reshaped_rt_sto(1, 1, :)), squeeze(reshaped_rt_sto(1, 2, :)), squeeze(reshaped_rt_sto(1, 3, :)), ...
    squeeze(reshaped_rt_sto(1, 4, :)), squeeze(reshaped_rt_sto(1, 5, :)), squeeze(reshaped_rt_sto(1, 6, :)), ...
    squeeze(reshaped_rt_sto(1, 7, :)), squeeze(reshaped_rt_sto(1, 8, :)), squeeze(reshaped_rt_sto(1, 9, :)), ...
    squeeze(reshaped_rt_sto(1, 10, :)), squeeze(reshaped_rt_sto(1, 11, :)), squeeze(reshaped_rt_sto(1, 12, :)), ...
    squeeze(reshaped_rt_sto(1, 13, :)), squeeze(reshaped_rt_sto(1, 14, :)), squeeze(reshaped_rt_sto(1, 15, :)), ...
    'VariableNames', ...
    {'jumpSize1stocha1','jumpSize1stocha2','jumpSize1stocha3',...
    'jumpSize2stocha1','jumpSize2stocha2','jumpSize2stocha3', ...
    'jumpSize3stocha1','jumpSize3stocha2','jumpSize3stocha3',...
    'jumpSize4stocha1','jumpSize4stocha2','jumpSize4stocha3',...
    'jumpSize5stocha1','jumpSize5stocha2','jumpSize5stocha3',...
    }); % and more for more jump sizes

    withinFactors = table(...
        categorical([1 1 1 2 2 2 3 3 3 4 4 4 5 5 5])',... % all levels of jumpSize
        categorical([1 2 3 1 2 3 1 2 3 1 2 3 1 2 3])',... % all levels of stochasticity
        'VariableNames',{'jumpSize','stochasticity'});
    
    rm = fitrm(data, ... % we have to name all variables and say we'll predict them by the group factor "1" (because we have no group factor)
        ['jumpSize1stocha1,jumpSize1stocha2,jumpSize1stocha3,jumpSize2stocha1,jumpSize2stocha2,jumpSize2stocha3,jumpSize3stocha1,jumpSize3stocha2,jumpSize3stocha3,jumpSize4stocha1,jumpSize4stocha2,jumpSize4stocha3,jumpSize5stocha1,jumpSize5stocha2,jumpSize5stocha3~1'],... 
        'WithinDesign', withinFactors);
    
    % ['RTs ~ jumpSize, volatility, jumpSize*volatility']
    
    %resultsTable = ranova(rm)
    resultsTable = ranova(rm, 'WithinModel', 'jumpSize*stochasticity-1')

%     all_nan_rt_js
%     all_nan_rt_js_vol
%     all_nan_rt_js_sto
end