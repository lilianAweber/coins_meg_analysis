function [ maxCorr_within, bestLag_within, maxCorr_between, bestLag_between, ...
    R, R_bounds] ...
    = crdm_reliability( dataMatrix, maxLag )
%CRDM_RELIABILITY This function assess the shape reliability of the
%responses measured from different participants in different sessions. The
%input dataMatrix should be structured as follows:
% nParticipants x nSessions x nSamples, where nSamples is the length of the
% measured response per session and participant.
% It outputs the distributions of maximum cross-correlation and the lags of
% this over session-comparisons (within-subject) and for pairing sessions
% from different participants (between-subject). These can be compared to
% get an estimate of the idiosyncracy of the measured response.
% Additionally, the function also computes the ICC per sample of the waveform
% and its confidence bounds.
% Number of maxXcorr and bestLag within: nSessions! / (2! (5-2)!)
% Number of maxXcorr and bestLag between: nSessions * (nSubjects-1) *
% nSessions

[nSubjects, nSessions, nSamples] = size(dataMatrix);
if nargin < 2
    maxLag = nSamples-1;
end

maxCorr_within = NaN(nSubjects, nchoosek(nSessions, 2));
bestLag_within = NaN(nSubjects, nchoosek(nSessions, 2));

maxCorr_between = NaN(nSubjects, nSessions*(nSubjects -1)*nSessions);
bestLag_between = NaN(nSubjects, nSessions*(nSubjects -1)*nSessions);

for iSubject = 1: nSubjects
    % Within-subject
    iPair = 0;
    for iSess = 1: nSessions-1
        for iPairedSess = iSess+1 : nSessions
            iPair = iPair + 1;
            [crossCorr, lags] = xcorr(...
                squeeze(dataMatrix(iSubject, iSess, :)), ...
                squeeze(dataMatrix(iSubject, iPairedSess, :)), ...
                maxLag, 'coeff');
            
            [maxCorr_within(iSubject, iPair), maxIdx] = max(crossCorr);
            bestLag_within(iSubject, iPair) = lags(maxIdx);
        end
    end
    
    % Between-subject
    otherSubjects = 1: nSubjects;
    otherSubjects(iSubject) = [];
    
    iPair = 0;
    for iSess = 1: nSessions
        for iOtherSub = 1: numel(otherSubjects)
            otherSubId = otherSubjects(iOtherSub);
            for iOtherSess = 1: nSessions
                iPair = iPair + 1;
                [crossCorr, lags] = xcorr(...
                    squeeze(dataMatrix(iSubject, iSess, :)), ...
                    squeeze(dataMatrix(otherSubId, iOtherSess, :)), ...
                    maxLag, 'coeff');
            
                [maxCorr_between(iSubject, iPair), maxIdx] = max(crossCorr);
                bestLag_between(iSubject, iPair) = lags(maxIdx);
            end
        end
    end
end

R = NaN(nSamples, 1);
% ICC per sample
for iSample = 1: nSamples
    [R(iSample) R_bounds(iSample, :)] = icc21(squeeze(dataMatrix(:, :, iSample)));
end
bounds2 = [R-R_bounds(:,1) R_bounds(:,2)-R];
%{
figure;
shadedErrorBar2(1:numel(R), R, bounds2, 'lineprops', '-b');


figure; 
subplot(2, 2, 1);
plot(maxCorr_within, '*')
ylim([0 1]);
ylabel('Max xcorr between sessions');
xlabel('Subject number');
title('Shape similarity WITHIN subjects')

subplot(2, 2, 2);
plot(maxCorr_between, '*')
ylim([0 1]);
ylabel('Max xcorr between sessions');
xlabel('Subject number');
title('Shape similarity BETWEEN subjects')

subplot(2, 2, 3);
plot(bestLag_within, '*')
ylim([-maxLag maxLag]);
ylabel('Best lag');
xlabel('Subject number');
title('Best lags WITHIN subjects')

subplot(2, 2, 4);
plot(bestLag_between, '*')
ylim([-maxLag maxLag]);
ylabel('Best lag');
xlabel('Subject number');
title('Best lags BETWEEN subjects')
%}
