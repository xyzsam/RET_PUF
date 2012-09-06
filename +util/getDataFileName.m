% GETDATAFILENAME   Filenames for data processing.	
% Returns the filename for the MATLAB data file corresponding to the
% provided parameters.
%
% SYNTAX: fileName = getDataFileName(initialCondition, inputCombination,
%                                    grid_type, emission)
%
%   fileName = name of the binary file that was loaded.
%   initialCondition = array specifying the initial conditions.
%   inputCombination = array specifying the input combination of lasers.
%   grid_type = string. grid label (sa1, sa2, etc).
%   emission = array specifying observation wavelengths.
%
% Example: initial condition = [0], input combination = [10,10],
% grid_type = 'sa1', emission = 620. Filename = 'sa1_ic0_i10,10_em620'.
% The latter two arguments should be omitted when using this script for
% RETSim.
%
% Author: Sam Xi

function fileName = getDataFileName(initialCondition, inputCombination, ...
                                    grid_type, emission)
ic = initialCondition;
input = inputCombination;

if (nargin == 2) % Creates filenames for RETSim trace files.
  fileName = 'ic';
  for i = 1:length(ic)
    fileName = strcat(fileName, num2str(ic(i)), '_');
  end
  fileName = strcat(fileName, 'i');
  for i = 1:length(input)
    fileName = strcat(fileName, num2str(input(i)), '_');
  end
  fileName = fileName(1:end-1);
  fileName = strrep(fileName, '-', '_');
else  % Creates filenames for TREX data files.
  fileName = strcat(grid_type, '_ic');
  for i = 1:length(ic)
    if (ic(i) ~= -1)
      fileName = strcat(fileName, num2str(ic(i)));
    end
    if (i ~= length(ic))
      fileName = strcat(fileName, ',');
    else
      fileName = strcat(fileName, '_');
    end
  end
  fileName = strcat(fileName, 'i');
  for i = 1:length(input)
    if (input(i) ~= -1)
      fileName = strcat(fileName, num2str(input(i)));
    end
    if (i ~= length(input))
      fileName = strcat(fileName, ',');
    else
      fileName = strcat(fileName, '_');
    end
  end
  fileName = strcat(fileName, 'em');
  for i = 1:length(emission)
    if (emission(i) ~= -1)
      fileName = strcat(fileName, num2str(emission(i)));
    end
    if (i ~= length(emission))
      fileName = strcat(fileName, ',');
    end
  end
end
