% DECRYPT   Decrypts a RET-PUF encrypted ciphertext.
% Decrypts a ciphertext that was encoded using a particular PUF. It accepts
% the ciphertext, a mapping database, an initial condition, and a time delay as
% the parameters and returns the decoded message as a String.
%
%   SYNTAX: plaintext = decrypt(ciphertext, mappingdb, t, ic, spec_dir)
%
%     plaintext  = decoded message.
%     ciphertext = encrypted message.
%     mappingdb  = a 2D cell array which maps laser input
%                  combinations to ASCII characters. The first cell of
%                  each column is an array with the input combination,
%                  and the second is a character with which that input
%                  combination is mapped to.
%     t          = the time in ps at which the spectrum should be examined.
%     ic         = array specifying the initial condition
%     emission     = wavelength at which output spectra should be
%                  observed when building the plaintext. Note: this
%                  should not be observed at very high (~1000) or low
%                  (0) wavelengths or out of bounds errors are likely
%                  to occur.
%     spec_dir   = an optional parameter indicating where the
%                  directory containing the analyzed spectral data
%                  is. If not specified, this defaults to a hardcoded
%                  directory.

function plaintext = decrypt(ciphertext, mappingdb, t, ic, emission, ...
                             spec_dir, grid_type, time_res)
  import hough.*;
  format long e;
  % decrypt_mode = 0 indicates we're using RETSim data. decrypt_mode = 1 indicates
  % we're using experimental data from TREX.
  if (nargin < 5)
    spec_dir = 'D:\Documents\My Dropbox\Dwyer\Experiments\pattern1_spectrum_decryption\';
    decrypt_mode = 0;
  elseif (nargin == 8)
    decrypt_mode = 1; % Use experimental data rather than RETSim data.
    emission_eps = 0;
    time_eps = time_res;
  else
    error('Invalid set of parameters.');
  end

  INT_MAX = 2147483647;
  if (decrypt_mode == 0)
    emission_eps = 10;
    time_eps = 2;
  else
    emisison_eps = 0;
    %time_eps = 5;
  end

  tspanWidth = (2*time_eps+1); % width of the time window
  plaintext = zeros(1, length(ciphertext)/tspanWidth);
  compMatrix = zeros(1, length(ciphertext)/tspanWidth); % comparison matrix.

  for n=1:size(mappingdb, 1)
    % Load the next data set.
    input = mappingdb{n, 1};
    fileName = util.getDataFileName(ic, input, grid_type, emission);
    % Load the data and extract the appropriate segment of the hough signature.
    file_loc = strcat(spec_dir, fileName, '.mat');
    if (exist(file_loc, 'file'))
      load(file_loc);
    else
      error('Data for file %s not found', fileName);
    end

    if (decrypt_mode == 0)
      % Renames the variable to 'current_sig'.
      eval(sprintf('current_sig = %s;', fileName));
      eval(sprintf('clear %s;', fileName)); % deletes the old copy
    else
      % The struct loaded is named 'data'.
      current_sig = data;
    end

    if (decrypt_mode == 0)
      timebinsize = 200;
      tbin = floor(t/timebinsize);
      % Create the span of time bins, centered around tbin.
      tbinspan = tbin-time_eps:tbin+time_eps;
      tbinIndices = zeros(1, length(tbinspan));
      for i=1:length(tbinspan)
        index = find(current_sig.keySet == tbinspan(i));
        if (~isempty(index))
          tbinIndices(i) = index;
        else
          tbinIndices(i) = 1;
        end
      end
      current_slice = current_sig.hough_sig(emission-emission_eps:emission+emission_eps, tbinIndices);
    else
      lifetime_range = current_sig.time_div./(tand(90-current_sig.theta_range))...
                       * current_sig.scale_factor * 1e9;
      current_sig.hough_sig(lifetime_range < 0) = [];
      lifetime_range(lifetime_range < 0) = [];
      index = find(abs(lifetime_range - t) == min(abs(lifetime_range - t)));
      index_range = index-time_eps:index+time_eps;
      % Ensure that the range is within the bounds of the array.
      index_range(index_range < 0 + index_range > length(index_range)) = [];
      csmax = max(current_sig.hough_sig);  % current_sig maximum.
      current_slice = current_sig.hough_sig(:, index_range)/csmax;
    end

    % Scan through the ciphertext and fill in the blanks with the best matching
    % input combination.
    for m=1:size(ciphertext, 2)/tspanWidth
      cipher_slice = ciphertext(1, (m-1)*tspanWidth+1:m*tspanWidth);
      % Compare the two data streams.
      func = crypto.comp_funcs('rel_conv_max');
      comp_val = func(current_slice, cipher_slice);
      if (comp_val > compMatrix(m))
         compMatrix(m) = comp_val;
         plaintext(m) = mappingdb{n, 2};
      end
    end
  end
  plaintext = char(plaintext);
end
