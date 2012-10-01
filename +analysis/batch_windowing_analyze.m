% BATCH_WINDOWING_ANALYZE   Intrapuf analysis on data in time windows
%
% The RET-PUF cryptoprotocol relies on being able to identify matching IX pairs
% with only a small fraction of the full histogram. This script is a wrapper
% around batch_intrapuf_analyze, taking an extra parameter that specifies a time
% window. The histogram data in that time window is extracted for all the data
% in the provided directory and processed according to the mode parameter.
%
% SYNTAX:
%   result = batch_windowing_analyze(dir, mode, start_time, end_time)
%     dir: See documentation for batch_intrapuf_analyze.
%     mode: See documentation for batch_intrapuf_analyze.
%     start_time: The beginning of the time window in ns.
%     end_time: The end of the time window in ns.
%     result: The return values of the analysis. This could be more than one
%       variable - see documentation for batch_intrapuf_analyze.
%
% This script works on either raw amplitude histograms or the Hough signature.
% Which set of data the script operates on is determined by the mode.
% Bounds of the time window are both inclusive. It will pick the closest time
% to the desired time window bounds.
%
% Author: Sam Xi

function varargout = batch_windowing_analyze(dir, mode, start_time, end_time)
  import analysis.*;
  import analysis.util.*;
  datasets = load_structs(dir);
  if (isempty(datasets))
    fprintf('No datasets were provided.\n');
    return;
  end
  start_time = start_time * 1e-9;
  end_time = end_time * 1e-9;
  num_files = length(datasets{1});
  num_dirs = length(datasets);
  for dir=1:num_dirs
    for i=1:num_files
      dataset = datasets{dir}(i);
      [data_type analysis_type] = getDataAndAnalysisType(mode);
      [timeaxis start_index end_index] = getIndexFromTimeAxis(...
        dataset, [start_time end_time], data_type);
      data = getDataFromType(dataset, data_type);
      data = data(start_index:end_index);
      dataset = setNewDataByDataType(dataset, data, data_type);
      datasets{dir}(i) = dataset;
    end
  end
  [varargout{1:nargout}] = batch_intrapuf_analyze(datasets, data_type, ...
                                                  analysis_type);
end

function index = getIndexOfClosestMatch(array, value)
  m = abs(array - value);
  index_temp = find(min(m)==m);
  index = index_temp(1);  % Return the first match.
end

% Returns a proper timeaxis for the data and the data type. For instance, this
% will return a different array for data_type = 'hough' than it will for
% data_type = 'hist'.
function timeaxis = getTimeAxisFromDataType(dataset, data_type)
  if (strcmp(data_type, 'hist'))
    timeaxis = 0:dataset.time_div:dataset.time_div*(length(dataset.graph)-1);
  elseif (strcmp(data_type, 'hough') || strcmp(data_type, 'cumhough'))
    timeaxis = dataset.time_div./(tand(90-dataset.theta_range)) * ...
               1e9 * dataset.scale_factor;
  end
end

% Sets the appropriate field in the dataset struct to the array data based on
% data_type.
% if data_type = 'hist': dataset.graph = data.
% if data_type = 'hough' or 'cumhough': dataset.hough_sig = data.
function dataset = setNewDataByDataType(dataset, data, data_type)
  if (strcmp(data_type, 'hist'))
    dataset.graph = data;
  elseif (strcmp(data_type, 'hough') || strcmp(data_type, 'cumhough'))
    dataset.hough_sig = data;
  end
end
