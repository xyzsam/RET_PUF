% Sam Xi
% 2/26/11
% Load emission data from dye list
%
% emission = loadDye(dye, dyelist, dyeDBpath)
%           dye = string containing abbreviation for dye.
%           dyelist = file containing the file names of each dye
%           dyeDB = directory containing dye excitation and emission data.
%           emission = emission spectra of this dye. First column is
%               the wavelength, second column is the intensity.

function emission = loadDye(dye, dyelist, dyeDBpath)

if (nargin < 3)
    error('Not enough inputs to load dyes.')
elseif ~(ischar(dye) && ischar(dyelist) && ischar(dyeDBpath))
    error('All inputs must be provided as strings.')
end
% open dyelist
dyeDB = cell(1, 2); % dye database
fid1 = fopen(dyelist, 'r');
line = fgetl(fid1);
entry = 1;
while (line ~= -1)
    f=regexp(line, '(\ *|\t*)', 'split');
    dyeDB{entry, 1} = f{1,1};
    dyeDB{entry, 2} = f{1,2};
    line = fgetl(fid1);
    entry = entry+1;
end
fclose(fid1);
% find requested dye in the database
idx = find(ismember(dyeDB, dye)==1);
row = idx - size(dyeDB, 1);
dyefname = dyeDB{row, 1};

% create filepath to dye
if (dyeDBpath(end)=='\')
    filepath = strcat(dyeDBpath, dyefname, '.txt');
else
    filepath = strcat(dyeDBpath, '\', dyefname, '.txt');
end

fid = fopen(filepath, 'r');
line = fgetl(fid);
while (isempty(str2num(line(1))))
   line = fgetl(fid); 
end
emission = zeros(1, 2);
entry = 1;

while (line ~= -1)
data = regexp(line, '\,', 'split'); % parse the numbers.
dataS = char(data); % convert to character array
% dlen = 4;
% check for empty rows
% for i = size(dataS, 1)
%    if size(find((isspace(dataS(i, :))==0)), 2) == 0
%        dlen = dlen-1;
%    end
% end
col1 = 3; col2 = 4;
if (length(data) ~= 2)
    if (isempty(data{3}) == 1 && isempty(data{4}) == 1)
        col1 = 1; col2 = 2;
    end
end
%fprintf('entry: %d, col1:%d, col2:%d\n', entry, col1, col2);    
emission(entry, 1) = str2num(deblank(dataS(col1,:)));
emission(entry, 2) = str2num(deblank(dataS(col2,:)));
entry = entry + 1;  
line = fgetl(fid);
end
fclose(fid);
end