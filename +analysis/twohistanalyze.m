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
%
% Author: Sam Xi
function stats = twohistanalyze(data_1, data_2, mode)
  if (strcmp(mode, 'counts_diff'))
    end_index = @getShorterLength(data_1.graph, data_2.graph);
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
    cross_corr = xcorr(data_1.graph, data_2.graph);
    auto_corr = xcorr(data_1.graph, data_1.graph);
    corr_integral = trapz(corr);
    corr_max = max(corr);
    corr_ratio = corr_max/max(auto_corr);
    stats = [corr_integral corr_max corr_ratio];
  end
end

function short_length = getShorterLength(hist1, hist2)
  if (length(hist1) > length(hist2))
    short_length = length(hist2)
  else
    short_length = length(hist1)
  end
end
