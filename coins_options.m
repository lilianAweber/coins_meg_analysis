function options = coins_options
%COINS_OPTIONS Sets all options for the analysis of behavioural and MEG
%data from the continuous inference study (COINS).
%   OUT:    options         - the struct that holds all analysis options

%%%---- ENTER YOUR PATHS HERE -----------------------------------------%%%
% This is where we are now (where the code is to be found):
options.codeDir = fileparts(mfilename('fullpath'));
% This is the base root for both raw data and analysis:
%options.mainDir = '/media/lil/copyCrdk/COINS';
%options.mainDir = '/home/lil/projects/ccn/ContinuousValue/rotation/COINS';
options.mainDir = '/Users/lilian/Projects/COINS/';
options.rawDir = fullfile(options.mainDir, 'rawData');
options.workDir = fullfile(options.mainDir, 'analysis');
%%%--------------------------------------------------------------------%%%

options.subjectIDs = [1:22];
options.pilotIDs = {'Ryan', 'Caroline', 'Karen', 'CarolineY'};

options.conditionLabels = {'Stable', 'Volatile'};
options.conditionIDs = 0:1;

options.behav.flagLoadData = 1;
options.behav.flagPerformance = 1;
options.behav.flagKernels = 1;
options.behav.flagAdjustments = 1;
options.behav.flagReactionTimes = 1;

options.behav.fsample = 60;
options.behav.movAvgWin = 100;
options.behav.minResponseDistance = 20;
options.behav.minStepSize = 10;
options.behav.kernelPreSamples = 6*options.behav.fsample;%2.5*options.behav.fsample;
options.behav.kernelPostSamples = 1*options.behav.fsample;
options.behav.flagBaselineCorrectKernels = 0;
options.behav.nSamplesKernelBaseline = 1.5*options.behav.fsample;
options.behav.adjustPreSamples = 100;
options.behav.adjustPostSamples = 500;
options.behav.flagNormaliseAdjustments = 1;
options.behav.meanJumpSet = [-3 -2 -1.5 -1 -0.5 0.5 1 1.5 2 3]*20*pi/180;
options.behav.varianceSet = [10 20 30]*pi/180;
options.behav.maxRtSamples = 2*options.behav.fsample; % distance between jump sizes is min=2s in volatile conditions

options.meg.triggers = coins_meg_trigger_list;

