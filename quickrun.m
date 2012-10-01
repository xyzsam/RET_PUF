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
      data_dir = 'E:\Documents\Dropbox\Dwyer\Measurements\sam-114_1\';
      grid_type = 'sa114';
      output_wavelength = 620; 
      ic = [0];
      time_res = 2e-9;
      lifetime = 5e-9;
      orig_plaintext = 'AABDCBDCEC';
      load([data_dir 'mappingdb-test.mat']);      
      ciphertext = encrypt(orig_plaintext, mappingdb, lifetime, ic, output_wavelength, ...
          strcat(data_dir, '1', '\'), grid_type, time_res);
      fprintf('Encrypted text : %s\n', orig_plaintext);
      plaintext = decrypt(ciphertext, mappingdb, lifetime, ic, output_wavelength, ...
          strcat(data_dir, '2', '\'), grid_type, time_res);
      fprintf('Decrypted text : %s\n', plaintext);
      diff = sum(orig_plaintext == plaintext);
      fprintf('Decryption fidelity: %0.0f%%, %d out of %d chars.\n', ...
          diff/length(orig_plaintext)*100, diff, length(orig_plaintext));
  end
  % for i = 1:9
  %     fprintf('Processing log %d...\n', i);
  %     name = sprintf('diamond40_%d.log', i);
  %     [time_data graph] = retsim(strcat(trace_dir,name), {'Cy3', 'FL', 'Cy3', 'FL'}, 200, 100000, 0);
  % end
end
