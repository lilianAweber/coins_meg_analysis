function coins_subjectPerformance( details, options )
%COINS_SUBJECTPERFORMANCE Computes basic performance indices for all blocks
%of all sessions of one participant in the COINS study

for iSess = 1: details.nSessions
    for iBlock = 1: 4
        blockData = subData(subData.sessID == iSess & subData.blockID == iBlock, :);
        fh = coins_plot_blockData(blockData, options);
        savefig(fh, details.analysis.behav.blockFigures{iSess, iBlock});
        
        [stim{iSess, iBlock}, perform{iSess, iBlock}] = ...
            coins_compute_trackingPerformance(blockData, options);
    end
end

close all
save(details.analysis.behav.performance, 'stim', 'perform');

end