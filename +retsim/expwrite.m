% Sam Xi
% 04/09/2011
% ExpWrite
% Writes XML experiment files containing the given laser configurations and
% laser parameters
%
% SYNTAX : expwrite(dir, tconfig, numTB, siml, runtime, timebin, wl, inten, high)
%
%           dir      : directory in which experiment files will be written
%           tconfig  : array containing initial condition and laser impulse
%                     firing sequences
%           numTB    : number of time bins available to the lasers.
%           siml     : total simulation length (ps)
%           runtime  : runtime length
%           timebin  : size of time bins (ps)
%           wl       : 1xn array of wavelengths, where the nth value
%                     corresponds to the nth laser.
%           inten    : 1xn array of intensities.
%           high     : 1xn array of high_width values
%
%          note : n refers to the number of lasers (initial condition +
%                 information encoding lasers.
%
% RETURNS : 1 if the operation was successful, 0 if not.
%
% This function will create a set of directories organized by the


function n = expwrite(dir, tconfig, numTB, siml, runtime, timebin, wl, inten, high)
if (nargin ~= 9)
    error('Invalid number of parameters.')
end
% directory location of the experiment skeleton file.
skeleton_loc = 'D:\Documents\My Dropbox\Dwyer\scripts\experiment_skeleton.xml';
slocID = fopen(skeleton_loc, 'r')
if (slocID == -1)
    error('Invalid directory or file.')
end

numLasers = size(tconfig, 2)/2;
numCombos = numLasers^numTB;
% numTimeBins = log(sqrt(length(tconfig)));
% if (~isinteger(numTimeBins))
%     error('tconfig variable has invalid dimensions.');
% end

for entry = 1:size(tconfig, 1)
    tdata = tconfig(entry, :);
    tdata_corr = (tdata+abs(min(tdata))).*timebin;
    % get laser input combination
    infoLaserTime = tdata(1, size(tconfig, 2)/2+1:end); 
    % get initial condition laser sequence and correct it for negative offset
    icarray = tdata(1, 1:size(tdata, 2)/2); 
    icarray_corr = tdata_corr(1, 1:size(tconfig, 2)/2);
     
    % create folder for initial condition
    folderName = strcat('ic(', num2str(icarray), ')');
    %folderName = strrep(folderName, ' ', ',');
    %folderName = folderName(1:end-1);
    %folderName = strcat(folderName, ')');
    cd(dir);
    if (exist(folderName, 'dir')~= 7)
        mkdir(dir, folderName);
    end
    cd(folderName);
    
    
    % now, write each file in this directory
    
    % create output file
    fileName = strcat('input(', num2str(infoLaserTime), ')');
    %fileName = strrep(fileName, ' ', ',');
    curfid = fopen(strcat(fileName, '.xml'), 'w');
    
    % get next line from skeleton
    nextLine = fgetl(slocID);
    while (ischar(nextLine))
        if (strcmp(nextLine(1:8), '<photons')==1)
            fprintf(curfid, '%s\n', nextLine);
            % write new laser data
            for lnum = 1:length(wl)
                fprintf(curfid, '<laser wavelength=%d\n', wl(lnum));
                fprintf(curfid, 'intensity=%d\n', inten(lnum));
                fprintf(curfid, 'high_width=%d\n', high(lnum));
                fprintf(curfid, 'low_width=%d\n', runtime-1); % -1 so that the next cycle will begin on the multiples of run time
                if (lnum <= numLasers)
                    fprintf(curfid, 'start_time=%d/>\n', icarray_corr(lnum));
                else
                    fprintf(curfid, 'start_time=%d/>\n', tdata_corr(lnum));
                end
            end
        elseif (strcmp(nextLine(2:10), 'simlength')==1)
            fprintf(curfid, '\tsimlength\t\t= %d\n', siml);
        elseif (strcmp(nextLine(2:8), 'outputs')==1) % custom log file path
            log_dir = char(regexp(nextLine, '(?<=").*(?=")', 'match'));
            trace_dir = sprintf('%s%s\\', log_dir, folderName);
            if (exist(trace_dir, 'dir') ~= 7)
                mkdir(trace_dir);
            end
            cd(trace_dir);
            fprintf(curfid, '<outputs excitation_log="%s%s.log">\n', trace_dir, fileName);
        elseif (strcmp(nextLine(3:6), 'file') == 1)
            expData_str = char( regexp(nextLine, '(?<=name = ").*(?=" data)', 'match'));
            fprintf(curfid, '\t<file name = "%s%s\\expData_%s.txt" data =  "d e f x l"/>\n', expData_str, folderName, fileName);
        else
            % copy the skeleton text to the experiment file
            fprintf(curfid, '%s\n', nextLine);
        end
        nextLine = fgetl(slocID);
    end
    frewind(slocID);
    fclose(curfid);
    
    
end

fclose(slocID);

cd(dir);
% write file containing the parameters of this batch of experiments.
s = date;
paramFileName = sprintf('batch_parameters_%s.log', s);
currentDate = date;
pid = fopen(paramFileName, 'w');
fprintf(pid, 'Experiment Batch Parameters\n');
fprintf(pid, 'Date Created: %s\n', currentDate);
fprintf(pid, 'Number of lasers : %d\n', numLasers);
fprintf(pid, 'Total simulation length: %d\n', siml);
fprintf(pid, 'Number of time bins: %d\n', numTB);
fprintf(pid, 'Runtime of each laser : %d\n', runtime);
fprintf(pid, 'Size of time bins: %d\n', timebin);
fprintf(pid, 'Set of wavelengths used: %s\n', num2str(wl));
fprintf(pid, 'Set of intensities used: %s\n', num2str(inten));
fprintf(pid, 'Set of high widths used: %s\n', num2str(high));
fclose(pid);
n=1;

end
