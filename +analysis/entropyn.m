% ENTROPYN
%
% Computes the n-symbol entropy in the given input string. If the input string
% is an array of floating point values, each value is converted into the
% standard IEEE754 format and broken into 8 8-bit symbols. If the input string
% is an array of integers, each integer is treated as an 8-bit symbol.
%
% Symbols are then grouped into n-grams, their probabilities tabulated over the
% entire input string, and the Shannon entropy computed from that.
%
% Syntax:
%   [H c] = entropyn(input, n)
%     input = input string
%     n = number of symbols over which to compute the entropy.
%     H = entropy of the input string
%     c = a container.Map object containing key-value pairs of n-gram to the
%     number of occurrences. Keys are in the string format '[\d;\d;\d;...]'.
%     This can be converted to an array via str2mat.
%
% Author: Sam Xi

function [H tracker] = entropyn(input, n)
  if (nargin < 2)
    error('Missing input argument.')
  end
  nValues = length(input);
  tracker = containers.Map({''}, {[]});
  tracker.remove('');
  
  % translate ciphertext into bytes
  if (strcmp(class(input), 'double'))
    str = [];
    for i=1:nValues
        val = input(i);
        s = util.ieee754(val);
        s8bit = [s(1:8); s(9:16); s(17:24); s(25:32); ...
                 s(33:40); s(41: 48); s(49: 56); s(57:64)];
        str = [str; bin2dec(s8bit)];
        r = mod(length(str), n);
        if (i == nValues && r ~= 0)  % zeropad at the very end
          str = [str; zeros(n-r, 1)];
          r = 0;
        end
        s_temp = str(1:end-r);
        str = str(end-r+1:end);
        ngrams = reshape(s_temp, n, length(s_temp)/n);
        for j=1:size(ngrams, 2)
          key = mat2str(ngrams(:, j));
          if (tracker.isKey(key))
            tracker(key) = tracker(key) + 1;
          else
            tracker(key) = 1;
          end
        end
     end
  elseif (strcmp(class(input), 'int8'))
    nbits = 8*nValues;
    negative = find(input < 0);
    newinput = single(input(negative) + 128);
    tracker = hist(newinput, 256);
%     for i=1:nValues
%       val = input(i);
%       s = dec2bin(val);
%       numOnes = length(find(s+0 == 49));
%       numZeros = 8 - numOnes;
%       tracker(1) = tracker(1) + numZeros;
%       tracker(2) = tracker(2) + numOnes;
%     end
  end
  vals = cell2mat(tracker.values);
  p = vals/sum(vals);
  p(p == 0) = [];
  H = -sum(p.*log2(p));
end