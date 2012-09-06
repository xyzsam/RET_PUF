% Windowing average
% 02/17/12
% Sam Xi
% Applies a windowing average function to a set of data.
%
% SYNTAX
%
%       data = windowavg(input, window_size)
%              input = raw data extracted from the TCSPC's ASCII output
%              window_size = number of data points to smooth over
%              data = averaged data

function data = windowavg(input, window_size)

% new data array
data = zeros(2, size(input, 2)-window_size+1);
data(1,:) = 1:size(data,2);

for i=1:size(data, 2)
    avg = 0;
    for j=0:window_size-1
        avg = avg+input(2, i+j);
    end
    avg = avg/window_size;
    data(2, i) = avg;
end

end