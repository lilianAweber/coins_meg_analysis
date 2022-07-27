function movexp = moving_exponential_kernel( input, horizon, decay )
%MOVING_EXPONENTIAL_KERNEL Calculates a moving average with exponentially
%downweighted samples into the past.

x = 0: horizon-1;
expWeight = exp(decay * x);
expWeight = expWeight/expWeight(end);
figure; plot(x, expWeight);

if size(input, 2) > size(input, 1)
    input = input(:);
end
padInput = [NaN(horizon, 1); input];
figure; plot(input)

for smp = horizon: numel(padInput)
    movexp(smp - horizon + 1) = nansum(expWeight .* padInput(smp-horizon+1: smp)')/sum(expWeight);
end
hold on; plot(movexp);

end