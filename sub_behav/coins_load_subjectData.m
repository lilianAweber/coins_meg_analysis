function subData = coins_load_subjectData( details )
%COINS_LOAD_SUBJECTDATA Loads the behavioural data of all sessions of one
%participant in the COINS study.

if str2num(details.subjName(end-1:end)) < 10
    dataFlag = 'initial';
else
    dataFlag = 'later';
end

subData = [];
for iSess = 1: details.nSessions
    sessData = coins_load_savedData(details.raw.behav.sessionFileNames{iSess}, dataFlag);
    sessData.sessID = iSess*ones(size(sessData, 1), 1);
    subData = [subData; sessData];
end

% make blockID variable indicate the position of the block within the
% session, blockIDall the block number across sessions, and blockIDorig the
% original blockID
subData.blockIDorg = subData.blockID;
newID = NaN(numel(subData.blockID),1);

blockCount = 1;
for i=2:numel(subData.blockID)
    if subData.blockID(i) ~= subData.blockID(i-1)
        blockCount = blockCount +1;
    end
    newID(i) = blockCount;
end

subData.blockIDall = newID;
newID(newID>12) = newID(newID>12) - 12;
newID(newID>8) = newID(newID>8) - 8;
newID(newID>4) = newID(newID>4) - 4;

subData.blockID = newID;