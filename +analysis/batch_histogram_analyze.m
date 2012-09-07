function out = batch_histogram_analyze(dir)
  % Load all the histogram data.
  current_dir = pwd;
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
    total_array{d} = data_array;
  end

  % Run the analysis scripts. Assume two subdirs.
  num_files = length(total_array{1});
  diffs = zeros(num_files, 6);
  headers = ['  data1 total', ...
             '  data2 total', ...
             '   total diff', ...
             ' total diff %%', ...
             '     max diff', ...
             '   max diff %%', ...
             '\n'];
  fprintf(headers);
  for i=1:num_files
    encrypt_struct = total_array{1}(i);
    decrypt_struct = total_array{2}(i);
    diffs(i, :) = analysis.twohistanalyze(encrypt_struct, decrypt_struct, ...
                                          'counts_diff');
    fprintf('%13d%13d%13d%13.2f%13d%13.2f\n', diffs(i,:));
  end
  out = diffs;
end
