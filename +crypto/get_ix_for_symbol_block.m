% GET_IX_FOR_SYMBOL_BLOCK
%
% Retrieve a excitation sequence that is mapped to by the provided symbol
% block in the input2ix_map object. If there are multiple valid ix mappings for
% the symbol block, one is randomly chosen.
%
% Author: Sam Xi

function ix = get_ix_for_symbol_block(sym_block, input2ix_map)
  valid_ix = input2ix_map.get(sym_block);
  % We need to exclude the first row of zeros when picking the random row.
  chosen_input_index = ceil((size(valid_ix, 1)-1)*rand)+1;
  ix = valid_ix(chosen_input_index, :);
end
