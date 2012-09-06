% hashmap2struct
%
% Converts a Java HashMap to a MATLAB struct. Field names are the keys to
% the HashMap and values are the corresponding values.
%
% SYNTAX: structure = hashmap2struct(m)
%           m = Java HashMap
%           structure = MATLAB struct.
%
% This script may not work if the HashMap values are of a type that MATLAB
% cannot expressly convert to an equivalent MATLAB type.

function structure = hashmap2struct(m)

keys = cell(m.keySet.toArray);
for i = 1:length(keys)
   key = keys{i};
   eval(sprintf('structure.%s = m.get(key);', key));
end
end