    % Sam Xi
% 2/26/11
% Main experiment analysis script
% This script will create a time-frequency graph of chromophore fluorescent
% events. 
%
% USAGE: 
%
%       [total time_data graph] = retsim(trace, dyes, tbin, laserInterval)
%
%               trace : filepath to the trace file.
%               dyes  : cell list of dyes (in abbreviated form) used. They
%                       must be listed in the order that they were declared
%                       in the experiment file, because the trace file does
%                       not provide specific dye information.
%               graph : 2-dimensional matrix containing the time-frequency
%                       plot of fluorescent activity over a single laser
%                       pulse. Data is organized by time on one axis,
%                       wavelength on the other, and the value of the
%                       element at that location is the intensity of the
%                       fluorescence from the chromophore structure at that
%                       time and wavelength.
%               laserInterval: length of time that elapses between two
%                       cycles of the laser pulse sequences.
%       analysis parameters : these are arguments required to properly
%               categorize the fluorescent events by time delay after
%               excitation.
%               tbin  : size of time intervals in which flourescent events
%                   will be grouped together.
%               laserInterval : time between the beginning of two pulses.
%


function [totalExcitations time_data graph] = mmaster(trace, plot)

if (nargin < 4)
    error('Not enough parameters to properly analyze the data.')
elseif (nargin > 5)
    error('Too many arguments. Analysis parameters are to be grouped in a vector.')
end
if (nargin == 4)
    plot = 1; % prompt for graphing my default
end
format short e;
dyes = char(dyes);
dyelist = 'D:\Documents\My Dropbox\Dwyer\02.22.11\DB\Dyes\list of dyes.txt';
dyeDBpath = 'D:\Documents\My Dropbox\Dwyer\02.22.11\DB\Dyes';

time_data = loadsdt(trace);
%keySet = getKeys(time_data);


if (plot == 1)
   graphspectra(graph, keySet, tbin, 'Response of Chromophores to Laser Impulse'); 
end

% save data as as a structure and export to the appropriate directory.
outputdir = regexp(trace, '.*(?=trace logs)', 'match');
configName = regexp(trace, 'ic(.*)\\input(.*)(?=\.log)', 'match');
configName = strrep(configName, '\', '_');
configName = strrep(configName, '  ', '_');
configName = strrep(configName, '-', '_');
configName = strrep(configName, '(', '');
configName = strrep(configName, ')', '');
configName = strrep(configName, 'input', 'i');
outputdir = outputdir{1};
configName = configName{1};
eval(sprintf('%s = struct(''time_data'', time_data, ''graph'', graph, ''keySet'', keySet, ''totalExcitations'', totalExcitations);', configName));
eval(sprintf('save ''%s.mat'' ''%s'';', strcat(outputdir, 'pattern1_spectrum_decryption\', configName), configName));
end
