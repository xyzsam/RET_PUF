% TWOHISTANALYZE  Compute statistics on two RET-PUF histograms.
%
% This script will compare two histograms from an experiment and compute various
% statistics that represent the amount that the two histograms differ. This is
% used to determine how similar two histograms from two different batches of the
% same PUF is used, for example.
%
% SYNTAX:
%   function stats = twohistanalyze(data_1, data_2, mode)
%     data_1: An array of data.
%     data_2: An array of data.
%     mode: A string indicating which statistics and metrics to compute.
%
%   if mode: 'countsdiff': result is an 1x6 matrix.
%     The two columns contain the total counts for the entire amplitude
%       histograms.
%     The third column is the difference in total counts.
%     The fourth column is the percent difference in total counts.
%     The fifth column
%   if mode: 'xcorr', result is a 1x3 matrix.
%     The first element is the integral of the correlation between the two data
%       sets.
%     The second element is the maximum of the cross correlation.
%     The third element is the ratio of cross correlation's maximum and the
%       maximum of the first data set's autocorrelation, to provide insight on
%       how similar the two datasets are. The closer to 1 this value is, the
%       more similar they are.
%   if mode: 'l2norm', result is a number representing the L2 norm of the
%     two datasets.
%
% Author: Sam Xi

function stats = twohistanalyze(data_1, data_2, mode)
  if (strcmp(mode, 'countsdiff'))
    end_index = getShorterLength(data_1, data_2);
    graph_1 = data_1(1:end_index);
    graph_2 = data_2(1:end_index);
    d1_total_counts = sum(graph_1);
    d2_total_counts = sum(graph_2);
    max_diff = max(abs(graph_1 - graph_2));
    max_graph_1 = max(graph_1);
    total_count_diff = d1_total_counts - d2_total_counts;
    stats = [d1_total_counts d2_total_counts ...
              total_count_diff total_count_diff/d1_total_counts*100 ...
              max_diff max_diff/max_graph_1*100];
  elseif (strcmp(mode, 'xcorr'))
    ndata_1 = data_1/max(data_1);
    ndata_2 = data_2/max(data_2);
    stats = corr_stats(ndata_1, ndata_2);
  elseif (strcmp(mode, 'l2norm'))
    stats = l2norm(data_1, data_2);
  end
end

function short_length = getShorterLength(hist1, hist2)
  if (length(hist1) > length(hist2))
    short_length = length(hist2);
  else
    short_length = length(hist1);
  end
end

function stats = corr_stats(hist1, hist2)
  cross_corr = xcorr(hist1, hist2);
  auto_corr = xcorr(hist1, hist1);
  corr_integral = trapz(cross_corr);
  corr_max = max(cross_corr);
  corr_ratio = corr_max/max(auto_corr);
  stats = [corr_integral corr_max corr_ratio];
end

function l2n = l2norm(hist1, hist2)
  longer_length = max(length(hist1), length(hist2));
  combined = zeros(2, longer_length);
  combined(1, 1:length(hist1)) = hist1/max(hist1);
  combined(2, 1:length(hist2)) = hist2/max(hist2);
  l2n = sqrt(sum((combined(1,:)-combined(2,:)).^2));
end
