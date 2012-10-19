% Sam Xi
% 03/21/11
% QUICKRUN
% Run a common experiment, all parameters hardcoded for convenience

function out = quickrun(mode)
  import crypto.*;
  if (mode == 1)
      trace_dir = 'D:\Documents\My Dropbox\Dwyer\Experiments\trace logs\ic(0  20)_decryption\';
  %    [total time_data graph] = retsim(strcat(trace_dir,'input(50  70).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
  %    [total time_data graph] = retsim(strcat(trace_dir,'input(50  120).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(50  170).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(100   70).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(100  120).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(100  170).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(150   70).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(150  120).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
      [total time_data graph] = retsim(strcat(trace_dir,'input(150  170).log'), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
  elseif (mode == 2)
      writedir = 'D:\Documents\My Dropbox\Dwyer\Experiments\pattern1_allexps';
      tconfig = expgen(2, 4, 50, 20, 200);
      n = expwrite(writedir, tconfig, 4, 1000000000, 100000, 200, [490 520 550 520], [5 5 5 5], [1 1 1 1]);
  elseif (mode == 3)
      cd('D:\Documents\My Dropbox\Dwyer\Experiments\');
      load mappingdb-ic0_20.mat
      cd('D:\Documents\My Dropbox\Dwyer\scripts\');
      ciphertext = encrypt('ABCDE', mappingdb, 20000, [0 20], 526, ...
          'D:\Documents\My Dropbox\Dwyer\Experiments\pattern1_spectrum_encryption\');
      fprintf('Encryption complete.\n');
      plaintext = decrypt(ciphertext, mappingdb, 20000, [0 20], 526, ...
          'D:\Documents\My Dropbox\Dwyer\Experiments\pattern1_spectrum_decryption\');
      fprintf('Decrypted text: %s\n', plaintext);
  elseif (mode == 4) % trex measurements data
      % Set measurement parameters.
      data_dir = 'E:\Documents\Dropbox\Dwyer\Measurements\sam-114_1\';
      load([data_dir 'mappingdb_new.mat']);     
      grid_type = 'sa114';
      output_wavelength = 620; 
      ic = [0];
      time_res = 2e-9;
      observe_time = 5e-9;
      % Set plaintext.
      orig_plaintext = 'ABCBEDGFADDGEDGFBBDFEFGDCCAF';
      fprintf('Plaintext to encrypt: %s\n', orig_plaintext);
      % Encrypt.
      ciphertext = encrypt(orig_plaintext, mapping_struct, observe_time, ic, ...
          output_wavelength, strcat(data_dir, '1', '\'), grid_type, time_res);
      fprintf('%s encrypted.\n', orig_plaintext);
      % Decrypt.
      decrypt_data_dir = 'E:\Documents\Dropbox\Dwyer\Measurements\sam-116_1\';
      decrypt_grid_type = 'sa116';
      dec_plaintext = decrypt(ciphertext, mapping_struct, observe_time, ic, ...
          output_wavelength,strcat(decrypt_data_dir, '1', '\'), decrypt_grid_type, time_res);
      fprintf('Decrypted text : %s\n', dec_plaintext);
      % Compare the decrypted plaintext with the original plaintext.
      enc_diff = sum(orig_plaintext == dec_plaintext);
      diff = sum(orig_plaintext == dec_plaintext(1:length(orig_plaintext)));
      fprintf('Decryption fidelity of encoded text: %0.0f%%, %d out of %d chars.\n', ...
          enc_diff/length(orig_plaintext)*100, enc_diff, length(orig_plaintext));
      fprintf('Decryption fidelity of plaintext: %0.0f%%, %d out of %d chars.\n', ...
          diff/length(orig_plaintext)*100, diff, length(orig_plaintext));
      out = struct('plaintext', orig_plaintext, ...
                   'ciphertext', ciphertext, ...
                   'decrypted_text', dec_plaintext);
  elseif (mode == 5)  % Ciphertext analysis mode
    % Set measurement parameters.
    data_dir = 'E:\Documents\Dropbox\Dwyer\Measurements\sam-114_1\';
    load([data_dir 'mappingdb_fullalpha.mat']);     
    grid_type = 'sa114';
    output_wavelength = 620; 
    ic = [0];
    time_res = 2e-9;
    observe_time = 5e-9;
    orig_plaintext = util.simplify_text('\', 'midsummer.txt');
    fprintf('Encrypting plaintext...');
    % Encrypt.
    ciphertext = encrypt(orig_plaintext, mapping_struct, observe_time, ic, ...
        output_wavelength, strcat(data_dir, '1', '\'), grid_type, time_res);
    fprintf('%s encrypted.\n', orig_plaintext);
    freqs = analysis.freq_analysis(ciphertext);
    out = struct('ciphertext', ciphertext, 'freq_analysis', freqs);
  end
  % for i = 1:9
  %     fprintf('Processing log %d...\n', i);
  %     name = sprintf('diamond40_%d.log', i);
  %     [time_data graph] = retsim(strcat(trace_dir,name), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
  % end
end
