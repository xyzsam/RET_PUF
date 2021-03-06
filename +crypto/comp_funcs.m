% COMP_FUNCS    Returns a comparison function for two streams of data.
% 
% This script returns a handle to a comparison function that can be called on
% two streams of data. The function returns a value that indicates the level of
% similarity between the two streams. The value's interpretation is up to the
% user of the function to determine - that is, the bounds of the value is not
% fixed and either smaller or larger values may indicate greater similarity.
%
% Syntax:
%   func = comp_funcs(type)
%   type: A string. Valid types are:
%     'l2norm_hist': Sum of squares of differences of the histograms.
%     'l2norm_loghist': Sum of squares of differences of ln(histograms).
%     'conv_max': Maximum of the convolution.
%     'conv_int': Integral of the convolution, with the trapezoidal approximation.
%     'rel_conv_max': Compares the maximum of the convolution of the two data
%       streams and the convolution of the first data stream with itself.
%       Returns the ratio of the two. A larger return value indicates a
%       greater degree of similarity.
%     'meandiff': Difference of the means.
%   func: A function handle. It takes two streams of data as input and returns
%     a similarity value. Syntax: val = func(data1, data2);

function func = comp_funcs(type)
  if (strcmp(type, 'l2norm_hist'))
    func = @sum_square;
  elseif (strcmp(type, 'l2norm_loghist'))
    func = @sum_square_log;
  elseif (strcmp(type, 'conv_max'))
    func = @conv_max;
  elseif (strcmp(type, 'conv_int'))
    func = @conv_int;
  elseif (strcmp(type, 'rel_conv_max'))
    func = @rel_conv_max;
  elseif (strcmp(type, 'mean_diff'))
    func = @mean_diff;
  elseif (strcmp(type, 'f_test'))
    func = @f_test;
  else
    error('Invalid type of comparison function.');
  end
end

  function val = sum_square(data1, data2)
    val = sqrt(sum((data1-data2).^2));
    val = 1/val;  % This makes larger values correspond to greater similarity.
  end
  
  % Computes the sum of squares of differences on the log of the raw counts,
  % which have been normalized to an area of 1.
  function val = sum_square_log(data1, data2)
    data1 = log(data1);
    data2 = log(data2);
    longer_length = max(length(data1), length(data2));
    combined = zeros(2, longer_length);
    combined(1, 1:length(data1)) = data1/trapz(data1);
    combined(2, 1:length(data2)) = data2/trapz(data2);
    l2n = sqrt(sum((combined(1,:)-combined(2,:)).^2));
    val = 1/l2n;  % This makes larger values correspond to greater similarity.
  end

  function val = conv_int(data1, data2)
    c = conv(data1, data2);
    val = trapz(c);
  end
  
  function val = conv_max(data1, data2)
    c = conv(data1, data2);
    val = max(c);
  end
  
  function val = rel_conv_max(data1, data2)
    conv2 = conv(data1, data2);
    conv1 = conv(data1, data1);
    % Subtracting 1 favors ratios closer to unity.
    diff_1 = abs(max(conv2)/max(conv1)-1);
    val = 1/diff_1;
  end
  
  function val = mean_diff(data1, data2)
    val = mean(data1) - mean(data2);
    val = 1/val;  % This makes larger values correspond to greater similarity.
  end
  
  function val = f_test(data1, data2)
    val = vartest2(data1, data2, .10);
  end