function subData = coins_load_subjectData( details )
%COINS_LOAD_SUBJECTDATA Loads the behavioural data of all sessions of one
%participant in the COINS study.

subData = [];
for iSess = 1: details.nSessions
    sessData = coins_load_savedData(details.raw.behav.sessionFileNames{iSess});
    sessData.sessID = iSess*ones(size(sessData, 1), 1);
    subData = [subData; sessData];
end

end