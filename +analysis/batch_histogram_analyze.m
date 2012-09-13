% BATCH_HISTOGRAM_ANALYZE
% Runs analysis between two sets of histograms, as specified by the mode.
%
% SYNTAX:
%   result = batch_histogram_analyze(dir, mode)
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

function varargout = batch_histogram_analyze(dir, mode)
  % Load all the histogram data. data_array is a 1xn structure array, where n is
  % the number of data files per directory. total_array is a 1xm cell array,
  % where m is the number of directories. m is usually 2 - twohistanalyze only
  % compares two histograms at a time. n corresponds to the number of distinct
  % input combinations that are being analyzed.
  sub_dirs = ['1', '2'];
  for d=1:length(sub_dirs)
    dir_path = [dir, '\', sub_dirs(d), '\'];
    files = ls([dir_path, '*.mat']);
    clear data_array;  % Delete this array if it already exists.
    for i=1:size(files, 1);
      filename = deblank(files(i, :));
      load([dir_path, filename]);
      data_array(i) = data;  % Dynamically create this structure array.
    end
    total_array{d} = data_array;  % Dynamically create this structure array too.
  end

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
  % Doing a sweeping comparison of all ix pairs requires a different looping
  % structure and a different set of data structures than just doing
  % corresponding ix pairs. Don't print anything because there is too much data
  % to fit on the console.
  if (strcmp(mode, 'intrapuf_hough_corr'))
    corr_integral_result = zeros(num_files, num_files);
    corr_max_result = zeros(num_files, num_files);
    corr_ratio_result = zeros(num_files, num_files);
    for i=1:num_files
      for j=1:num_files
        encrypt_struct = total_array{1}(i);
        decrypt_struct = total_array{2}(j);
        stats = analysis.twohistanalyze(encrypt_struct, decrypt_struct,  ...
                                        'hough_corr');
        corr_integral_result(i, j) = stats(1);
        corr_max_result(i, j) = stats(2);
        corr_ratio_result(i, j) = stats(3);
      end
    end
    varargout{1} = corr_integral_result;
    varargout{2} = corr_max_result;
    varargout{3} = corr_ratio_result;
  else
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
end
