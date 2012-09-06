% GENERATEMAPPINGDB     Generates a mapping from input combinations to symbols.
% 
% This is used to match a particular input combination (consisting of laser
% pulse delays) to symbols for the RET-PUF cryptoprotocol.
% 
% SYNTAX: 
%   mappingdb = generateMappingDB(v, n)
%   v: The laser delays to permute.
%   n: Optional. The number of lasers used in this experiment. Defaults to 1.
%   mappingdb: nx2 cell array, in which the first column contains arrays of
%     input combinations and the second column contains the corresponding
%     symbols that the input combinations map to. Symbols start at A and go
%     through Z consecutively.
%
% For example, generateMappingDB([0,5,10], 2) returns the following cell array:
%   [0, 0]    'A'
%   [0, 5]    'B'
%   [0, 10]   'C'
%   [5, 0]    'D'
%   [5, 5]    'E'
%   [5, 10]   'F'
%   [10, 0]   'G'
%   [10, 5]   'H'
%   [10, 10]  'I'
%
% Author: Sam Xi

function mappingdb = generateMappingDB(v, n)
  if (nargin < 2)
    error('Not enough arguments provided.')
  elseif (nargin == 2)
    n = 2;
  end

  % Generate the input arguments for NDGRID.
  input_args = '';
  varnames = cell(1, n);
  for i=1:n
    input_args = strcat(input_args, 'v,');
    varnames{i} = 'x';
  end
  input_args = input_args(1:end-1);  % Remove trailing comma
  varnames = genvarname(varnames);

  % Build the variable list to accept the output of NDGRID.
  output_args = '';
  for i=1:n
    output_args = strcat([output_args, ' ', varnames{i}]);
  end

  % Build the final overall command and execute it.
  command = sprintf('[%s] = ndgrid(%s);', output_args, input_args);
  eval(command);

  % Consolidate the result into a matrix. First, build the input argument string.
  % This command changes a string of variable names 'x x1 x2 x3' into the string
  % 'x(:) x1(:) x2(:) x3(:)'. Wrapping this string with square brackets gives us
  % a matrix containing all possible permutations of the values of v.
  input_arg2 = regexprep(output_args, '(\S+)', '$1(:)');
  command2 = sprintf('matrix = [%s];', input_arg2);
  eval(command2);

  % Convert this structure into a cell array and match it with an ASCII character.
  mappingdb = cell(size(matrix, 1), 2);
  symbol = 65;  % 65 is A in ASCII
  for i=1:size(mappingdb, 1)
    mappingdb{i, 1} = matrix(i, :);
    mappingdb{i, 2} = char(symbol);
    symbol = symbol + 1;
  end
end