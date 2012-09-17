% BATCH_TWOHIST_ANALYZE
% Runs analysis between two sets of histograms, as specified by the mode.
%
% SYNTAX:
%   result = batch_twohist_analyze(dir, mode)
%     dir: A directory containing two subdirectories which contain MATLAB data
%       files to be analyzed. The data files are produced by asc2mat.
%     mode: A string indicating the type of analysis to run. Valid options are:
%       'counts_diff': Computes differences in total counts and maximum counts.
%       'xcorr_hist': Computes cross correlations between the datasets.
%     result: An array containing the computed data. Details about the analysis
%       data is provided in the documentation for twohistanalyze.
%
% For easier use, the results are also formatted and printed to the console.
% Author: Sam Xi

function varargout = batch_twohist_analyze(dir, mode)
  total_array = analysis.load_structs(dir);
  num_files = length(total_array{1});
  if (strcmp(mode, 'counts_diff'))
    result = zeros(num_files, 6);
    header = ['  data1 total', ...
              '  data2 total', ...
              '   total diff', ...
              ' total diff %%', ...
              '     max diff', ...
              '   max diff %%', ...
              '\n'];
    result_format = '%13d%13d%13d%13.2f%13d%13.2f\n';
  elseif (strcmp(mode, 'xcorr_hist'))
    result = zeros(num_files, 3);
    header = ['        xcorr', ...
              '    xcorr max', ...
              '   corr ratio', ...
              '\n'];
    result_format = '%13.5g%13.5g%13.5f\n';
  end
  fprintf(header);
  for i=1:num_files
    encrypt_struct = total_array{1}(i);
    decrypt_struct = total_array{2}(i);
    result(i, :) = analysis.twohistanalyze(encrypt_struct, decrypt_struct, ...
                                           mode);
    fprintf(result_format, result(i, :));
  end
  varargout{1} = result;
end
