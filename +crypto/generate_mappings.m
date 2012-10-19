% GENERATE_MAPPINGS   Maps input sequences to input-excitation pairs.
%
% This function maps a block of input symbols of radix n to a space of input-
% excitation (IX) sequences of radix m, where each input symbol block is of
% length k. The mapping is returned in an array, in which the first k columns
% contains the input symbol blocks and the remaining columns contains the IX
% sequences. Mappings are randomly created each time.
%
% SYNTAX:
%   mappingdb = generate_mappings(n, k, m)
%     n: Radix of the input symbols. n must be less than or equal to m.
%     k: Length of each input symbol block.
%     m: Radix of the input-excitation sequence space. If m is greater than n,
%       then certain input symbol blocks will be mapped to multiple IX
%       sequences.
%     pvalues: An array containing integer representations of the input symbols
%       to permute. If this is not given, pvalues defaults to 65:(65+n-1),
%       which are the ASCII uppercase characters.
%     mappingdb: Integer array containing the generated mappings.
%
% Example:
% Let n=4, m=4, and k=4. This means that there are n=4 different input symbols,
% k=4 symbols per block, and m=4 different IX sequences.
% The radix 4 string of length 4 'ABCD' might be generated to match the IX
% sequence (0, 15, 29, 12), in which each sequence has 2 inputs. In the
% returned array, the IX sequence would be represented as (0, 3, 1, 2),
% in which 0 -> [0,0], 3 -> [2,5], etc. Note that the IX sequence is of radix 4-
% there are only four different values. The secondary mapping from IX sequence
% to the actual sequence of laser pulses is described elsewhere - it plays no
% role in this function.
%
% Author: Sam Xi

function mappingdb = generate_mappings(n, k, m, pvalues)
  if (nargin < 3)
    error('Invalid number of arguments provided.\n');
  elseif (m <= 1)
    error('m must be greater than 1.\n');
  elseif (nargin == 3)
    pvalues = 65:(65+n-1);
  end

  % This is the minimum number of IX sequences needed to match n^k input symbol
  % blocks, where each IX sequence is of radix m.
  p = ceil(k*log(n)/log(m));
  ix_seqs = util.nperms(1:m, p);
  symbol_blocks = util.nperms(pvalues, k);
  num_symbols = size(symbol_blocks, 1);
  num_ix = size(ix_seqs, 1);
  % Randomly permute the rows of the ix_seqs.
  row_order = randperm(num_ix);
  ix_seqs = ix_seqs(row_order, :);
  % Create the mapping array.
  mappingdb = zeros(num_ix, p+k);
  mappingdb(1:end, k+1:k+p) = ix_seqs;
  % Each symbol block will have at most nreps mappings to ix pairs.
  nreps = ceil(num_ix/num_symbols);

  start_row = 1;
  end_row = num_symbols;
  end_source = end_row;
  for i=1:nreps
    mappingdb(start_row:end_row, 1:k) = symbol_blocks(1:end_source, :);
    if (num_ix - end_row >= num_symbols)
      start_row = end_row + 1;
      end_row = end_row + num_symbols;
    else
      start_row = end_row + 1;
      end_source = num_ix - end_row;
      end_row = num_ix;
    end
  end
end
