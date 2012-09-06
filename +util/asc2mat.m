% Sam Xi
% 3/18/10
% ASC2MAT
%
% Converts TCSPC ascii output data to a MATLAB struct. It performs a Hough
% transform on the data and stores that array in the struct to act as a
% signature of that spectrum.
% Format of the structure is:
%
%             graph:  [1 x m double]
%             keySet: [1 x n double]
%             houghSignature: [array of doubles]
%             scale_factor: integer
%             ic : [array of doubles]
%   `         ex : [array of doubles]
%             em : [array of doubles]
%
% SYNTAX:
%
%           out = asc2mat(array, start_time, end_time)
%                 array = raw ascii data
%                 period = period of time between laser pulses.
%                 end_time = end time of data collection period in ns
%                 time_div = width of a time bin.
%                 filename = name of the file
%           out = array of structures

function out = asc2mat(array, period, time_div, filename)
import hough.*;

% parse name
grid_type = regexp(filename, '.*(?=_ic)', 'match');
% Originally I separated numbers by commas but I changed those to
% underscores.
ic = regexp(filename, '(?<=ic)([\d|,]*)', 'match');
ex = regexp(filename, '(?<=i)([\d|,]*)', 'match');
%em = 620;  % Temporary hard coding for filenames all missing emission info.
em = regexp(filename, '(?<=em)([\d|,]*)', 'match');
keySet = linspace(0, period, length(array));
% Take the log of the time domain response and remove zeros.
keySet(array==0) = [];
array(array==0) = [];
% These are terrible variable names, but I really only care about H.
[P L I T R H F factor] = getLifetimesHough(keySet, array, time_div, 3);
Hmax = max(H);
out = struct('graph', array, 'hough_sig', Hmax, 'theta_range', T, ...
             'scale_factor', factor, 'time_div', time_div, 'period', period, ...
             'ic', ic, 'ex', ex, 'em', em, 'grid_type', grid_type);
end
