function savedData = coins_load_savedData( filename )
%COINS_LOAD_SAVEDDATA Loads in a csv spreadsheet of one session of one
%participant in the COINS study.

delimiter = ',';
startRow = 2;

% Current data entries in each line of the csv output:
% column1: blockID - double (%f)
% column2: currentFrame - double (%f)
% column3: laserRotation - double (%f)
% column4: shieldRotation - double (%f)
% column5: shieldDegrees - double (%f)
% column6: currentHit - categorical (%C)
% column7: totalReward - double (%f)
% column8: sendTrigger - categorical (%C)
% column9: triggerValue - double (%f)
% column10: trueMean - double (%f)
% column11: trueVariance - double (%f)
% column12: volatility - categorical (%C)
% column13: eyepositionX - string (%s)
% column14: eyepositionX - string (%s)
% We are currently treating the eyeposition as a string due to unfortunate
% formatting.
formatSpec = '%f%f%f%f%f%C%f%C%f%f%f%f%s%s%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', ...
    'string', 'EmptyValue', NaN, 'HeaderLines', startRow-1, 'ReturnOnError', ...
    false, 'EndOfLine', '\r\n');
fclose(fileID);

% Create output variable
savedData = table(dataArray{1:end-1}, 'VariableNames', ...
    {'blockID','currentFrame','laserRotation','shieldRotation',...
    'shieldDegrees','currentHit','totalReward','sendTrigger',...
    'triggerValue','trueMean','trueVariance','volatility',...
    'eyepositionX','eyepositionY'});

end
