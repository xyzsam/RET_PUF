% Sam Xi
% 03/22/11
% RETHelper
% Automatically organizes output files into the specified folder/file
% hierarchy.

home = 'D:\Documents\My Dropbox\Dwyer\';
exp_dir = 'Experiments\';
output_dir = 'pattern1_longerlow\';
results_dir = 'diamond40\';
output_name = 'diamond40_100.log';
new_output = 'diamond40_';
exp_name = 'expData.txt';
% get current listing of files
l = dir(strcat(home, exp_dir, results_dir, '*.log'));
nextnum = length(l) + 1;
% move and rename trace file
ll = dir(strcat(home, exp_dir, output_dir, output_name));
if (~isempty(ll))
	movefile(strcat(home, exp_dir, output_dir, output_name), ...
             strcat(home, exp_dir, results_dir, sprintf('%s%d.log', new_output, nextnum)));
end
% move and rename experiment out
ee = dir(strcat(home, exp_dir, results_dir, exp_name));
if (~isempty(ee))
    movefile(strcat(home, exp_dir, results_dir, exp_name), ...
             strcat(home, exp_dir, results_dir, sprintf('expData_%d.txt', nextnum)));
end

% logs = cell(length(l), 1);
% for i = 1:length(l)
%     logs{i} = l(i).name;
% end
