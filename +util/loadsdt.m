% SDT ASCII file data loader
% 02/14/11
% Sam Xi

function data = loadsdt(fname)

fid = fopen(fname, 'r'); % open file for reading
if (fid == -1)
    error('Invalid file specified.')
end

%% read header

% read number of fluorophores
line = fgetl(fid);
while (strncmp(line, '*BLOCK 1 Decay', 14) == 0)
    line = fgetl(fid);
end

% set up data array
lines = 4096;
data = zeros(1, lines);
entry = 1; % row counter
%% Begin reading data
line = fgetl(fid);
if (strncmp(line, '*END', 4))
    line = -1;
end
while (line ~= -1)
%     if (mod(entry, 1000)==0)
%         fprintf('Processing entry: %d\n', entry);
%     end
    % convert to integers/strings 
    data(1, entry) = str2num(line);
    line = fgetl(fid);
    entry = entry + 1;
    if (strncmp(line, '*END', 4))
        line = -1;
    end
end
fclose(fid);
end