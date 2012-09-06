% Sam Xi
% 03/10/11
% Returns the keySet of the TreeMap containing time bin categorized data,
% in the form of a sorted array. The TreeMap's keys are in the form
% time_dye, where time is a number corresponding to a time bin and dye is a
% number referring to a specific fluorophore.
%
% SYNTAX:   keySet = getKeys(tree)
%

function keySet = getKeys(tree)

if (nargin ~= 1)
    error('Invalid number of input arguments.')
elseif (nargout ~= 1)
    error('Invalid number of output arguments.')
end

if (strcmp(class(t), 'java.util.TreeMap')~= 1)
    error('Input tree is not a TreeMap');
end

k = char(tree.keySet); % convert keySet to a string
k = k(2:end-1); % strip off brackets

kCell = regexp(k, ',\ ', 'split'); % parse key information
kCell = regexp(kCell, '.*(?=_)', 'match'); % eliminate dye specific info.

keySet = zeros(length(kCell), 1);
for i = 1:size(keySet, 1)
   key = str2num(char(kCell{i}));
   if (i>1 && keySet(i-1)~=key) % if key does not already exist
       keySet(i) = key;
   end
end
lastEntry = find(keySet==0, 1, 'first'); % get the first zero entry
keySet = keySet(1:lastEntry); % delete extra zeros at the end
end