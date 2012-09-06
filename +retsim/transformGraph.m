% Sam Xi
% 03/13/11
% Transforms the graph data into a linear-time sparse matrix so that it can
% be plotted with accuracy, without any extra memory requirements.
%
% Syntax:
%           newGraph = transformGraph(graph, times)
%                   graph = data to be transformed
%                   times = list of times at which events occur. 
%
%           returns: a MATLAB sparse array in which rows correspond to
%           linearly spaced time, starting from times(1) and ending at
%           times(2).

function newGraph = transformGraph(graph, times)

% determine along which dimension to expand graph.
len = length(times);
dim = find(size(graph)==len);
newGraph = spalloc(size(graph,1), size(graph,2), numel(graph));
offset = 0;
if (times(1)<=0)
    offset=1;
end
if (dim==1)
   for i=1:length(times)
      newGraph(times(i)+offset,:) = graph(i,:);
   end
else
    for i=1:length(times)
       newGraph(:, times(i)+offset) = graph(:, i); 
    end
end
end