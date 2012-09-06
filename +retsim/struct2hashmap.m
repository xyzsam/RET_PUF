% struct2hashmap
%
% Converts a MATLAB structure to a Java HashMap. This allows the structure
% to be placed as the value to another Java HashMap.
%
% SYNTAX : hmap = struct2hashmap(S)
%           S = single structure. 
%           hmap = a HashMap where keys are struct field names and values
%           are the values to those fields.

function hmap = struct2hashmap(S)
if ((~isstruct(S)) || (numel(S) ~= 1))
    error('struct2hashmap:invalid','%s',...
          'struct2hashmap only accepts single structures');
end

hmap = java.util.HashMap;
for fn = fieldnames(S)'
    % fn iterates through the field names of S
    % fn is a 1x1 cell array
    key = fn{1};
    value = getfield(S, key);
    hmap.put(key, value);
end
