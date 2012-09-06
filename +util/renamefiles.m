% RENAMEFILES
% Renames files that use underscores rather than commas to separate input
% combination numbers. Also, adds in appropriate emission data if it is
% missing.
% Example output: sa114_ic0_i10_10.asc => sa114_ic0_i10,10_em620.asc.

function data = renamefiles(dir, emission)
current_dir = pwd;
cd(dir)
list = ls('s*');
for i=1:size(list,1)
  fname = list(i,:);
  fname = deblank(fname);
  [str matchstart matchend] = regexp(fname, 'i[\d+|_]+', 'match', 'start', 'end');
  str = strrep(str, '_', ',');
  extension = regexp(fname, '\.\w+', 'match');
  % Convert single cells to strings.
  extension = extension{1};
  str = str{1};
  newstr = '';
  if (nargin > 1)
    emission_str = num2str(emission);
    newstr = strcat(fname(1:matchstart-1), str, '_em', emission_str, extension);
  else
    newstr = strcat(fname(1:matchstart-1), str, extension);
  end
  movefile(fname, newstr);
end
cd(current_dir)
end