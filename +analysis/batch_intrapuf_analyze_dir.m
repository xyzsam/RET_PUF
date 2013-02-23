% BATCH_INTRAPUF_ANALYZE_DIR    Compare data for different IXs on the same PUF.
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
%
% ssd = batch_intra_puf_analyze(dir, mode) computes sum of squares of
% differences on all IX pairs. ssd is an nxn matrix where n is the number of IX
% pairs. All data sets are normalized to a maximum of 1 before any computation
% is performed.
%   Valid modes:
%     'ssd_hist' operates on the raw amplitude histograms.
%     'ssd_hough' operates on the Hough signatures.
%     'ssd_cumhough' operates on the cumulative Hough signature sums.
%
% Note that in order for this script to work properly, the two directories must
% contain data files which, when sorted by name, match exactly. Otherwise, the
% wrong data sets will be compared.
%
% For more details, see the documentation for the corresponding mode in
% analysis.twohistanalyze.
%
% Author: Sam Xi

function varargout = batch_intrapuf_analyze_dir(dir, mode)
  import analysis.*;
  import analysis.util.*;
  datasets = load_structs(dir);
  [data_type analysis_type] = getDataAndAnalysisType(mode);
  [varargout{1:nargout}] = batch_intrapuf_analyze( ...
      datasets, data_type, analysis_type);
end
