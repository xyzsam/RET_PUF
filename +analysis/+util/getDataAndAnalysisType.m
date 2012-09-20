% GETDATAANDANALYSISTYPE
%
% Parse the user supplied mode for the data and analysis type.
%
% [data_type analysis_type] = getDataAndAnalysisType(mode) returns the data
% type and analysis type indicated by mode, where mode is in the format
% <data_type>_<analysis_type>, unless mode="countsdiff", in which analysis_type 
% = "counts_diff" and data_type = "hist".
%
% Author: Sam Xi

function [data_type analysis_type] = getDataAndAnalysisType(mode)
  if (strcmp(mode, 'countsdiff'))
    analysis_type = mode;
    data_type = 'hist';
  else
    analysis_type = char(regexp(mode, '\w+(?=_)', 'match'));
    data_type = char(regexp(mode, '(?<=_)\w+', 'match'));
  end
end

