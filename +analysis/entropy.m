% ENTROPY
%
% Computes the n-bit entropy in the given input string. If the input string is
% an array of floating point values, each value is converted into the standard
% IEEE754 format. If the input string is an array of integers, each integer is
% treated as an 8-bit value.
%
% Syntax:
%   [H c] = entropy(input, n)
%     input = input string
%     n = number of bits over which to compute the entropy.
%     H = entropy of the input string.
%     c = an array in which c(i) is the number of times the byte i occurred in
%     the string. H = -sum(c.*log2(c)).
%
% Author: Sam Xi

function [H tracker] = entropy(input, n)
  if (nargin < 1)
    error('Missing input argument.')
  end
  nValues = length(input);
  tracker = zeros(1, 2^n);
  
  % translate ciphertext into bytes
  if (strcmp(class(input), 'double'))
    s = '';
    for i=1:nValues
        val = input(i);
        s = strcat(s, util.ieee754(val));
        r = mod(length(s), n);
        if (i == nValues && r ~= 0)  % zeropad at the very end
          s = strcat(s, char(48*ones(1, n-r)));
          r = 0;
        end
        s_temp = s(1:end-r);
        s = s(end-r+1:end);
        s_broken = reshape(s_temp, n, length(s_temp)/n)';       
        bytes = bin2dec(s_broken)';
        tracker(bytes+1) = tracker(bytes+1) + 1;
        %numOnes = length(find(s+0 == 49));
        %numZeros = length(s) - numOnes;
        %tracker(1) = tracker(1) + numZeros;
        %tracker(2) = tracker(2) + numOnes;
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
  p = tracker/sum(tracker);
  p(p == 0) = [];
  H = -sum(p.*log2(p));
end