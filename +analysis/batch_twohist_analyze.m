% BATCH_TWOHIST_ANALYZE
% Runs analysis between two sets of histograms, as specified by the mode.
%
% SYNTAX:
%   result = batch_twohist_analyze(dir, mode)
%     dir: A directory containing two subdirectories which contain MATLAB data
%       files to be analyzed. The data files are produced by asc2mat.
%     mode: A string indicating the type of analysis to run. Valid options are:
%     result: An array containing the computed data. Details about the analysis
%       data is provided below.
%
% The mode string is composed of two parts, an analysis type and a data type.
% The analysis type determines which values to calculate, and the data type
% determines what data to operate on.
% Build the mode string by concatenating the two with an underscore.
% Valid analysis types:
%   xcorr: Cross correlation
%   ssd: Sum of squares of differences.
%   countsdiff: Difference in total and max counts. NOTE: with this analysis
%     type, do not include a data type. This is because a comparison of counts
%     is only meaningful on the raw amplitude histograms, so that data type is
%     used by default.
% See the documentation for analysis.twohistanalyze for more details on what
% these analysis types return.
%
% Valid data types:
%   hist: Raw amplitude histograms from the TCSPC.
%   loghist: Log (ln) of the raw amplitude histograms.
%   hough: Hough signature of the raw histograms.
%   cumhough: Cumulative hough signature.
%
% Example of valid mode strings: xcorr_hist, ssd_cumhough, countsdiff.
% Example of invalid mode strings: countsdiff_hough, hist_xcorr.
%
% For easier use, the results are also formatted and printed to the console.
% Author: Sam Xi

function result = batch_twohist_analyze(dir, mode)
  total_array = analysis.load_structs(dir);
  num_files = length(total_array{1});
  if (strcmp(mode, 'countsdiff'))
    analysis_type = mode;
    data_type = 'hist';
  else
    analysis_type = char(regexp(mode, '\w+(?=_)', 'match'));
    data_type = char(regexp(mode, '(?<=_)\w+', 'match'));
  end
  if (strcmp(analysis_type, 'countsdiff'))
    result = zeros(num_files, 6);
    header = ['  data1 total', ...
              '  data2 total', ...
              '   total diff', ...
              ' total diff %%', ...
              '     max diff', ...
              '   max diff %%', ...
              '\n'];
    result_format = '%13d%13d%13d%13.2f%13d%13.2f\n';
  elseif (strcmp(analysis_type, 'xcorr'))
    result = zeros(num_files, 3);
    header = ['        xcorr', ...
              '    xcorr max', ...
              '   corr ratio', ...
              '\n'];
    result_format = '%13.5g%13.5g%13.5f\n';
  elseif (strcmp(analysis_type, 'ssd'))
    result = zeros(num_files, 1);
    header = ['      L2 norm', ...
              '\n'];
    result_format = '%13.5g\n';
  end
  fprintf(header);
  for i=1:num_files
    encrypt_struct = total_array{1}(i);
    decrypt_struct = total_array{2}(i);
    % TODO: There is code duplication here with batch_intrapuf_analyze.
    if (strcmp(data_type, 'hist'))
      data_1 = encrypt_struct.graph;
      data_2 = decrypt_struct.graph;
    elseif (strcmp(data_type, 'loghist'))
      data_1 = log(encrypt_struct.graph);
      data_2 = log(decrypt_struct.graph);
    elseif (strcmp(data_type, 'hough'))
      data_1 = encrypt_struct.hough_sig;
      data_2 = decrypt_struct.hough_sig;
    elseif (strcmp(data_type, 'cumhough'))
      data_1 = cumsum(encrypt_struct.hough_sig);
      data_2 = cumsum(decrypt_struct.hough_sig);
    end
    result(i, :) = analysis.twohistanalyze(data_1, data_2, analysis_type);
    fprintf(result_format, result(i, :));
  end
end
