% LOAD_STRUCTS    Load experimental data in a directory.
%
% Loads all the experimental histogram data located in a directory and stores
% the data in a structure array. It assumes that there are two subdirectories
% named '1' and '2' in the provided directory and loads the data separately for
% the subdirectories. Data for '1' and '2' are placed under all{1} and all{2},
% respectively.

function all = load_structs(dir)
  % Load all the histogram data. data_array is a 1xn structure array, where n is
  % the number of data files per directory. all is a 1xm cell array,
  % where m is the number of directories. m is usually 2 - twohistanalyze only
  % compares two histograms at a time. n corresponds to the number of distinct
  % input combinations that are being analyzed.
  sub_dirs = ['1', '2'];
  for d=1:length(sub_dirs)
    dir_path = [dir, '\', sub_dirs(d), '\'];
    files = ls([dir_path, '*.mat']);
    clear data_array;  % Delete this array if it already exists.
    for i=1:size(files, 1);
      filename = deblank(files(i, :));
      load([dir_path, filename]);
      data_array(i) = data;  % Dynamically create this structure array.
    end
    all{d} = data_array;  % Dynamically create this structure array too.
  end
end
