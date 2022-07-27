function [ volValues, staValues, h, p, ci, stats ] = ...
    coins_compare_performance_across_conditions( perform, subFieldName )

volValues = [];
staValues = [];
for iSess = 1: 4
    for iBlock = 1:4
        if isfield(perform{iSess,iBlock}, subFieldName)
            if perform{iSess,iBlock}.volatility == 1
                volValues = [volValues; perform{iSess,iBlock}.(subFieldName)];
            else
                staValues = [staValues; perform{iSess, iBlock}.(subFieldName)];
            end
        end
    end
end
nDiff = numel(staValues) - numel(volValues);
if nDiff > 0
    staValues(end-nDiff+1:end) = [];
elseif nDiff < 0
    volValues(end+nDiff+1:end) = [];
end

[h,p,ci,stats] = ttest(volValues, staValues);

if p>1
    figure;
    plot(1, volValues, 'o'); 
    hold on;
    plot(2, staValues, 'o');
    xlabel('condition')
    xlim([0 3]);
    xticks([1 2])
    xticklabels({'volatile', 'stable'});
    ylabel(subFieldName);
    title([subFieldName ' across conditions'])
end
end





















