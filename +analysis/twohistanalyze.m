% TWOHISTANALYZE  Compute statistics on two RET-PUF histograms.
%
% This script will compare two histograms from an experiment and compute various
% statistics that represent the amount that the two histograms differ. This is
% used to determine how similar two histograms from two different batches of the
% same PUF is used, for example.
%
% SYNTAX:
%   function stats = twohistanalyze(encrypt_struct, decrypt_struct, mode)
%     encrypt_struct: structure containing encryption data
%     decrypt_struct: structure containing decryption data
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
%         at any one given time.
%       The sixth element is the maximum percent difference between the two
%         histograms at any one given time.
%     To prevent strange data collection errors from intefering with
%     this metric, all leading and trailing zeros have been stripped from the
%     histograms.
%
% Author: Sam Xi
function result = twohistanalyze(encrypt_struct, decrypt_struct, mode)
  if (strcmp(mode, 'counts_diff'))
    if (length(encrypt_struct.graph) > length(decrypt_struct.graph))
      end_index = length(decrypt_struct.graph);
    else
      end_index = length(encrypt_struct.graph);
    end
    graph_1 = encrypt_struct.graph(1:end_index);
    graph_2 = decrypt_struct.graph(1:end_index);
    encrypt_total_counts = sum(graph_1);
    decrypt_total_counts = sum(graph_2);
    max_diff = max(abs(graph_1 - graph_2));
    total_count_diff = abs(encrypt_total_counts - decrypt_total_counts);
    result = [encrypt_total_counts decrypt_total_counts ...
              total_count_diff max_diff];
  end
end
