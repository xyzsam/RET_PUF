% Sam Xi
% 06/08/11
% Encryption
%
% This script performs encryption using the RET-PUF encryption protocol.
% Spectral data files are named as such:
%   sa[grid_num]_ic[initial conditions]_i[input combination]
% so: sa100_ic0_1_i_10_30 refers to PUF #100, initial conditions (0,1), and
% input combination (10,30).
%
% SYNTAX:
%		ciphertext = encrypt(plaintext, mapping_struct, observe_time, ic, spec_dir, grid_num)
%
%     ciphertext: a 2D matrix containing the encrypted data.
%     plaintext: a string representing the plaintext data.
%     mapping_struct: A struct containing mappings from symbols to ix pairs.
%       'input2ix': an integer array containing a mapping from a block
%         of input symbols to a set of IX numbers. The first k columns contains
%         the input symbol blocks, and the remaining columns hold the set of IX
%         numbers. k is stored in this struct as "symbol_block_length".
%       'ix2delays': an integer array containing a mapping of IX numbers to
%         their actual delays. The first column is the IX number, and the rest
%         of the matrix is the delay values.
%       'symbol_block_length': The length of each input symbol block.
%       For more information, see crypto.generate_mappings.m.
%     observe_time: a lifetime value at which the generated Hough transform histograms for
%				each input combination is compared (in ns).
%     ic: an array containing the initial conditions of this encryption session.
%     emission: wavelength at which output spectra should be observed when
%				building the ciphertext. Note: this should not be observed at very high
%				(~1000) or low (0) wavelengths or out of bounds errors are likely to
%				occur.
%     spec_dir: an optional parameter indicating where the directory containing
%				the analyzed spectral data is. If not specified, this defaults to a
%				hardcoded directory.
%			grid_num: An identifier for the particular PUF used.
%
% Author: Sam Xi

function ciphertext = encrypt(plaintext, mapping_struct, observe_time, ic_t, ...
                              emission_t, spec_dir_t,	grid_num_t, time_eps)
  import hough.*;
   % Set global variables so we can use them in other functions in this file.
  global ic grid_num emission spec_dir encrypt_mode sym_offset
  ic = ic_t; grid_num = grid_num_t; emission = emission_t;
  spec_dir = spec_dir_t;
  % Symbols in the mapping arrays start from integer value 1. Since we are
  % encoding ASCII symbols, we need to offset those by 65-1 = 64 to start our
  % alphabet at A.
  sym_offset = 64;

  % encrypt_mode = 0 indicates we're using RETSim data. encrypt_mode = 1 indicates
  % we're using experimental data from TREX.
  if (nargin < 5)
    spec_dir = 'D:\Documents\My Dropbox\Dwyer\Experiments\pattern1_spectrum_decryption\';
    encrypt_mode = 0;
  elseif (nargin == 8)
    encrypt_mode = 1; % Use experimental data rather than RETSim data.
    emission_eps = 0;
  else
    error('Invalid set of parameters.');
  end

  % emission-epsilon. This takes into account the fact that wavelength measurements
  % will never be perfect, so we use a window around the desired wavelength. Note
  % that is only used for RETSim data, as RETSim is able to simulate data
  % measurements at very precise wavelengths.

  % timebin_epsilon. This takes into account the fact that we cannot capture
  % data at exactly the correct timebin. It is set to 0 initially, but is
  % changed later based on the type of data used in encryption.
  if (encrypt_mode == 0)
    emission_eps = 10;
    time_eps = 2;
  else
    emission_eps = 0;
  end

  % A HashMap allows quick access to the appropriate PUF signature and character
  % input combination mapping.
  sig_map = java.util.HashMap;
  sym_len = mapping_struct.symbol_block_length;
  input2ix_map = buildInput2IXMap(mapping_struct);

  % Encrypt the plaintext block by block.
  plaintext_length = length(plaintext);
  for n = 1:sym_len:plaintext_length
    if (n+sym_len <= plaintext_length)
      sym_block = plaintext(n:n+sym_len);
    else
      num_zeros = sym_len - (plaintext_length - n + 1);
      % 'Zero pad' the block with a character.
        sym_block = [plaintext(n:end) ones(1, num_zeros) + sym_offset];
    end
    input = getIXForSymbolBlock(sym_block, input2ix_map);
    for ix_num=input
      [current_sig sig_map] = getStructForIX(ix_num, sig_map, ...
                                             mapping_struct.ix2delays);

      % Generate the time axis array and the index window into this array for
      % extracting the segment of the histogram desired. I assume that all
      % histograms for this particular collection of data share a common time
      % axis, so this only has to be done once.
      if (~exist('ciphertext', 'var'))
        [taxis start_index end_index] = analysis.util.getIndexFromTimeAxis(...
          current_sig, [observe_time-time_eps observe_time+time_eps], 'hist');
        tspanWidth = end_index - start_index + 1;
        ciphertext = [];
        %ciphertext = zeros(2*emission_eps+1, length(plaintext)*tspanWidth);
      end
      csmax = max(current_sig.graph);  % current_sig maximum.
      current_slice = current_sig.graph(start_index:end_index)/csmax;
      ciphertext = [ciphertext current_slice];
%      ciphertext(:, (n-1)*tspanWidth+1:n*tspanWidth) = current_slice;
    end
  end
end

% Build a HashMap of key value pairs <input symbol block, list of IX sets> out
% of the data in mapping_struct.
function input2ix_map = buildInput2IXMap(mapping_struct)
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

% Retrieve a excitation sequence that is mapped to by the provided symbol
% block in the input2ix_map object. If there are multiple valid ix mappings for
% the symbol block, one is randomly chosen.
function ix = getIXForSymbolBlock(sym_block, input2ix_map)
  valid_ix = input2ix_map.get(sym_block);
  % We need to exclude the first row of zeros when picking the random row.
  chosen_input_index = ceil((size(valid_ix, 1)-1)*rand)+1;
  ix = valid_ix(chosen_input_index, :);
end

% Return the data structure corresponding to ix, the excitation sequence number.
% If it does not currently exist in sig_map, the HashMap holding all the data,
% then add to sig_map and returned the updated variable.
function [current_sig sig_map] = getStructForIX(ix_num, sig_map, ix2delays)
  global ic grid_num emission spec_dir
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
    % Translate the ix num to the actual delay values.
    index = find(ix2delays(:, 1) == ix_num);
    input = ix2delays(index, 2:end);
    % Load the file and store it in the HashMap.
    fileName = util.getDataFileName(ic, input, grid_num, emission);
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
