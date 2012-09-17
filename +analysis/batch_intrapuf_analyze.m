% BATCH_INTRAPUF_ANALYZE    Compare data for different IXs on the same PUF.
%
% Performs analysis on data obtained from different IX pairs on the same PUF.
%
% [I M R] = batch_intra_puf_analyze(dir, xcorr_mode) compares cross correlation
% results between all IX pairs. The data used is determined by the mode.
% I, M, and R are all nxn matrices, where n is the number of IX pairs to be
% analyzed. I contains the integral of the cross-correlation curves. M contains
% the peaks of the cross-correlation curves. R contains the ratio between the
% peak of the cross-correlation curve and the peak of the auto-correlation curve
% of one dataset.
%   Valid modes: 
%     'xcorr_hist' operates on the raw amplitude histograms.
%     'xcorr_hough' operates on the Hough signatures.
%     'xcorr_cumhough' operates on the cumulative Hough signature sums.
% l2norm = batch_intra_puf_analyze(dir, l2norm_mode) computes L2 norms on all
% IX pairs. l2norm is an nxn matrix where n is the number of IX pairs. All data
% sets are normalized to a maximum of 1 before any computation is performed.
%   Valid modes:
%     'l2norm_hist' operates on the raw amplitude histograms.
%     'l2norm_hough' operates on the Hough signatures.
%     'l2norm_cumhough' operates on the cumulative Hough signature sums.
%
% For more details, see the documentation for the corresponding mode in
% analysis.twohistanalyze.
%
% Author: Sam Xi

function varargout = batch_intrapuf_analyze(dir, mode)
  total_array = analysis.load_structs(dir);
  num_files = length(total_array{1});
  if (strcmp(mode, 'countsdiff'))
    analysis_type = mode;
    data_type = 'hist';
  else
    analysis_type = char(regexp(mode, '\w+(?=_)', 'match'));
    data_type = char(regexp(mode, '(?<=_)\w+', 'match'));
  end
  if (strcmp(analysis_type, 'xcorr'))
    corr_integral_result = zeros(num_files, num_files);
    corr_max_result = zeros(num_files, num_files);
    corr_ratio_result = zeros(num_files, num_files);
    for i=1:num_files
      for j=1:num_files
        encrypt_struct = total_array{1}(i);
        decrypt_struct = total_array{2}(j);
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
        encrypt_struct = total_array{1}(i);
        decrypt_struct = total_array{2}(j);
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
      d1 = total_array{1}(j);
      d2 = total_array{2}(j);
      plot(d1.time_div./(tand(90-d1.theta_range))*d1.scale_factor*1e9, cumsum(d1.hough_sig), colors(j));
      hold on;
      plot(d2.time_div./(tand(90-d2.theta_range))*d2.scale_factor*1e9, cumsum(d2.hough_sig), colors(j));
    end
    axis([0 10 3e4 8.5e4]);
  end
end

% Returns an array that corresponds to the type of data needed for a particular
% computation. 
% SYNTAX:
%   data = getDataFromType(data_struct, data_type)
%     data_struct: A structure object created by asc2mat.
%     data_type: A string indicating what kind of data to be extracted from the
%       struct. 'hist' returns data_struct.graph, the raw amplitude histogram.
%       'hough' returns data_struct.hough_sig, the Hough signature. 'cumhough'
%       returns the cumulative sum of the Hough signature.
%
% Author: Sam Xi
function data = getDataFromType(data_struct, data_type)
  if (strcmp(data_type, 'hist'))
    data = data_struct.graph;
  elseif (strcmp(data_type, 'hough'))
    data = data_struct.hough_sig;
  elseif (strcmp(data_type, 'cumhough'))
    data = cumsum(data_struct.hough_sig);
  end
end
