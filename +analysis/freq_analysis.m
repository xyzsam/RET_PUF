% FREQ_ANALYSIS   Performs alphabetic frequency analysis on an array of doubles.
%
% freqs = freq_analysis(m) converts the floating point values in array m into
% IEEE754 format, parses them into 8 bit chunks, and builds a histogram of the
% number of occurrences of each 8 bit segment. This histogram is returned as
% freqs, where freqs(i) is the number of occurrences of the 8 bit
% representation of the integer i-1 (due to MATLAB array indexing).
%
% Author: Sam Xi

function freqs = freq_analysis(m)
  if (~isfloat(m) || size(m, 1) > 1)
    error('m must be an single dimension array of floating point values.');
  end

  freqs = zeros(256, 8);
  for i=1:length(m)
    s = util.ieee754(m(i));
    s8bit = [s(1:8); s(9:16); s(17:24); s(25:32); ...
             s(33:40); s(41: 48); s(49: 56); s(57:64)];
    intvalues = bin2dec(s8bit) + 1;
    for j=1:8
      freqs(intvalues(j), j) = freqs(intvalues(j), j) + 1;
    end
  end
  freqs = freqs';
end