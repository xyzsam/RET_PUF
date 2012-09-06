% Sam Xi
% 03/22/11
% Perform statistical analysis on the spectral data.
% Calculate variance, mean of intensity as a function of time and wavelength.
%
% SYNTAX:  [var mean] = stats(beginSet, endSet, dyes)
%               beginSet = number of the first labeled .mat file containing
%                   analysis data.
%               endSet = number of the last labeled .mat file to be
%                   analyzed.
%               dyes  = cell array of dyes used
%               dataType = mean or variance. 1 is mean, 2 is variance.
%                   Default is 1.
%               mean  = mean vs time and wavelength.
%               keySet = an array of numbers that associate a row of data
%                   in mean to a time after the laser impulse.

function [mean meanKeySet] = meanStats(beginSet, endSet, dyes, graphOn)

if (nargin < 3)
    error('Not enough input arguments.')
elseif (nargin == 3)
    graphOn = 0;
elseif (nargin > 4)
    error('Too many input arguments.')
end

totalData = java.util.TreeMap;
data_dir = 'D:\Documents\My Dropbox\Dwyer\Experiments\diamond40\';
% iterate through all data sets
for s = beginSet:endSet
    % load data
    eval(sprintf('load ''%sanalysisVars_%d.mat'';', data_dir, s));
    fprintf('Current data set: %d\n', s);
    % iterate through keySet
    for i = 1:length(keySet)
        % iterate through the dyes
        for k = 1:length(dyes)
            key = sprintf('%d_%d', keySet(i), k);
            if (keySet(i)==102)
                fprintf('Breakpoint\n');
            end
            w = time_data.get(key);
            if (~isempty(w))
               % add to overall TreeMap
               % must encode number of added elements as well as total
               % value. this is done through a 4 digit number or more,
               % where the first three digits indicate the value and any
               % others indicate number of times elements were added to
               % this key.              
               totalw = totalData.get(key);
               if (~isempty(totalw))
                   totalData.put(key, totalData.get(key)+w+1000);
               else
                   totalData.put(key, w+1000);
               end
            end
        end
    end
end

% get the overall keySet
totalKeySet = char(totalData.keySet);
totalKeySet = totalKeySet(2:end-1);
totalKeySet = char(regexp(totalKeySet, '\d*_\d*', 'match'));

% potential bug if totalKeySet is a single row
for r = 1:length(totalKeySet)
    key = deblank(totalKeySet(r, :));
    rawData = totalData.get(key);
    nTimes = floor(rawData/1000);
    val = rawData - nTimes * 1000;
    totalData.put(key, val/nTimes);
end

% reduce keySet to purely numbers
tempkeySet = char(totalData.keySet);
tempkeySet = str2num(char(regexp(tempkeySet, '\d*(?=_)', 'match')));
tempkeySet = sort(tempkeySet);
keySet = tempkeySet(1);
for i = 2:length(tempkeySet)
    if (tempkeySet(i)~=tempkeySet(i-1))
        keySet(end+1) = tempkeySet(i);
    end
end

% load in dyes
dyes = char(dyes);
dyelist = 'D:\Documents\My Dropbox\Dwyer\02.22.11\DB\Dyes\list of dyes.txt';
dyeDBpath = 'D:\Documents\My Dropbox\Dwyer\02.22.11\DB\Dyes';
for i = 1:length(dyes)
    eval(sprintf('dye_%d = loadDye(''%s'', ''%s'', ''%s'');', i, deblank(dyes(1,:)), dyelist, dyeDBpath));
    eval(sprintf('dye_%d = zeroDye(dye_%d, 1, 1000);', i, i));
end
% build the overall graph
graph = zeros(length(keySet), 1000);
for dyeN = 1:length(dyes)
    for w = 1:length(keySet)
       key = strcat(num2str(keySet(w)), '_', num2str(dyeN));
       weight = totalData.get(key);
       if (~isempty(weight))        
           fprintf('Found key %s with weight %d. w = %d\n', key, weight, w);
           eval(sprintf('curDye = dye_%d;', dyeN)); % MATLAB does pointer assignments here, not copying data.
           graph(w, :) = graph(w,:)+weight * flipud(curDye(:, 2)');
       end       
    end
end

mean = graph;
graph = graph';
if (graphOn == 1)
    graphspectra(graph, keySet, 200, 'Mean Response of Chromophores to Laser Impulse');
end
meanKeySet = keySet;
end