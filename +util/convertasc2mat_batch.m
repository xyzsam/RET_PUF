% Sam Xi
% 3/18/2012
% Converts an entire directory of .asc files to .mat

function out = convertasc2mat_batch(dir)
import util.*;

if (nargin < 1)
    error('Need to specify directory.\n'); 
end
cur_dir = pwd;
%dir = 'D:\Documents\My Dropbox\Dwyer\Measurements\sa1 sa2 ix measurements';
% cd(dir)
list = ls(strcat(dir, '\*.asc'));
for i=1:size(list,1)
    name = deblank(list(i,:));
    path = strcat(dir, '\', name);
    fprintf('Processing file %s, %d of %d...\n', name, i, size(list,1));
    if (exist(path, 'file'))
       s = loadsdt(path);
       % This is the time range in ns for the saved data. For instance, the
       % data in array s might correspond to the time range 0-50ns, so we
       % would use start_time = 0 and end_time = 50.
       total_time = 50;
       time_div = 1.22e-11;
       data = asc2mat(s, total_time, time_div, name);
       newname = path(1:end-3);
       newname = strcat(newname, 'mat');
       eval(sprintf('save -mat ''%s'' data;', newname));
    end
end
%cd(cur_dir)
end