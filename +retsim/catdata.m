% Sam Xi
% 02/20/11
% Categorize fluorescent events by time elapsed after a laser pulse.
%
% SYNTAX:   [totalExcitations t keySet] = catdata(data, tbin, laserInterval)
%               data : parsed data from running loadLog.
%               tbin : time per bin
%               laserInterval: time between laser pulses
%               totalExcitations : number of flourescent events
%               t    : a TreeMap containing the categorized data. The keys
%               are in the format time_dye, where time = time since last
%               laser pulse / tbin, and dye is a number i corresponding to
%               the ith dye.
%               keySet: a sorted array in ascending order, containing all
%               the values of timeSincePulse/tbin used in the TreeMap. This
%               is necessary in order to process the TreeMap's data
%               efficiently.
%
% This script does not currently take into account excitations from other
% fluorophores.

function [totalExcitations t keySet] = catdata(data, tbin, laserInterval)

if (nargin ~= 3)
    error('catdata : Invalid number of input arguments');
elseif (nargout ~= 3)
    error('catdata : Invalid number of output arguments');
end
if (isempty(data))
    error('Input data is empty. Please run loadLog first.');
end
if (size(data,2) < 2)
    error('Input data does not have enough columns.');
end

numF = data(1,1);
numL = data(1,2);
data = data(2:end, :);
% check for correct dimensions
if (size(data,2) ~= 1+numF+numL)
    error('Dimensions of data do not match number of fluorophores/lasers.')
end

entry = 2;
numRows = length(data);
totalExcitations = 0;
previousOrigin = 1;
% must use a TreeMap to handle large data sets with many zero rows.
t = java.util.TreeMap;
keySet = zeros(1,1);
while (entry < numRows)
    if (mod(entry, 10000)==0)
        fprintf('Categorizing entry : %d\n', entry);
    end
    % look for fluoroscent activity
    fluoro = data(entry, 2:2+numF-1);
    excited = find(ismember(fluoro, 1) == 1);
    if (~isempty(excited))
        % search for the last excitation, not including any pulse at the
        % current time. Work backwards
        for n = excited
            tempEnt = entry;
            %tempFluoro = data(tempEnt, 2:2+numF);
            %laserAct = data(tempEnt, end-numL+1:end);
            timeSincePulse = 0;
            if (data(entry,1) - laserInterval >= data(previousOrigin, 1))
                while ((tempEnt-1)>0 && mod(data(tempEnt,1),laserInterval) ~= 0)
                    tempEnt = tempEnt - 1;
                    %tempFluoro = data(tempEnt, 2:2+numF);
                end
                previousOrigin = tempEnt;
                %fprintf('Previous origin: %d\n', previousOrigin);
            end
            
            
            if (tempEnt > 0)
                timeSincePulse = data(entry,1) - data(previousOrigin,1);
            end
            
            if (timeSincePulse < laserInterval)
                % store the excitation in the appropriate time bin
                %fprintf('timeSincePulse=%d, n=%d\n', timeSincePulse, n);
                %fprintf('currentTime:%d, laserPulseTime=%d\n', data(entry,1), data(tempEnt,1));
                key = sprintf('%d_%d', floor(timeSincePulse/tbin), n);
                if (timeSincePulse == 0)
                    key = sprintf('-1_%d', n);
                end
                if (isempty(t.get(key)))
                    t.put(key, 1);
                else
                    t.put(key, t.get(key)+1);
                end
                
                % store the key in the keySet
                val = floor(timeSincePulse/tbin);
                if (timeSincePulse == 0)
                    val = -1;
                end
                if ~(ismember(keySet, val))
                    keySet(end+1) = val;
                end
                totalExcitations = totalExcitations + 1;
                
            % if the time since the pulse exceeds the laser interval time,
            % then throw out the point. this is caused by bugs in RETSim.
            else
                %timeSincePulse = laserInterval;
                fprintf('Last laser pulse at time %d was outside the range of the interval.\n',  data(entry, 1));
            end
            
            
        end
    end
    entry = entry+1;
end
keySet = sort(keySet);
fprintf('Total excitations: %d\n', totalExcitations);
end
