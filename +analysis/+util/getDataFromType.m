% GETDATAFROMTYPE
% Returns an array that corresponds to the type of data needed for a particular
% computation. 
% SYNTAX:
%   data = getDataFromType(data_struct, data_type)
%     data_struct: A structure object created by asc2mat.
%     data_type: A string indicating what kind of data to be extracted from the
%       struct. 'hist' returns data_struct.graph, the raw amplitude histogram.
%       'hough' returns data_struct.hough_sig, the Hough signature. 'cumhough'
%       returns the cumulative sum of the Hough signature.
%
% Author: Sam Xi
function data = getDataFromType(data_struct, data_type)
  if (strcmp(data_type, 'hist'))
    data = data_struct.graph;
  elseif (strcmp(data_type, 'hough'))
    data = data_struct.hough_sig;
  elseif (strcmp(data_type, 'cumhough'))
    data = cumsum(data_struct.hough_sig);
  end
end
