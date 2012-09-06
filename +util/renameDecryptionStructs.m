%
% Gets rid of the "decryption" indicator in the structure variable names.
dir = 'D:\Documents\My Dropbox\Dwyer\Experiments\pattern1_spectrum_decryption\';
files = ls(dir);
for i=1:size(files,1) 
   if (~isempty(regexp(files(i,:), 'ic.*', 'match')))
        load(strcat(dir, deblank(files(i,:))));
        param = regexp(files(i, :), '(\d*)_(\d*)', 'match');
        oldvarname = strcat('ic', char(param{1}), '_decryption_i', char(param{3}));
        newvarname = regexp(files(i,:), '.*(?=\.mat)', 'match');
        newvarname = char(newvarname{:});
        if (exist(oldvarname, 'var'))
            fprintf('Renaming %s to %s.\n', oldvarname, newvarname);
            eval(sprintf('%s= %s', newvarname, oldvarname));
            eval(sprintf('save %s.mat %s;', newvarname, newvarname));
        end
        %clearvars -except files i
   end
end