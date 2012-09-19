% BAR3_COLOR    Plots a 3D bar chart with an amplitude colormap.
%
% By default, bar3 colors the bar chart by column of data. This plots the bar
% chart and shades it by comparative amplitude, so that trends are more easily
% seen. The colormap used is 'jet'.
%
% SYNTAX:
%     handle = bar3_color(data) plots data as a 3D barchart, colors it by
%       comparative amplitude, and returns a handle to the figure.
%
% Obtained from: http://www.mathworks.com/matlabcentral/newsreader/view_thread/
% 141194

function handle = bar3_color(data)
  barmin = min(data(:));
  barmax = max(data(:));
  bh=bar3(data);
  for i=1:length(bh)
    set(bh(i),'cdata',...
    get(bh(i),'zdata'));
  end
  colormap(jet(barmax+1));
  caxis([barmin barmax]);
  colorbar;
  shading interp;
  handle = bh;
end
