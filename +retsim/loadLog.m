% RETSim Analyzer - Data Loader.
% 02/14/11
% Sam Xi
% This loads the data from a trace file generated by RETSim. 
% Do not strip the header data from the trace file first! This information
% is required to parse the data correctly.
% 
% The function accepts one parameter: the path to the log file. It can be
% absolute or relative. It returns an integer array containing the parsed
% trace data.
%
% The data in a trace file is structured like this:
% Time          Fluorophore             Laser
% ------      ---------------        ----------
% 1           .     F0      *        [5 5]
% Time is in units specified by the experiment file. Typically it is
% picoseconds. There are n columns in the fluorophore, corresponding to the
% n fluorophores in the experiment. The value in the column indicates the
% activity of the particular fluorophore. 
% Symbols:
%   .       = no activity
%   Fn      = excitation by the nth fluorophore (F0 = zeroth fluorophore)
%   Ln      = excitation by the nth laser (L0 = zeroth laser)
%   *       = emission of photon (fluorescence)
%
% A + symbol at the end of a time indicates that only the last row of that
% time elemFent should be considered - in other words, all entries beginning
% with 1+ except the last should be ignored.
%
% The integer array returned is broken into these three sections: time,
% fluorophores, and lasers.
%
% The time column has no '+'s, only the relevant rows. 
% The laser columns comprise the last n columns.
% Fluorophore activity is given by the following table:
%   0           = no activity
%   1           = fluorescence
%   1000 - 1999 = excitation by a fluorophore. 1000 -> zeroth fluorophore,
%                 1001 -> first fluorophore, etc.
%   2000 - 2999 = excitation by a laser. 2000 -> zeroth laser, 2001 = first
%                 laser, etc.
%
% This script assumes that a given experiment uses no more than 1000
% fluorophores and 1000 lasers. This is not rigid and is easily modified.
%
% The first row contains information about the experiment. The first
% element is the number of fluorophores, and the second is the number of
% lasers.

function data = loadLog(fname)


fid = fopen(fname, 'r') % open file for reading
if (fid == -1)
    error('Invalid file specified.')
end

%% read header

% read number of fluorophores
line = fgetl(fid);
while (strncmp(line, 'Fluorophore', 11) == 0)
    line = fgetl(fid);
end
numF = 0;
line = fgetl(fid);
while (line(1) ~= '.')
    numF = numF+1;
    line = fgetl(fid);
end

% read number of lasers
numL = 0;
while (strncmp(line, 'Laser', 5) == 0)
    line = fgetl(fid);
end
line = fgetl(fid);
while (~isempty(line))
    numL = numL+1;
    line = fgetl(fid);
end
fprintf('Loaded %d fluorophores, %d lasers\n', numF, numL)
fgetl(fid); % skip over another line of column headers
% set up data array
data = zeros(2, 1+numF+numL);
entry = 2; % row counter
firstTime = 1;
time = 0; % keep track of last time entry
%% Begin reading data
line = fgetl(fid);
while (size(str2num(line(1)))==0)
   line = fgetl(fid); 
end
while (line ~= -1)
    if (mod(entry, 10000)==0)
        fprintf('Processing entry: %d\n', entry);
    end
    %fprintf('Processing: %s\n', line);
    % parse the string
    tempT = regexp(line, '\d*(?=(+| )?(:))', 'match');
    tempF = regexp(line, '(?<=:).*(?=[)', 'match');
    if (isempty(tempF))
        tempF = regexp(line, '(?<=:).*', 'match');
    end
    tempL = regexp(line, '((?<=[).*(?=]))', 'match');
    tempL = strrep(tempL, '.', '0'); % replace . with 0
    % parse even further to reduce down to only necessary data
    fArrayCell = regexp(tempF, '(\.)|(\w\d)|\*', 'match');
    if (~isempty(tempL))
        lArrayCell = regexp(tempL, '\d*', 'match');
        lArrayStr = char(lArrayCell{1});   
    else
        lArrayStr = zeros(0,0);
    end
    % convert to integers/strings and add to data array
    tempT = char(tempT);
    time = str2num(tempT);
    
    % account for partial solutions
    if (time ~= data(entry,1))
        entry = entry + 1;
    end
     if (entry == 1) % part of accounting for '+' after first entry
         lastTime = time;
     end
    fArrayStr = char(fArrayCell{1});
    data(entry, 1) = time;
    %keyboard
    for i = 1:length(fArrayStr)
        currentF = deblank(fArrayStr(i, :));
        elemF = 0;
        if (currentF(1) == 'F')
            elemF = elemF + 1000;
        elseif (currentF(1) == 'L')
            elemF = elemF + 2000;
        elseif (currentF(1) == '*')
            elemF = 1;
        end
        if (length(currentF) > 1)
            elemF = elemF + str2num(currentF(1, 2)); % assign value to fluorophore
        end
        data(entry, 1+i) = elemF;
    end
    for i = 1:length(lArrayStr)
        if (~isempty(lArrayStr))
            currentL = deblank(lArrayStr(i,:));
            elemL = str2num(currentL);
        else
            elemL = 0;
        end
        data(entry, 1+numF+i) = elemL;
    end
    %lastTime = time;
    line = fgetl(fid);
end
fclose(fid);

% include number of fluorophores and lasers in the data matrix

% data = data(2:end, :);
 data(1,1) = numF;
 data(1,2) = numL;
end