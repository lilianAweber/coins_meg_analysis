function betas = coins_compute_GLM( X, Y, options )

if options.behav.flagNormaliseEvidence
    X = (X - nanmean(X))./nanstd(X);
    Y = (Y - mean(Y))./std(Y);
end
% only keep trials without NaNs in design matrix
toRemove = isnan(X(:,1));
X(toRemove,:) = [];
Y(toRemove) = [];
nTrials = size(X,1);

pDM = geninv(X); %pseudoinvesrse of design matrix    
betas = pDM*Y;

end