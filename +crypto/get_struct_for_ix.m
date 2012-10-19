% GET_STRUCT_FOR_IX
%
% Return the data structure corresponding to ix_num, the excitation sequence
% number. If it does not currently exist in sig_map, the HashMap holding all
% the data, then add to sig_map and return the updated variable.
%
% This script relies on certain global variables to be present. It is designed
% to be called only from encrypt.m and decrypt.m.
%
% Author: Sam Xi

function [current_sig sig_map] = get_struct_for_ix(ix_num, sig_map, ix2delays)
  global ic grid_type emission spec_dir
  str_key = mat2str(ix_num);
  % Check if the appropriate data has already been loaded
  if (~isempty(sig_map.get(str_key)))
    current_sig = sig_map.get(str_key);
    current_sig = retsim.hashmap2struct(current_sig);
    % In MATLAB, adding an array to a hashmap flips the array for some unknown
    % reason. This undoes that flip.
    if (size(current_sig.graph, 1) ~= 1)
      current_sig.graph = current_sig.graph';
    end
  else
    % ix2delays is indexed by ix_num.
    input = ix2delays(ix_num, 2:end);
    % Load the file and store it in the HashMap.
    fileName = util.getDataFileName(ic, input, grid_type, emission);
    % load the data, extract the appropriate slice of sig.
    file_loc = strcat(spec_dir, fileName, '.mat');
    if (exist(file_loc, 'file'))
      load(file_loc);
    else
      error('Data for file %s not found', fileName);
    end
    current_sig = data;  % The loaded variable is named "data".
    sig_hashmap = retsim.struct2hashmap(current_sig);
    sig_map.put(str_key, sig_hashmap);
  end
end
