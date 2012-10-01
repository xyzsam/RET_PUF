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
%		ciphertext = encrypt(plaintext, mappingdb, observe_time, ic, spec_dir, grid_num)
%
%     ciphertext: a 2D matrix containing the encrypted data.
%     plaintext: a string representing the plaintext data.
%     mappingdb: a 2D cell array which maps laser input combinations to ASCII
%				characters. The first cell of each column is an array with the input
%				combination, and the second is a character with which that input
%       combination is mapped to.
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

function ciphertext = encrypt(plaintext, mappingdb, observe_time, ic, emission, ...
                              spec_dir,	grid_num, time_eps)
  import hough.*;

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
    emisison_eps = 0;
    %time_eps = 5;
  end

  % A HashMap allows quick access to the appropriate PUF signature and character
  % input combination mapping.
  sig_map = java.util.HashMap;
  db_map = java.util.HashMap;


  %% Build the DB HashMap
  for n = 1:size(mappingdb, 1)
    key = mappingdb{n, 2};
    input = mappingdb{n, 1};
    db_map.put(key, input);
  end

  % encrypt the plaintext character by character
  for n = 1:length(plaintext)
    c = plaintext(n);
    input = db_map.get(c);

    % Check if the appropriate data has already been loaded
    if (~isempty(sig_map.get(c)))
      current_sig = sig_map.get(c);
      current_sig = retsim.hashmap2struct(current_sig);
      % In MATLAB, adding an array to a hashmap flips the array for some unknown
      % reason. This undoes that flip.
      if (size(current_sig.hough_sig, 1) ~= 1)
        current_sig.hough_sig = current_sig.hough_sig';
      end
    else
     % Load the file and store it in the HashMap.
      fileName = util.getDataFileName(ic, input, grid_num, emission);
      % load the data, extract the appropriate slice of sig.
      file_loc = strcat(spec_dir, fileName, '.mat');
      if (exist(file_loc, 'file'))
        load(file_loc);
      else
        error('Data for file %s not found', fileName);
      end
      if (encrypt_mode == 0)
        % Renames the variable to 'current_sig'.
        eval(sprintf('current_sig = %s;', fileName));
        eval(sprintf('clear %s;', fileName)); % deletes the old copy
      else
        current_sig = data;  % The loaded variable is named "data".
      end
      sig_hashmap = retsim.struct2hashmap(current_sig);
      sig_map.put(c, sig_hashmap);
    end

    if (encrypt_mode == 0)
      % Time bin size is hardcoded for now. This will be added to the signature
      % structures later.
      timebinsize = 1/4096;
      tbin = floor(observe_time/timebinsize);
      % Identify indices of the time bin, build up a dynamic array of indices.
      tbinspan = tbin-time_eps:tbin+time_eps;
      tbinIndices = zeros(1,length(tbinspan));
      for i=1:length(tbinspan)
        index = find(current_sig.keySet == tbinspan(i));
        if (~isempty(index))
          tbinIndices(i) = index;
        else
          tbinIndices(i) = 1;
        end
      end
      % Extract the slice of sig from current_sig and add to ciphertext.
      current_slice = current_sig.graph(...
        emission-emission_eps:emission+emission_eps, tbinIndices);    
    else
      % Assume that all histograms for this particular collection of data share
      % a common time axis, so this only has to be done once.
      if (~exist('ciphertext', 'var'))
        [taxis start_index end_index] = analysis.util.getIndexFromTimeAxis(...
          current_sig, [observe_time-time_eps observe_time+time_eps], 'hist');
        tspanWidth = end_index - start_index + 1;
        % Ciphertext matrix. It is as long as the plaintext is - a security issue that
        % we will need to address.
        ciphertext = zeros(2*emission_eps+1, length(plaintext)*tspanWidth);
      end
      csmax = max(current_sig.graph);  % current_sig maximum.
      current_slice = current_sig.graph(start_index:end_index)/csmax;
  %   LEGACY CODE.
  %    lower_index = (index-time_eps)*(index - time_eps > 0);
  %		% True if the time at which we're inspecting the sig plus the time
  %		% window is greater than the number of points in the sig. This is used
  %		% so that we generate a valid, within-bounds time window to inspect the
  %		% response sig.
  %		eps_exceeds_bounds = index + time_eps <= length(current_sig.hough_sig);
  %    upper_index = (index+time_eps)*(eps_exceeds_bounds) + ...
  %                   length(current_sig.hough_sig)*(~eps_exceeds_bounds);
  %    index_range = lower_index:upper_index;
  %    csmax = max(current_sig.hough_sig);  % current_sig maximum.
  %    current_slice = current_sig.hough_sig(1, index_range)/csmax;
    end

    ciphertext(:, (n-1)*tspanWidth+1:n*tspanWidth) = current_slice;
  end
end
