% Sam Xi
% 03/23/11
% Graph a spectrum
% Quick function for graphing a spectrum.
%
% SYNTAX:   v = graphspectra(graph, keySet, tbin, t)
%
%           graph : spectral data
%           keySet: vector containing time bin information
%           tbin  : size of a time bin
%           t     : title of the graph
%

function v = graphspectra(graph, keySet, tbin, t)
s='a';
while (ischar(s) || s<0 || s>3)
    s = input('What kind of plot do you want to see? Type the number of the option.\n1. Surface\n2. Mesh\n3. Wireframe\nOption: ');
    if (ischar(s) || s<0 || s>3)
        fprintf('\nInvalid choice, please try again\n')
    end
end
if (keySet(1) == -1)
    keySet = keySet(2:length(keySet));
    graph = graph(:, 2:size(graph,2));
end
[tmesh wmesh] = meshgrid(keySet, 1:size(graph,1));
if (s==1)
    h = surfc(tmesh, wmesh, graph);
    set(h, 'edgecolor', 'none')
elseif (s==2)
    meshc(tmesh, wmesh, graph);
elseif (s==3)
    plot3(tmesh, wmesh, graph);
end
xlabel(sprintf('Time Bin (%d ps)', tbin))
ylabel('Wavelength (nm)')
zlabel('Intensity')
title(t)

end
