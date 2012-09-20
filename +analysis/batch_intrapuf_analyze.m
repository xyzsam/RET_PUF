% BATCH_INTRAPUF_ANALYZE    Compare data for different IXs on the same PUF.
%
% Performs analysis on data obtained from different IX pairs on the same PUF.
%
% This is the actual analysis code, factored out so that it can be reused by
% other modules. It is called by batch_intrapuf_analyze_dir.
%
% SYNTAX:
%   [outputs] = batch_intrapuf_analyze(datasets, data_type, analysis_type)
%     datasets: structure array containing dataset structures. This is produced
%       by analysis.load_structs - see its documentation for details about the
%       structure of this variable.
%     data_type: The type of data to be analyzed.
%     analysis_type: The type of analysis to run.
%
% For more details, including the valid strings for data_type and analysis_type,
% see the documentation for the corresponding mode in analysis.twohistanalyze.
%
% Author: Sam Xi

function varargout = batch_intrapuf_analyze(datasets, data_type, analysis_type)
  import analysis.util.*;
  num_files = length(datasets{1});
  if (strcmp(analysis_type, 'xcorr'))
    corr_integral_result = zeros(num_files, num_files);
    corr_max_result = zeros(num_files, num_files);
    corr_ratio_result = zeros(num_files, num_files);
    for i=1:num_files
      for j=1:num_files
        encrypt_struct = datasets{1}(i);
        decrypt_struct = datasets{2}(j);
        data_1 = getDataFromType(encrypt_struct, data_type);
        data_2 = getDataFromType(decrypt_struct, data_type);
        stats = analysis.twohistanalyze(data_1, data_2, analysis_type);
        corr_integral_result(i, j) = stats(1);
        corr_max_result(i, j) = stats(2);
        corr_ratio_result(i, j) = stats(3);
      end
    end
    varargout{1} = corr_integral_result;
    varargout{2} = corr_max_result;
    varargout{3} = corr_ratio_result;
  elseif (strcmp(analysis_type, 'l2norm'))
    l2norms = zeros(num_files, num_files);
    for i=1:num_files
      for j=1:num_files
        encrypt_struct = datasets{1}(i);
        decrypt_struct = datasets{2}(j);
        data_1 = getDataFromType(encrypt_struct, data_type);
        data_2 = getDataFromType(decrypt_struct, data_type);
        l2norms(i, j) = analysis.twohistanalyze(data_1, data_2, analysis_type);
      end
    end
    varargout{1} = l2norms;
  elseif (strcmp(mode, 'hough_comparison'))
    % Plot EVERYTHING. Temporary code for Dwyer.
    colors= 'rgbcmykwrgbc';
    figure(1);
    for j=1:8
      d1 = datasets{1}(j);
      d2 = datasets{2}(j);
      plot(d1.time_div./(tand(90-d1.theta_range))*d1.scale_factor*1e9, cumsum(d1.hough_sig), colors(j));
      hold on;
      plot(d2.time_div./(tand(90-d2.theta_range))*d2.scale_factor*1e9, cumsum(d2.hough_sig), colors(j));
    end
    axis([0 10 3e4 8.5e4]);
  end
end
