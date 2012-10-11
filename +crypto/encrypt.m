% Sam Xi
% 06/08/11
% Encryption
%
% This script performs encryption using the RET-PUF encryption protocol.
% Spectral data files are named as such:
%   sa[grid_type]_ic[initial conditions]_i[input combination]
% so: sa100_ic0_1_i_10_30 refers to PUF #100, initial conditions (0,1), and
% input combination (10,30).
%
% SYNTAX:
%		ciphertext = encrypt(plaintext, mapping_struct, observe_time, ic, spec_dir, grid_type)
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
%     observe_time: the time at which the histograms for each input combination
%       is compared (in ns).
%     ic: an array containing the initial conditions of this encryption session.
%     emission: wavelength at which output spectra should be observed when
%				building the ciphertext. Note: this should not be observed at very high
%				(~1000) or low (0) wavelengths or out of bounds errors are likely to
%				occur.
%     spec_dir: A directory location containing the histogram data.
%			grid_type: An identifier for the particular PUF used.
%
% Author: Sam Xi

function ciphertext = encrypt(plaintext, mapping_struct, observe_time, ic_t, ...
                              emission_t, spec_dir_t,	grid_type_t, time_eps)
  import crypto.*;
  % Set global variables so we can use them in other functions in this file.
  global ic grid_type emission spec_dir encrypt_mode sym_offset
  ic = ic_t; grid_type = grid_type_t; emission = emission_t;
  spec_dir = spec_dir_t;
  % Symbols in the mapping arrays start from integer value 1. Since we are
  % encoding ASCII symbols, we need to offset those by 65-1 = 64 to start our
  % alphabet at A.
  sym_offset = 64;

  if (nargin < 8)
    error('Invalid set of parameters.');
  end

  % A HashMap allows quick access to the appropriate PUF signature and character
  % input combination mapping.
  sig_map = java.util.HashMap;
  sym_len = mapping_struct.symbol_block_length;
  input2ix_map = build_input2ix_map(mapping_struct);

  % Encrypt the plaintext block by block.
  plaintext_length = length(plaintext);
  for n = 1:sym_len:plaintext_length
    if (n+sym_len <= plaintext_length)
      sym_block = plaintext(n:n+sym_len-1);
    else
      num_zeros = sym_len - (plaintext_length - n + 1);
      % 'Zero pad' the block with a character.
        sym_block = [plaintext(n:end) ones(1, num_zeros) + sym_offset];
    end
    input = get_ix_for_symbol_block(sym_block, input2ix_map);
    for ix_num=input
      [current_sig sig_map] = get_struct_for_ix(ix_num, sig_map, ...
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