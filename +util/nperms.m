% NPERMS  Generates all valid length n permutations of an array of numbers.
%
% SYNTAX:
%   p = nperms(v, n)
%   v: The values to permute.
%   n: The length of each permutation
%   mappingdb: An nPv by v integer array containing the valid permutations.
%
% For example, nperms([0,5,10], 2) returns the following cell array:
%   [0, 0]
%   [0, 5]
%   [0, 10]
%   [5, 0]
%   [5, 5]
%   [5, 10]
%   [10, 0]
%   [10, 5]
%   [10, 10]
%
% Author: Sam Xi

function matrix = nperms(v, n)
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
  % THIS CODE BELOW IS DEPRECRATED.
  mappingdb = cell(size(matrix, 1), 2);
  symbol = 65;  % 65 is A in ASCII
  for i=1:size(mappingdb, 1)
    mappingdb{i, 1} = matrix(i, :);
    mappingdb{i, 2} = char(symbol);
    symbol = symbol + 1;
  end
end
