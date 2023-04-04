function coins_group_performance( options )

subjectIDs = 1:9;

for iSub = 1: numel(subjectIDs)
    details = coins_subjects(subjectIDs(iSub), options);
    load(details.analysis.behav.performance, 'perform');
    A = cell2mat(perform);
    grpPerf(iSub, :) = [A(:).reward];
    grpCond(iSub, :) = [A(:).volatility];
    grpMeanSize(iSub, :) = [A(:).meanStdev];
    grpSizeTrackBias(iSub, :) = [A(:).sizeTrackBias];
end
    
avgPerf = mean(grpPerf,2);
sumPerf = sum(grpPerf,2);

figure; plot(grpMeanSize')
ylabel('mean shield size')
xlabel('block number')
legendCell = cellstr(num2str([1:9]', 'sub%-d'));
legend(legendCell)

for iSub = 1: numel(subjectIDs)
    volSize(iSub) = mean(grpMeanSize(iSub, grpCond(iSub,:)==1));
    staSize(iSub) = mean(grpMeanSize(iSub, grpCond(iSub,:)==0)); 
end

figure;
plot(1, staSize, '*')
hold on
plot(2, volSize, '*');
xlim([0 3])

figure; 
plot([volSize' staSize']')


end