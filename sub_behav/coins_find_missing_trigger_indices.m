function idxMissingTrigs = coins_find_missing_trigger_indices( megTrigs, behavTrigs )

% max time delay acceptable between MEG and behav trigger - initial value,
% and the baseline value (onto which we add the average delay later)
initialThresh = 0.01;
% number of delays to average over for the max time delay acceptable
nDelaysToAverageOver = 10;

iBehav = 0;
% loop through all MEG triggers (the smaller number of triggers)
for iMeg = 1: numel(megTrigs)
    % per default, use the same index for the behav trigger
    iBehav = iBehav + 1;
    
    % determine the current threshold to compare the delay to
    if iMeg < nDelaysToAverageOver
        % we don't have enough delays yet, so we use a default initial value
        threshold = initialThresh;
    else
        % once we have enough delays, we use the average over the last 10
        % as the norm
        threshold = mean(delays(end-nDelaysToAverageOver+1: end)) + initialThresh;
    end
    
    
    delays(iMeg) = megTrigs(iMeg) - behavTrigs(iBehav);
    if delays(iMeg) > threshold
        idxMissingTrigs = [idxMissingTrigs iBehav];
        iBehav = iBehav + 1;
        delays(iMeg) = megTrigs(iMeg) - behavTrigs(iBehav);
        if delays(iMeg) > threshold
            warning(['removing just one behav trigger did not fix the problem at MEG idx ' num2str(iMeg)])
        end
    end
end

corrTrigs = behavTrigs;
corrTrigs(idxMissingTrigs) = [];
if numel(corrTrigs) ~= numel(megTrigs)
    error('Still not the same number of jumps in MEG and behav');
end    

end