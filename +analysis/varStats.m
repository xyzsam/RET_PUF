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
%               Default is 1.
%               mean  = mean vs time and wavelength.
%               meanKeySet = an array of numbers that associate a row of data
%                   in mean to a time after the laser impulse.

function var = varStats(beginSet, endSet, dyes, mean, meanKeySet, graphOn)

if (nargin < 5)
    error('Not enough input arguments.')
elseif (nargin == 5)
    graphOn = 0;
elseif (nargin > 6)
    error('Too many input arguments.')
end

% last column in var matrix contains the number of data rows to average by.
var = zeros(size(mean)+[0 1]);
data_dir = 'D:\Documents\My Dropbox\Dwyer\Experiments\diamond40\';
% iterate through all data sets
for s = beginSet:endSet
    %fprintf('Current data set: %d\n', s);
    % load data. contains the keySet and graph arrays.
    eval(sprintf('load ''%sanalysisVars_%d.mat'';', data_dir, s));
    %offset = (keySet(1)==0); % if the first key entry is 0, we must provide an offset to avoid index out of bounds errors
    % iterate through keySet
    for i = 1:length(keySet)      
        key = keySet(i);%+offset % this keySet refers to the particular data set
        keyInMean = find(meanKeySet==key, 1, 'first');
        %fprintf('Current row: %d\n', i)
        var(keyInMean, 1:(size(var, 2)-1)) = abs(mean(keyInMean, :).^2 - (graph(:, i)').^2);
        var(keyInMean, size(var, 2)) = var(keyInMean, size(var, 2))+1; 
    end
end

% average the data, eliminate the last column.
for r = 1:size(var, 1)
   n = var(r, size(var, 2));
   var(r, :) = var(r,:)/n;
end
var = var(:, 1:(size(var, 2)-1));
var = var.^(1/2);
graph = var';
if (graphOn == 1)
    graphspectra(graph, meanKeySet, 200, 'Variance of Response of Chromophores to Laser Impulse');
end

end