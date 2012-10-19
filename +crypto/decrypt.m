% DECRYPT   Decrypts a RET-PUF encrypted ciphertext.
% Decrypts a ciphertext that was encoded using a particular PUF. It accepts
% the ciphertext, a mapping database, an initial condition, and a time delay as
% the parameters and returns the decoded message as a String.
%
%   SYNTAX: plaintext = decrypt(ciphertext, mapping_struct, observe_time, ic, ...
%                               emission, spec_dir, grid_type, time_eps)
%
%     plaintext: decoded message.
%     ciphertext: encrypted message.
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
%     spec_dir: A directory location containing the histogram data.
%			grid_type: An identifier for the particular PUF used.
%
% Author: Sam Xi

function plaintext = decrypt(ciphertext, mapping_struct, observe_time, ic_t, ...
                             emission_t, spec_dir_t, grid_type_t, time_eps)
  import crypto.*;
  format long e;
  global ic grid_type emission spec_dir
  ic = ic_t; grid_type = grid_type_t; emission = emission_t;
  spec_dir = spec_dir_t;
  % decrypt_mode = 0 indicates we're using RETSim data. decrypt_mode = 1 indicates
  % we're using experimental data from TREX.
  if (nargin < 8)
    error('Invalid set of parameters.');
  end

  sym_len = mapping_struct.symbol_block_length;
  input2ix_array = mapping_struct.input2ix;
  sig_map = java.util.HashMap;
  
  for n=1:size(input2ix_array, 1)
    % Keep track of progress
    if (floor(n/100) == n/100)
      fprintf('Testing input %d of %d...\n', n, size(input2ix_array, 1));
    end
    sym_block = input2ix_array(n, 1:sym_len);
    input = input2ix_array(n, sym_len+1:end);
    ix_len = size(input2ix_array, 2) - sym_len;
    for i=1:length(input)
      ix_num=input(i);
      [current_sig sig_map] = get_struct_for_ix(ix_num, sig_map, ...
                                                mapping_struct.ix2delays);
      % Initialize this data just once.
      if (~exist('plaintext', 'var'))
        [taxis start_index end_index] = analysis.util.getIndexFromTimeAxis(...
          current_sig, [observe_time-time_eps observe_time+time_eps], 'hist');
        symbolWidth = end_index - start_index + 1;
        cipherBlockWidth = ix_len*symbolWidth;
        num_characters = (length(ciphertext)/cipherBlockWidth)*sym_len;
        current_slice = zeros(1, cipherBlockWidth);
        plaintext = zeros(1, num_characters);
        % Comparison matrix for finding the best match.
        compMatrix = zeros(1, num_characters/sym_len);
      end
      csmax = max(current_sig.graph);  % current_sig maximum.
      current_subslice = current_sig.graph(:, start_index:end_index)/csmax;
      current_slice((i-1)*symbolWidth+1:i*symbolWidth) = current_subslice;
    end
    % Scan through the ciphertext and fill in the blanks with the best matching
    % input combination.
    for m=1:num_characters/sym_len
      cipher_slice = ciphertext((m-1)*cipherBlockWidth+1:m*cipherBlockWidth);
      % Compare the two data streams.
      func = crypto.comp_funcs('l2norm');
      comp_val = func(current_slice, cipher_slice);
      if (comp_val > compMatrix(m))
        compMatrix(m) = comp_val;
        plaintext((m-1)*sym_len+1:m*sym_len) = sym_block;
      end
    end
  end
  plaintext = char(plaintext);
end
