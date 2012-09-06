% Sam Xi
% 2/26/11
% Main experiment analysis script
% This script will create a time-frequency graph of chromophore fluorescent
% events.
%
% USAGE:
%
%  [total time_data graph] = retsim(trace, dyes, tbin, laserinterval, show_graph)
%
%   Args:
%     trace: filepath to the trace file.
%     dyes: cell list of dyes (in abbreviated form) used. This is specified in
%				the experiment file. The order of the dyes must match that in the
%				experiment file.
%     tbin: size of time intervals in which flourescent events
%       will be grouped together.
%     laserInterval: length of time that elapses between two
%       cycles of the laser pulse sequences.
%     show_graph: An optional integer. 1 if the generated system response graph
%       should be plotted and displayed. 0 otherwise.
%
%		Returns:
%			totalExcitations: the total number of fluorescence events.
%			time_data: A mapping of time bins and dyes to the number of excitation
%				events. For instance, the mapping (10_1, 5) means that at the 10th time
%				bin, for the 1st dye, there were 5 excitation events.
%     graph: 3-dimensional matrix containing the time-frequency plot of
%				fluorescent activity over a single laser pulse. Data is organized by
%				time on one axis, wavelength on the other, and the value of the element
%				at that location is the intensity of the fluorescence from the
%				chromophore structure at that time and wavelength.
function [totalExcitations time_data graph] = retsim(trace, dyes, tbin, ...
                                                     laserInterval, show_graph)
if (nargin < 4)
  error('Not enough parameters')
elseif (nargin > 5)
  error('Too many arguments.')
end
if (nargin == 4)
  show_graph = 0;  % By default, do not show_graph.
end

format short e;

%% Load emission spectra of the dyes.
dyes = char(dyes);
dyeDBpath = 'D:\Documents\My Dropbox\Dwyer\02.22.11\DB\Dyes\list of dyes.txt';
dyelist = 'D:\Documents\My Dropbox\Dwyer\02.22.11\DB\Dyes';
dyeMap = java.util.HashMap();
for i = 1:size(dyes, 1)
	% Not all versions of MATLAB support associative arrays, so we use Java
	% HashMaps instead.
	dyeName = deblank(dyes(1,:));
	loadedDye = loadDye(dyeName, dyelist, dyeDBpath);
	loadedDye = zeroDye(loadedDye, 1, 1000);
	dyeMap.put(i, loadedDye);
%  eval(sprintf('dye_%d = loadDye(''%s'', ''%s'', ''%s'');', ...
%               i, deblank(dyes(1,:)), dyelist, dyeDBpath));
%  eval(sprintf('dye_%d = zeroDye(dye_%d, 1, 1000);', i, i));
end

%% Parse the trace file.
trace_data = loadLog(trace);
[totalExcitations time_data keySet] = catdata(trace_data, tbin, laserInterval);
graph = zeros(length(keySet), 1000);

%% Build the combined frequency and time domain system response graph.
fprintf('Building graph\n');
for dyeN = 1:length(dyes)
  for w = 1:length(keySet)
    key = strcat(num2str(keySet(w)), '_', num2str(dyeN));
    weight = time_data.get(key);
    if (~isempty(weight))
      % MATLAB does pointer assignments here, not copying data.
	    curDye = dyeMap.get(dyeN);
			% eval(sprintf('curDye = dye_%d;', dyeN));
      graph(w, :) = graph(w,:)+weight * flipud(curDye(:, 2)');
    end
  end
end
graph=graph';
if (show_graph == 1)
  graphspectra(graph, keySet, tbin, 'Response of Chromophores to Laser Impulse');
end

%% Export the output of this function to a file.
% Trace filenames look like input(x   y).log. They belong under a folder that
% specifies the experiment's initial conditions. These all belong under a folder
% called "trace logs". Regexps convert this directory structure to a variable 
% name that holds both the initial conditions and the input combinations.
% Example variable name: ic0_20_i50_70 means that (0, 20) is the initial
% condition and (50, 70) is the input combination.
% The exported MATLAB binary file holds a struct containing the variables
% time_data, graph, keySet, and totalExcitations.
outputdir = regexp(trace, '.*(?=trace logs)', 'match');
configName = regexp(trace, 'ic(.*)\\input(.*)(?=\.log)', 'match');
configName = regexprep(configName, '[ -\\]', '_')
configName = regexprep(configName, '[()]', '')
%configName = strrep(configName, '\', '_');
%configName = strrep(configName, '  ', '_');
%configName = strrep(configName, '-', '_');
%configName = strrep(configName, '(', '');
%configName = strrep(configName, ')', '');
configName = strrep(configName, 'input', 'i');
outputdir = outputdir{1};
%configName = configName{1};
output = struct('time_data', time_data, 'graph', graph, 'keySet', keySet, ...
								'totalExcitations', totalExcitations);
%eval(sprintf('%s = struct(''time_data'', time_data, ''graph'', graph, ''keySet'', keySet, ''totalExcitations'', totalExcitations);', configName));
eval(sprintf('save ''%s.mat'' output;', strcat(outputdir, ...
						 'pattern1_spectrum_decryption\', configName)));
%eval(sprintf('save ''%s.mat'' ''%s'';', strcat(outputdir, 'pattern1_spectrum_decryption\', configName), configName));
end
