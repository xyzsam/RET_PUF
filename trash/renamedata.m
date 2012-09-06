% Sam Xi
% 4/15/12
% Renaming script
%
% Figures out a filename and puts into a consistent format

function out = renamedata(dir) 

if (nargin < 1)
    dir = pwd;
else
    cd(dir);
end

files = ls('*.asc');
nfiles = size(1,files);

for i=1:nfiles
    name = deblank(files(i, :));
    type = regexp(name, 'sa\d', 'match');
    
end

end