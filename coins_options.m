function options = coins_options
%COINS_OPTIONS Sets all options for the analysis of behavioural and MEG
%data from the continuous inference study (COINS).
%   OUT:    options         - the struct that holds all analysis options

%%%---- ENTER YOUR PATHS HERE -----------------------------------------%%%
% This is where we are now (where the code is to be found):
options.codeDir = fileparts(mfilename('fullpath'));
% This is the base root for both raw data and analysis:
%options.mainDir = '/media/lil/copyCrdk/COINS';
options.mainDir = '/home/lil/projects/ccn/ContinuousValue/rotation/COINS';
options.rawDir = fullfile(options.mainDir, 'rawData');
options.workDir = fullfile(options.mainDir, 'analysis');
%%%--------------------------------------------------------------------%%%

options.subjectIDs = [1];
options.pilotIDs = {'Ryan', 'Caroline', 'Karen', 'CarolineY'};

options.conditionLabels = {'Stable', 'Volatile'};
options.conditionIDs = 0:1;

options.behav.fsample = 60;
options.behav.movAvgWin = 100;
options.behav.kernelPreSamples = 150;
options.behav.kernelPostSamples = 150;

