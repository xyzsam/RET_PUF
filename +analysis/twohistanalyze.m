% TWOHISTANALYZE  Compute statistics on two RET-PUF histograms.
%
% This script will compare two histograms from an experiment and compute various
% statistics that represent the amount that the two histograms differ. This is
% used to determine how similar two histograms from two different batches of the
% same PUF is used, for example.
%
% SYNTAX:
%   function stats = twohistanalyze(data_1, data_2, mode)
%     data_1: A structure containing PUF data.
%     data_2: A structure containing PUF data.
%     mode: A string indicating which statistics and metrics to compute.
%       Valid modes:
%         'counts_diff': Computes the difference in total counts and the maximum
%             difference in counts at any given time. All zero data points are
%             removed so that the two histograms start at nonzero values, and
%             the shorter histogram is zero-padded to correct differences in
%             lengths.
%
%  RETURNS:
%    if mode: 'counts_diff', stats is an 1x6 matrix.
%       The first two elements are the total counts for the two histograms given.
%       The third element is the difference in total count between the two
%         histograms.
%       The fourth element is the total count percentage difference with respect
%         to the first histogram.
%       The fifth element is the maximum difference between the two histograms
%         at any one given time with respect to the first.
%       The sixth element is the maximum percent difference between the two
%         histograms at any one given time with respect to the maximum count at
%         at any one given time of the first histogram.
%     To prevent strange data collection errors from intefering with
%     this metric, all leading and trailing zeros have been stripped from the
%     histograms.
%   if mode: 'xcorr_hist', stats is a 1x3 matrix.
%     The first element is the integral of the correlation between the two data
%       sets.
%     The second element is the maximum of the cross correlation.
%     The third element is the ratio of cross correlation's maximum and the
%       maximum of the first data set's autocorrelation, to provide insight on
%       how similar the two datasets are. The closer to 1 this value is, the
%       more similar they are.
%   if mode: 'hough_corr', stats is a 1x3 matrix. It performs the equivalent
%     function as 'xcorr_hist' except that the data operated on is the Hough
%     signature of the amplitude histogram.
%   if mode: 'cumhough_corr', stats is a 1x3 matrix. It performs the equivalent
%     function as 'xcorr_hist' except that the data operated on is the
%     cumulative sum of the Hough signature of the amplitude histogram.
%   if mode: 'l2norm_hist', stats is a number representing the L2 norm of the
%     two amplitude histograms.
%   if mode: 'l2norm_hough', stats is a number representing the L2 norm of the
%     two Hough signatures.
%
% Author: Sam Xi

function stats = twohistanalyze(data_1, data_2, mode)
  if (strcmp(mode, 'counts_diff'))
    end_index = getShorterLength(data_1.graph, data_2.graph);
    graph_1 = data_1.graph(1:end_index);
    graph_2 = data_2.graph(1:end_index);
    d1_total_counts = sum(graph_1);
    d2_total_counts = sum(graph_2);
    max_diff = max(abs(graph_1 - graph_2));
    max_graph_1 = max(graph_1);
    total_count_diff = d1_total_counts - d2_total_counts;
    stats = [d1_total_counts d2_total_counts ...
              total_count_diff total_count_diff/d1_total_counts*100 ...
              max_diff max_diff/max_graph_1*100];
  elseif (strcmp(mode, 'xcorr_hist'))
    ndata_1 = data_1.graph/max(data_1.graph);
    ndata_2 = data_2.graph/max(data_2.graph);
    stats = corr_stats(ndata_1, ndata_2);
  elseif (strcmp(mode, 'hough_corr'))
    ndata_1 = data_1.hough_sig/max(data_1.hough_sig);
    ndata_2 = data_2.hough_sig/max(data_2.hough_sig);
    stats = corr_stats(ndata_1, ndata_2);
  elseif (strcmp(mode, 'cumhough_corr'))
    ndata_1 = data_1.hough_sig/max(data_1.hough_sig);
    ndata_2 = data_2.hough_sig/max(data_2.hough_sig);
    stats = corr_stats(cumsum(ndata_1), cumsum(ndata_2));
  elseif (strcmp(mode, 'l2norm'))
    stats = l2norm(data_1.hough_sig, data_2.hough_sig);
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

function stats = l2norm(hist1, hist2)
  hist1 = hist1/max(hist1);
  hist2 = hist2/max(hist2);
  l2 = sqrt(sum((hist1-hist2).^2));
  stats = l2;
end
