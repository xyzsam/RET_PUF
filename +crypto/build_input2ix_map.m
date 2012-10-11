% BUILD_INPUT2IX_MAP
%
% Build a HashMap of key value pairs <input symbol block, list of IX sets> out
% of the data provided in the structure mapping_struct.
%
% This script relies on certain global variables to be present. It is designed
% to be called only from encrypt.m and decrypt.m.
%
% Author: Sam Xi

function input2ix_map = build_input2ix_map(mapping_struct)
  global sym_offset;
  input2ix_array = mapping_struct.input2ix;
  input2ix_map = java.util.HashMap;
  sym_len = mapping_struct.symbol_block_length;
  ix_len = size(input2ix_array, 2) - sym_len;

  for n = 1:size(input2ix_array, 1)
    % Java HashMaps in MATLAB don't like singleton dimensions. We'll pad the
    % beginning with a row of 0s.
    ix = [zeros(1, ix_len); input2ix_array(n, sym_len+1:end)];
    key = input2ix_array(n, 1:sym_len);
    str_key = char(key+sym_offset);  % Need to use string as key, not array.
    if (~input2ix_map.containsKey(str_key))
      input2ix_map.put(str_key, ix);
    else
      % Augment the current input mapping list with the new one, because some
      % input symbol blocks have multiple mappings.
      new_input = [input2ix_map.get(str_key); ix];
      input2ix_map.put(str_key, new_input);
    end
  end
end