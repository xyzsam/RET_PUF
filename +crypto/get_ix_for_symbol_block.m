% GET_IX_FOR_SYMBOL_BLOCK
%
% Retrieve a excitation sequence that is mapped to by the provided symbol
% block in the input2ix_array array. If there are multiple valid ix mappings for
% the symbol block, one is randomly chosen. The excitation sequence
% corresponding to this symbol block is stored in the given HashMap and
% returned.
%
% Author: Sam Xi

function [ix input2ix_map] = get_ix_for_symbol_block(sym_block, ...
                                                     input2ix_map, ...
                                                     input2ix_array)
  % Convert string to matrix string key.
  sym_block_key = mat2str(sym_block+0);
  % Conver string to array.
  sym_block_array = sym_block + 0;
  valid_ix = input2ix_map.get(sym_block_key);
  if (isempty(valid_ix))
    % Find the IX sequence mapped by this symbol block and eliminate incorrect
    % possible duplicates found by strfind. Add all of the matches to the map.
    ind = strfind(reshape(input2ix_array', 1, []), sym_block_array);
    sym_len = length(sym_block);
    ix_len = size(input2ix_array, 2) - sym_len;
    correct_ind = mod(ind - 1, size(input2ix_array, 2)) == 0;
    ind = (ind(correct_ind) - 1)/size(input2ix_array, 2) + 1;
    valid_ix = input2ix_array(ind, sym_len+1:end);
    input2ix_map.put(sym_block_key, [zeros(1, ix_len); valid_ix]);
  end
  % We need to exclude the first row of zeros when picking the random row.
  chosen_input_index = ceil((size(valid_ix, 1)-1)*rand)+1;
  ix = valid_ix(chosen_input_index, :);
end