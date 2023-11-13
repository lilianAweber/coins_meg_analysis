function fh = coins_plot_subject_kernels_by_volatility( staKernels, ...
    volKernels, nResponses, details, options )

col = coins_colours;

fh = figure;
timeAxis = [-options.behav.kernelPreSamples : ...
    options.behav.kernelPostSamples]/options.behav.fsample;

volaKerns = nanmean(squeeze(nanmean(volKernels(:, :, 1, :),1)),1);
stabKerns = nanmean(squeeze(nanmean(staKernels(:, :, 1, :),1)),1);
if options.behav.flagBaselineCorrectKernels
    volaBase = nanmean(volaKerns(1, 1:options.behav.nSamplesKernelBaseline));
    stabBase = nanmean(stabKerns(1, 1:options.behav.nSamplesKernelBaseline));
    %volaBase = max(volaKerns);
    %stabBase = max(stabKerns);
    volaKerns = volaKerns - volaBase;
    stabKerns = stabKerns - stabBase;
    %volaKerns = volaKerns/volaBase;
    %stabKerns = stabKerns/stabBase;
end    

subplot(2, 1, 1); 
% signed PEs preceding movements
plot(timeAxis, volaKerns, 'color', col.volatile)
hold on
plot(timeAxis, stabKerns, 'color', col.stable)
xlabel('time (s) around button press')
ylabel('signed PE')
yline(0)
title([details.subjName ': Average signed PEs leading up to shield movement onset'])
legend(['volatile blocks (N=' num2str(nResponses.volatile.move) ')'], ...
    ['stable blocks (N=' num2str(nResponses.stable.move) ')'], ...
    'location', 'northwest');
%xLims = xlim;
%yLims = ylim;
%text(xLims(1)+0.5, mean(yLims)+3, details.subjName, "FontWeight","bold")
%text(xLims(1)+0.5, mean(yLims), ['Median step size: ' num2str(median(steps.stepSizes))])
%text(xLims(1)+0.5, mean(yLims)-3, ['Avg small/unified steps: ' num2str(mean(steps.smallSteps)) '/' num2str(mean(steps.unifSteps))])

volaKernsUp = nanmean(squeeze(nanmean(volKernels(:, :, 5, :),1)),1);
stabKernsUp = nanmean(squeeze(nanmean(staKernels(:, :, 5, :),1)),1);
volaKernsDown = nanmean(squeeze(nanmean(volKernels(:, :, 6, :),1)),1);
stabKernsDown = nanmean(squeeze(nanmean(staKernels(:, :, 6, :),1)),1);


subplot(2, 1, 2); 
% abs PEs preceding size updates
plot(timeAxis, volaKernsUp)
hold on
plot(timeAxis, volaKernsDown)
plot(timeAxis, stabKernsUp)
plot(timeAxis, stabKernsDown)
xlabel('time (s) around button press')
ylabel('absolute PE')
title('Average absolute PEs leading up to shield size update')
legend(['volatile blocks: up (N=' num2str(nResponses.volatile.sizeUp) ')'], ...
    ['volatile blocks: down (N=' num2str(nResponses.volatile.sizeDown) ')'], ...
    ['stable blocks: up (N=' num2str(nResponses.stable.sizeUp) ')'], ...
    ['stable blocks: down(N=' num2str(nResponses.stable.sizeDown) ')'], ...
    'location', 'northwest');


end
