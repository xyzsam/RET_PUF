% ENTROPYN
%
% Computes the n-symbol entropy for the given file. The binary data is broken
% into 8 8-bit symbols. Symbols are then grouped into n-grams, their
% probabilities tabulated over the entire input string, and the Shannon entropy
% computed from that.
%
% Syntax:
%   [H c] = entropyn(fname, n)
%     fname = file name
%     n = number of symbols over which to compute the entropy.
%     H = entropy of the input string
%     c = a container.Map object containing key-value pairs of n-gram to the
%     number of occurrences. Keys are in the string format '[\d;\d;\d;...]'.
%     This can be converted to an array via str2mat.
%
% Author: Sam Xi

function [H tracker] = entropynfile(fname, n)
  if (nargin < 2)
    error('Missing input argument.')
  end
  tracker = containers.Map({''}, {[]});
  tracker.remove('');
  
  fid = fopen(fname, 'r');
  ngram = fread(fid, n);
  while (~isempty(ngram))
      if (length(ngram) < n)  % zeropad at the very end
        ngram = [ngram; zeros(n-length(ngram), 1)];
      end
      key = mat2str(ngram);
      if (tracker.isKey(key))
        tracker(key) = tracker(key) + 1;
      else
        tracker(key) = 1;
      end
      %numOnes = length(find(s+0 == 49));
      %numZeros = length(s) - numOnes;
      %tracker(1) = tracker(1) + numZeros;
      %tracker(2) = tracker(2) + numOnes;
      ngram = fread(fid, n);
  end
  fclose(fid);
  vals = cell2mat(tracker.values);
  p = vals/sum(vals);
  p(p == 0) = [];
  H = -sum(p.*log2(p));
end