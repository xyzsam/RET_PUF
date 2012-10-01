% GETINDEXFROMTIMEAXIS  Helper function to index into the time axis.
%
% This functions returns an array for the time axis of a photon count histogram
% and the start and end indices corresponding to a time range on that axis. The
% time axis can either mean time bin of photon detection or the lifetime of the
% Hough signature of a histogram, as indicated by the mode.
%
% SYNTAX:
% [timeaxis s e] = getIndexFromTimeAxis(dataset, [sub_start sub_end], mode)
%   dataset: A TCSPC structure, created from asc2mat.
%   sub_start: the start of the time range within the time axis.
%   sub_end: the end of the time range within the time axis.
%   mode: 'hist', 'hough', or 'cumhough' depending on which data type is desired.
%
% Returns:
%   timeaxis: the complete time axis, ranging from start_time to
%     end_time - time_div.
%   s: the index of sub_start in the time axis, inclusive.
%   e: the index of sub_end in the time axis, exclusive.

function [timeaxis s e] = getIndexFromTimeAxis(dataset, sub_time_range, mode)

  sub_start = sub_time_range(1);
  sub_end = sub_time_range(2);
  
  if (strcmp(mode, 'hist'))
    timeaxis = 0:dataset.time_div:dataset.time_div*(length(dataset.graph)-1);
  elseif (strcmp(mode, 'hough') || strcmp(mode, 'cumhough'))
    timeaxis = dataset.time_div./(tand(90-dataset.theta_range)) * ...
               1e9 * dataset.scale_factor;
  else
    error('Invalid mode parameter.');
  end
  
  s = getIndexOfClosestMatch(timeaxis, sub_start);
  e = getIndexOfClosestMatch(timeaxis, sub_end);
  
  % Ensure that s and e lie within the bounds of the timeaxis array.
  if (s == -1)
    s = 0;
  end
  if (e == -1)
    s = length(timeaxis);
  end
  
end

function index = getIndexOfClosestMatch(array, value)
  m = abs(array - value);
  index_temp = find(min(m)==m);
  if (~isempty(index_temp))
    index = index_temp(1);  % Return the first match.
  else
    index = -1;
  end
end