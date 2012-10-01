% BAR3_RELCOLOR    Plots a 3D bar chart by relative amplitude.
%
% Given a square matrix of data, this script transforms each row of data such
% that each value in each row maps to its sorted position, so that the smallest
% value in each row corresponds to 1, the second smallest value to 2, and so
% on. This is then plotted on a 3D bar chart and colored using a colormap with
% just two distinct colors, in which the smallest value is one color and all the
% other values are the other color. This allows us to easily distinguish the
% smallest elements in each row.
% 
% Example:
% [15 23 3  4  76  => [3 4 1 2 5
%  4  90 22 34 17]     1 5 3 4 2]
% meaning that 15 is the 3rd smallest value in its row, 23 is the 4th smallest
% value in its row, etc.
%
% SYNTAX:
%     handle = bar3_color(data) plots data as a 3D barchart, colors it by
%       comparative amplitude, and returns a handle to the figure. data must be
%       a square matrix.
%
% Obtained from: http://www.mathworks.com/matlabcentral/newsreader/view_thread/
% 141194

function handle = bar3_relcolor(data)
  % Rearranges the data so that the smallest value in data corresponds to 1 and
  % the largest value corresponds to size(data, 1).
  [results indices] = sort(data, 2, 'ascend');
  sorted = zeros(size(indices));
  cols = 1:size(indices, 2);
  for row=1:size(indices, 1)
    sorted(row, indices(row, cols)) = cols;
  end
  barmin = min(sorted(:));
  barmax = max(sorted(:));
  bh=bar3(sorted);
  for i=1:length(bh)
    set(bh(i),'cdata', ...
        get(bh(i), 'zdata'));
  end
  numcolors = size(data, 2);
  colormap(getColorMap(numcolors, 1));
  caxis([barmin barmax]);
  colorbar;
  shading interp;
  handle = bh;
  view(2);
end

% Returns a colormap with num_colors number of colors, in which all but the
% n colors are gray. This enables us to color the bar graph such that the
% smallest n values are n colors and everything else is uniformly gray.
%
% SYNTAX:
%   map = getColorMap(total_colors, distinct_colors)
%     total_colors: The total number of colors to map.
%     distinct_values: The number of smallest values to color distinctly.
%     map: The generated colormap.
function map = getColorMap(total_colors, distinct_colors)
  green_color = [.75 .75 .75];
  map = kron(green_color, ones(total_colors, 1));  % Make everything one color.
  map(1:distinct_colors, :) = lines(distinct_colors);
end